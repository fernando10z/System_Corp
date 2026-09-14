-- =============================================================================
-- 04_tables_operacion.sql
--
-- EL NÚCLEO. Aquí vive core.orden_trabajo, la tabla principal de MIP.
--
-- Todo el ciclo técnico del cap. 8 al 14 cuelga de ella: la solicitud que la
-- originó, sus diagnósticos versionados, sus OT derivadas recursivas, la
-- cotización vigente, la ejecución con avances/incidencias/pausas, el trabajo
-- realizado, el cierre y las reaperturas.
--
-- La ÚLTIMA columna de orden_trabajo es `trazabilidad JSONB`: el árbol completo
-- de todo lo que esa OT generó. El motor que la mantiene está en 07_trazabilidad.sql.
--
-- Dos decisiones de modelado que conviene explicar:
--
--  1. La "versión vigente" de diagnóstico y cotización se marca con un booleano
--     en la fila hija + índice único parcial, NO con un FK desde orden_trabajo.
--     Un FK crearía un ciclo de dependencia entre tablas y obligaría a FKs
--     diferidas; el índice parcial hace cumplir "exactamente una vigente" (cap.
--     21.3) de forma más simple y sin ciclo.
--
--  2. El estado operativo y el estado administrativo son DIMENSIONES SEPARADAS
--     (cap. 25.1). Una OT puede estar CERRADA con OC pendiente. Por eso el estado
--     administrativo no es parte de ot_estado ni bloquea el cierre técnico.
-- =============================================================================
SET search_path = core, internal, public;

-- ── Solicitud de trabajo ─────────────────────────────────────────────────────
-- Puerta de entrada. Reporte NO técnico: el solicitante informa una necesidad,
-- no diagnostica. Nunca se le exige activo, CECOS ni causa (cap. 7.1, 24.1).
CREATE TABLE IF NOT EXISTS core.solicitud_trabajo (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES core.tenant(id),
  numero              VARCHAR(30) NOT NULL,
  estado              core.solicitud_estado NOT NULL DEFAULT 'borrador',

  titulo              VARCHAR(180) NOT NULL,
  descripcion         TEXT NOT NULL,          -- se conserva LITERALMENTE el reporte inicial (cap. 7.2)
  lugar               TEXT NOT NULL,          -- referencia libre: el solicitante puede no saber la ubicación técnica
  impacto_operativo_id UUID REFERENCES core.catalogo_item(id),
  impacto_comentario  TEXT,                   -- obligatorio cuando el ítem es 'Otro' (cap. 24.3)
  prioridad_percibida core.prioridad,         -- informativa; NO sustituye la prioridad técnica (cap. 8.4)

  area_id             UUID NOT NULL REFERENCES core.area(id),
  empresa_ruc_id      UUID NOT NULL REFERENCES core.empresa_ruc(id),
  sucursal_id         UUID REFERENCES core.sucursal(id),

  solicitante_id      UUID NOT NULL REFERENCES core.usuario(id),
  fecha_envio         TIMESTAMPTZ,
  fecha_primera_revision TIMESTAMPTZ,         -- alimenta el KPI de primera revisión (cap. 35.2)
  coordinador_revisor_id UUID REFERENCES core.usuario(id),

  solicitud_principal_id UUID REFERENCES core.solicitud_trabajo(id),  -- si se marcó DUPLICADA
  motivo_rechazo_id   UUID REFERENCES core.catalogo_item(id),
  observacion_actual  TEXT,

  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ,
  created_by          UUID REFERENCES core.usuario(id),
  updated_by          UUID REFERENCES core.usuario(id),

  CONSTRAINT uq_solicitud_numero UNIQUE (tenant_id, numero),
  CONSTRAINT ck_solicitud_titulo_largo CHECK (char_length(btrim(titulo)) BETWEEN 5 AND 180),
  CONSTRAINT ck_solicitud_descripcion CHECK (char_length(btrim(descripcion)) >= 10),
  CONSTRAINT ck_solicitud_no_autoduplicada CHECK (solicitud_principal_id IS NULL OR solicitud_principal_id <> id)
);
CREATE INDEX IF NOT EXISTS ix_solicitud_tenant_estado ON core.solicitud_trabajo (tenant_id, estado) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS ix_solicitud_solicitante ON core.solicitud_trabajo (solicitante_id, created_at DESC);
CREATE INDEX IF NOT EXISTS ix_solicitud_area ON core.solicitud_trabajo (area_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS ix_solicitud_titulo_trgm ON core.solicitud_trabajo USING gin (titulo gin_trgm_ops);

-- Cada decisión del coordinador queda registrada formalmente, con motivo (cap. 7.3, 24.2).
CREATE TABLE IF NOT EXISTS core.solicitud_decision (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      UUID NOT NULL REFERENCES core.tenant(id),
  solicitud_id   UUID NOT NULL REFERENCES core.solicitud_trabajo(id),
  tipo           core.tipo_decision_solicitud NOT NULL,
  estado_anterior core.solicitud_estado,
  estado_nuevo   core.solicitud_estado NOT NULL,
  motivo_id      UUID REFERENCES core.catalogo_item(id),
  comentario     TEXT,
  destinatario_id UUID REFERENCES core.usuario(id),          -- para 'derivar'
  solicitud_relacionada_id UUID REFERENCES core.solicitud_trabajo(id),  -- para 'marcar_duplicada'
  actor_id       UUID NOT NULL REFERENCES core.usuario(id),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_solicitud_decision_solicitud ON core.solicitud_decision (solicitud_id, created_at);

-- =============================================================================
-- ██  core.orden_trabajo — LA TABLA PRINCIPAL DE MIP  ██
-- =============================================================================
-- La OT es el contenedor del ciclo técnico de una intervención (cap. 8.1).
-- Una OT representa UNA intervención técnica ejecutable; si el alcance se divide,
-- se crean OT derivadas (cap. 2.4, 10, 27). Esa regla es la que hace comparables
-- los costos del cap. 16.2, así que el modelo la protege con el anti-ciclo de 06.
--
-- La última columna es `trazabilidad`. No es decorativa ni un log: es el árbol
-- navegable de TODO lo que esta OT generó, y el motor de 07_trazabilidad.sql
-- garantiza que esté siempre fresco.
-- =============================================================================
CREATE TABLE IF NOT EXISTS core.orden_trabajo (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             UUID NOT NULL REFERENCES core.tenant(id),
  numero_ot             VARCHAR(30) NOT NULL,   -- generado por MIP, único en el tenant, jamás reutilizado

  -- Origen ────────────────────────────────────────────────────────────────────
  solicitud_origen_id   UUID REFERENCES core.solicitud_trabajo(id),  -- NULL en derivadas sin solicitud propia
  ot_padre_id           UUID REFERENCES core.orden_trabajo(id),      -- padre DIRECTO; NULL si es principal
  nivel                 INT NOT NULL DEFAULT 0,                      -- 0 = principal; se recalcula en trigger
  motivo_derivacion_id  UUID REFERENCES core.catalogo_item(id),
  motivo_derivacion_texto TEXT,
  es_bloqueante_para_padre BOOLEAN NOT NULL DEFAULT true,            -- derivada no bloqueante: cap. 10, 27.2
  independizada_de_padre BOOLEAN NOT NULL DEFAULT false,             -- sobrevive a la cancelación del padre (Anexo C)

  -- Organización ──────────────────────────────────────────────────────────────
  sucursal_id           UUID REFERENCES core.sucursal(id),
  empresa_ruc_id        UUID REFERENCES core.empresa_ruc(id),
  area_id               UUID REFERENCES core.area(id),
  cecos_id              UUID REFERENCES core.cecos(id),

  -- Clasificación técnica ─────────────────────────────────────────────────────
  tipo_mantenimiento_id UUID REFERENCES core.catalogo_item(id),
  tipo_trabajo_id       UUID REFERENCES core.tipo_trabajo(id),
  prioridad_tecnica     core.prioridad,          -- la fija el coordinador; independiente de la percibida
  es_emergencia         BOOLEAN NOT NULL DEFAULT false,
  emergencia_justificacion TEXT,
  emergencia_declarada_por UUID REFERENCES core.usuario(id),
  emergencia_declarada_at  TIMESTAMPTZ,
  regularizacion_pendiente BOOLEAN NOT NULL DEFAULT false,  -- la emergencia NO elimina el deber de regularizar (cap. 3)

  -- Estado operativo ──────────────────────────────────────────────────────────
  estado                core.ot_estado NOT NULL DEFAULT 'creada',
  condicion             core.ot_condicion NOT NULL DEFAULT 'activa',

  -- Estado administrativo: dimensión SEPARADA del estado operativo (cap. 25.1) ─
  estado_administrativo core.estado_administrativo NOT NULL DEFAULT 'sin_solped',

  -- Responsables ──────────────────────────────────────────────────────────────
  coordinador_id        UUID REFERENCES core.usuario(id),   -- obligatorio para salir de CREADA
  ejecutor_id           UUID REFERENCES core.usuario(id),   -- requisito de inicio

  -- Fechas: todas auditadas; duración en días calendario (cap. 12.3, 25.1) ─────
  fecha_creacion        TIMESTAMPTZ NOT NULL DEFAULT now(),
  fecha_inicio_real     TIMESTAMPTZ,
  fecha_termino_real    TIMESTAMPTZ,
  fecha_cierre          TIMESTAMPTZ,

  -- Cancelación / reapertura ──────────────────────────────────────────────────
  motivo_cancelacion_id UUID REFERENCES core.catalogo_item(id),
  cancelacion_observacion TEXT,
  fecha_cancelacion     TIMESTAMPTZ,
  veces_reabierta       INT NOT NULL DEFAULT 0,

  -- Control ───────────────────────────────────────────────────────────────────
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ,   -- las OT se CANCELAN, no se eliminan (cap. 18.1)
  created_by            UUID REFERENCES core.usuario(id),
  updated_by            UUID REFERENCES core.usuario(id),

  -- ══════════════════════════════════════════════════════════════════════════
  -- TRAZABILIDAD · el árbol completo de todo lo que esta OT generó.
  -- Mantenida por internal.fn_ot_trazabilidad + app.sp_ot_trazabilidad_refrescar.
  -- `trazabilidad_dirty` la marcan los triggers de TODAS las tablas hijas.
  -- Va al final a propósito: es la última columna de la tabla principal.
  -- ══════════════════════════════════════════════════════════════════════════
  trazabilidad_version  INT     NOT NULL DEFAULT 0,
  trazabilidad_dirty    BOOLEAN NOT NULL DEFAULT true,
  trazabilidad_at       TIMESTAMPTZ,
  trazabilidad          JSONB   NOT NULL DEFAULT '{}'::jsonb,

  CONSTRAINT uq_ot_numero UNIQUE (tenant_id, numero_ot),
  -- Una OT no puede ser su propio padre. Los ciclos de más de un salto los ataja
  -- el trigger trg_ot_anticiclo de 06_triggers.sql (cap. 21.3, QA-15).
  CONSTRAINT ck_ot_no_autopadre CHECK (ot_padre_id IS NULL OR ot_padre_id <> id),
  -- El término no puede anteceder al inicio; el cierre no puede anteceder al término (cap. 21.3, QA-13).
  CONSTRAINT ck_ot_termino_tras_inicio CHECK (
    fecha_termino_real IS NULL OR fecha_inicio_real IS NULL OR fecha_termino_real >= fecha_inicio_real),
  CONSTRAINT ck_ot_cierre_tras_termino CHECK (
    fecha_cierre IS NULL OR fecha_termino_real IS NULL OR fecha_cierre >= fecha_termino_real),
  -- Declarar emergencia exige justificación (cap. 8.4, QA-11).
  CONSTRAINT ck_ot_emergencia_justificada CHECK (
    es_emergencia = false OR btrim(coalesce(emergencia_justificacion,'')) <> '')
);

-- Una solicitud aceptada genera UNA sola OT; no se convierte dos veces (cap. 21.3, QA-03).
CREATE UNIQUE INDEX IF NOT EXISTS uq_ot_solicitud_origen
  ON core.orden_trabajo (solicitud_origen_id)
  WHERE solicitud_origen_id IS NOT NULL AND deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS ix_ot_tenant_estado    ON core.orden_trabajo (tenant_id, estado) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS ix_ot_padre            ON core.orden_trabajo (ot_padre_id) WHERE ot_padre_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_ot_coordinador      ON core.orden_trabajo (coordinador_id, estado);
CREATE INDEX IF NOT EXISTS ix_ot_ejecutor         ON core.orden_trabajo (ejecutor_id, estado);
CREATE INDEX IF NOT EXISTS ix_ot_organizacion     ON core.orden_trabajo (sucursal_id, empresa_ruc_id, area_id);
CREATE INDEX IF NOT EXISTS ix_ot_admin            ON core.orden_trabajo (tenant_id, estado_administrativo);
CREATE INDEX IF NOT EXISTS ix_ot_emergencia       ON core.orden_trabajo (tenant_id) WHERE es_emergencia = true;
CREATE INDEX IF NOT EXISTS ix_ot_dirty            ON core.orden_trabajo (id) WHERE trazabilidad_dirty = true;
-- Consultas ad-hoc DENTRO del árbol de trazabilidad.
CREATE INDEX IF NOT EXISTS ix_ot_trazabilidad_gin ON core.orden_trabajo USING gin (trazabilidad jsonb_path_ops);

COMMENT ON TABLE  core.orden_trabajo IS
  'TABLA PRINCIPAL de MIP. Contenedor del ciclo técnico de una intervención (cap. 8.1). La columna trazabilidad guarda el árbol completo de todo lo que la OT generó.';
COMMENT ON COLUMN core.orden_trabajo.trazabilidad IS
  'Árbol JSONB de TODO lo que generó esta OT: solicitud origen, diagnósticos versionados, derivadas recursivas, cotizaciones, ejecución, cierre, administrativo, adjuntos, conversación, costos y eventos. Proyección — la fuente de verdad son las tablas.';

-- Toda transición operativa deja rastro; nunca se edita el campo estado a mano (regla 23.1, cap. 33).
CREATE TABLE IF NOT EXISTS core.ot_estado_historial (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES core.tenant(id),
  ot_id           UUID NOT NULL REFERENCES core.orden_trabajo(id),
  estado_anterior core.ot_estado,
  estado_nuevo    core.ot_estado NOT NULL,
  motivo_id       UUID REFERENCES core.catalogo_item(id),
  motivo_texto    TEXT,
  actor_id        UUID NOT NULL REFERENCES core.usuario(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_ot_estado_historial_ot ON core.ot_estado_historial (ot_id, created_at);

-- ── Diagnóstico ──────────────────────────────────────────────────────────────
-- Versionado: un cambio NO sobrescribe la historia (cap. 9, 26). Los cuatro campos
-- técnicos son obligatorios para pasar a EN COTIZACION (QA-07).
CREATE TABLE IF NOT EXISTS core.diagnostico (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id          UUID NOT NULL REFERENCES core.tenant(id),
  ot_id              UUID NOT NULL REFERENCES core.orden_trabajo(id),
  version            INT NOT NULL,
  vigente            BOOLEAN NOT NULL DEFAULT true,

  diagnostico        TEXT NOT NULL,
  causa_probable     TEXT NOT NULL,
  alcance            TEXT NOT NULL,
  trabajo_a_realizar TEXT NOT NULL,   -- plan de trabajo, NO trabajo ya ejecutado (cap. 9)
  observaciones      TEXT,
  lecturas_instrumentos TEXT,          -- sólo texto: no se modelan series medibles en el MVP (cap. 9, 26.2)

  autor_id           UUID NOT NULL REFERENCES core.usuario(id),
  aprobado_por       UUID REFERENCES core.usuario(id),
  aprobado_at        TIMESTAMPTZ,
  motivo_cambio      TEXT,             -- obligatorio a partir de la versión 2 (QA-06)
  reemplaza_a        UUID REFERENCES core.diagnostico(id),

  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by         UUID REFERENCES core.usuario(id),
  updated_by         UUID REFERENCES core.usuario(id),

  CONSTRAINT uq_diagnostico_version UNIQUE (ot_id, version),
  CONSTRAINT ck_diagnostico_campos CHECK (
    btrim(diagnostico) <> '' AND btrim(causa_probable) <> ''
    AND btrim(alcance) <> '' AND btrim(trabajo_a_realizar) <> '')
);
-- Exactamente UNA versión vigente por OT (cap. 21.3).
CREATE UNIQUE INDEX IF NOT EXISTS uq_diagnostico_vigente
  ON core.diagnostico (ot_id) WHERE vigente = true;
CREATE INDEX IF NOT EXISTS ix_diagnostico_ot ON core.diagnostico (ot_id, version DESC);

-- ── Cotización seleccionada ──────────────────────────────────────────────────
-- MIP NO compara proveedores (cap. 11). Recibe la cotización final ya elegida.
-- Una vigente por OT; reemplazar no borra, versiona (cap. 28.2, QA-09).
CREATE TABLE IF NOT EXISTS core.cotizacion (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES core.tenant(id),
  ot_id             UUID NOT NULL REFERENCES core.orden_trabajo(id),
  version           INT NOT NULL,
  vigente           BOOLEAN NOT NULL DEFAULT true,

  proveedor_id      UUID REFERENCES core.proveedor(id),
  proveedor_ruc     VARCHAR(20),
  proveedor_nombre  VARCHAR(200),
  numero_cotizacion VARCHAR(60),
  fecha_cotizacion  DATE,
  monto             NUMERIC(14,2),
  moneda            core.moneda_codigo NOT NULL DEFAULT 'PEN',
  plazo_ofrecido_dias INT,                 -- el plazo pertenece a la cotización, no a la OT (cap. 12.1)
  observaciones     TEXT,

  motivo_reemplazo  TEXT,                  -- obligatorio al reemplazar (cap. 28.2)
  reemplaza_a       UUID REFERENCES core.cotizacion(id),
  invalidada        BOOLEAN NOT NULL DEFAULT false,

  cargada_por       UUID NOT NULL REFERENCES core.usuario(id),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by        UUID REFERENCES core.usuario(id),
  updated_by        UUID REFERENCES core.usuario(id),

  CONSTRAINT uq_cotizacion_version UNIQUE (ot_id, version),
  CONSTRAINT ck_cotizacion_monto CHECK (monto IS NULL OR monto >= 0),
  CONSTRAINT ck_cotizacion_plazo CHECK (plazo_ofrecido_dias IS NULL OR plazo_ofrecido_dias >= 0)
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_cotizacion_vigente
  ON core.cotizacion (ot_id) WHERE vigente = true AND invalidada = false;
CREATE INDEX IF NOT EXISTS ix_cotizacion_ot ON core.cotizacion (ot_id, version DESC);
CREATE INDEX IF NOT EXISTS ix_cotizacion_proveedor ON core.cotizacion (proveedor_id, fecha_cotizacion DESC);

-- ── Ejecución ────────────────────────────────────────────────────────────────
-- Una fila por OT: agrupa los datos de arranque y término del trabajo (cap. 12, 29).
CREATE TABLE IF NOT EXISTS core.ejecucion (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id          UUID NOT NULL REFERENCES core.tenant(id),
  ot_id              UUID NOT NULL REFERENCES core.orden_trabajo(id),
  responsable_id     UUID NOT NULL REFERENCES core.usuario(id),
  inicio_real        TIMESTAMPTZ NOT NULL,
  termino_real       TIMESTAMPTZ,
  confirmado_por     UUID REFERENCES core.usuario(id),   -- confirmación explícita del coordinador (cap. 12.1)
  inicio_sin_cotizacion BOOLEAN NOT NULL DEFAULT false,  -- true sólo en emergencia (cap. 29.1)
  observaciones      TEXT,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by         UUID REFERENCES core.usuario(id),
  updated_by         UUID REFERENCES core.usuario(id),
  CONSTRAINT uq_ejecucion_ot UNIQUE (ot_id),
  CONSTRAINT ck_ejecucion_termino CHECK (termino_real IS NULL OR termino_real >= inicio_real)
);

-- Avance: declaración NARRATIVA del progreso. El porcentaje no es obligatorio
-- y un avance por sí solo no cambia el estado de la OT (cap. 29.2).
CREATE TABLE IF NOT EXISTS core.ot_avance (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    UUID NOT NULL REFERENCES core.tenant(id),
  ot_id        UUID NOT NULL REFERENCES core.orden_trabajo(id),
  descripcion  TEXT NOT NULL,
  porcentaje   NUMERIC(5,2),
  autor_id     UUID NOT NULL REFERENCES core.usuario(id),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT ck_avance_porcentaje CHECK (porcentaje IS NULL OR (porcentaje >= 0 AND porcentaje <= 100)),
  CONSTRAINT ck_avance_descripcion CHECK (btrim(descripcion) <> '')
);
CREATE INDEX IF NOT EXISTS ix_ot_avance_ot ON core.ot_avance (ot_id, created_at DESC);

-- Incidencia: hecho que afecta el trabajo (falta de acceso, retraso de proveedor,
-- material incorrecto, riesgo de seguridad, interferencia u otro) — cap. 12.2.
CREATE TABLE IF NOT EXISTS core.ot_incidencia (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES core.tenant(id),
  ot_id         UUID NOT NULL REFERENCES core.orden_trabajo(id),
  tipo_id       UUID REFERENCES core.catalogo_item(id),
  descripcion   TEXT NOT NULL,
  resuelta      BOOLEAN NOT NULL DEFAULT false,
  resuelta_at   TIMESTAMPTZ,
  resolucion    TEXT,
  autor_id      UUID NOT NULL REFERENCES core.usuario(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_ot_incidencia_ot ON core.ot_incidencia (ot_id, created_at DESC);

-- Pausa: no se permite abrir una nueva si hay una vigente — evita intervalos
-- ambiguos (cap. 29.3, QA-12). Lo hace cumplir el índice único parcial de abajo.
CREATE TABLE IF NOT EXISTS core.ot_pausa (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id          UUID NOT NULL REFERENCES core.tenant(id),
  ot_id              UUID NOT NULL REFERENCES core.orden_trabajo(id),
  motivo_id          UUID REFERENCES core.catalogo_item(id),
  motivo_texto       TEXT NOT NULL,
  fecha_pausa        TIMESTAMPTZ NOT NULL DEFAULT now(),
  fecha_reanudacion  TIMESTAMPTZ,
  observacion_reanudacion TEXT,
  pausada_por        UUID NOT NULL REFERENCES core.usuario(id),
  reanudada_por      UUID REFERENCES core.usuario(id),
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT ck_pausa_reanudacion CHECK (fecha_reanudacion IS NULL OR fecha_reanudacion >= fecha_pausa)
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_pausa_abierta
  ON core.ot_pausa (ot_id) WHERE fecha_reanudacion IS NULL;
CREATE INDEX IF NOT EXISTS ix_ot_pausa_ot ON core.ot_pausa (ot_id, fecha_pausa DESC);

-- ── Trabajo realizado y su revisión ──────────────────────────────────────────
-- El ejecutor declara; el coordinador revisa. Versionado porque una corrección
-- devuelve la OT a EN TRABAJO y luego se vuelve a declarar (cap. 14.1-14.2, QA-14).
CREATE TABLE IF NOT EXISTS core.trabajo_realizado (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             UUID NOT NULL REFERENCES core.tenant(id),
  ot_id                 UUID NOT NULL REFERENCES core.orden_trabajo(id),
  version               INT NOT NULL,
  vigente               BOOLEAN NOT NULL DEFAULT true,

  descripcion           TEXT NOT NULL,
  resultado_id          UUID REFERENCES core.catalogo_item(id),
  resultado_texto       TEXT,
  fecha_termino         TIMESTAMPTZ NOT NULL,
  observaciones         TEXT,
  declarado_por         UUID NOT NULL REFERENCES core.usuario(id),

  resultado_revision    core.resultado_revision,
  revision_observacion  TEXT,
  revisado_por          UUID REFERENCES core.usuario(id),
  revisado_at           TIMESTAMPTZ,

  -- La conformidad del solicitante es opcional y NO bloquea el cierre (cap. 14.2).
  conformidad           core.conformidad_solicitante NOT NULL DEFAULT 'sin_pronunciarse',
  conformidad_comentario TEXT,
  conformidad_at        TIMESTAMPTZ,

  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by            UUID REFERENCES core.usuario(id),
  updated_by            UUID REFERENCES core.usuario(id),
  CONSTRAINT uq_trabajo_realizado_version UNIQUE (ot_id, version),
  CONSTRAINT ck_trabajo_descripcion CHECK (btrim(descripcion) <> '')
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_trabajo_realizado_vigente
  ON core.trabajo_realizado (ot_id) WHERE vigente = true;

-- ── Cierre y reapertura ──────────────────────────────────────────────────────
-- El cierre anterior NUNCA se elimina; por eso el cierre es una tabla con filas,
-- no un par de columnas (cap. 14.4, QA-22).
CREATE TABLE IF NOT EXISTS core.ot_cierre (
  id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id              UUID NOT NULL REFERENCES core.tenant(id),
  ot_id                  UUID NOT NULL REFERENCES core.orden_trabajo(id),
  secuencia              INT NOT NULL,
  vigente                BOOLEAN NOT NULL DEFAULT true,
  fecha_cierre           TIMESTAMPTZ NOT NULL DEFAULT now(),
  cerrado_por            UUID NOT NULL REFERENCES core.usuario(id),
  -- Cierre con pendiente administrativo: exige confirmación explícita y observación
  -- obligatoria del coordinador (cap. 14.3, 31.2, QA-19).
  admin_revisado         BOOLEAN NOT NULL DEFAULT false,
  estado_admin_al_cierre core.estado_administrativo,
  observacion_pendiente  TEXT,
  derivadas_bloqueantes_resueltas BOOLEAN NOT NULL DEFAULT true,
  created_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_ot_cierre_secuencia UNIQUE (ot_id, secuencia)
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_ot_cierre_vigente
  ON core.ot_cierre (ot_id) WHERE vigente = true;

CREATE TABLE IF NOT EXISTS core.ot_reapertura (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES core.tenant(id),
  ot_id           UUID NOT NULL REFERENCES core.orden_trabajo(id),
  cierre_id       UUID REFERENCES core.ot_cierre(id),
  motivo_id       UUID REFERENCES core.catalogo_item(id),
  motivo_texto    TEXT NOT NULL,     -- motivo SIEMPRE obligatorio (cap. 14.4)
  estado_retorno  core.ot_estado NOT NULL,
  reabierta_por   UUID NOT NULL REFERENCES core.usuario(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT ck_reapertura_motivo CHECK (btrim(motivo_texto) <> ''),
  CONSTRAINT ck_reapertura_estado CHECK (estado_retorno IN ('en_trabajo','en_diagnostico'))
);
CREATE INDEX IF NOT EXISTS ix_ot_reapertura_ot ON core.ot_reapertura (ot_id, created_at);
