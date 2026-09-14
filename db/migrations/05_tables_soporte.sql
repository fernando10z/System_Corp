-- =============================================================================
-- 05_tables_soporte.sql
--
-- Todo lo que cuelga de la OT sin ser el ciclo técnico en sí:
--   · Seguimiento administrativo (SOLPED / OC / liberación) — cap. 15, 22, 31.
--   · Conversación contextual y línea de tiempo — cap. 13, 30.
--   · Adjuntos centralizados — cap. 28.3.
--   · Motor de costos unitarios — cap. 16, 32.
--   · Transversales: notificaciones, auditoría y la bitácora ot_evento — cap. 18, 19, 33.
--
-- Sobre SAP: el cap. 22.4 deja explícitamente pendientes los campos exactos de
-- SOLPED y el mecanismo de integración. Aquí se modela la ESTRUCTURA (para no
-- perder trazabilidad) y los estados de integración, pero no se implementa
-- comportamiento de conector. El formulario interno va en un JSONB justamente
-- porque su forma la define cada cliente.
-- =============================================================================
SET search_path = core, internal, public;

-- ── Seguimiento administrativo ───────────────────────────────────────────────
-- Una fila por OT. Es el resumen consolidado; el detalle vive en las tablas hijas.
CREATE TABLE IF NOT EXISTS core.seguimiento_administrativo (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES core.tenant(id),
  ot_id               UUID NOT NULL REFERENCES core.orden_trabajo(id),
  estado_consolidado  core.estado_administrativo NOT NULL DEFAULT 'sin_solped',
  monto_liberado_total NUMERIC(14,2) NOT NULL DEFAULT 0,
  moneda              core.moneda_codigo NOT NULL DEFAULT 'PEN',
  revisado_por        UUID REFERENCES core.usuario(id),
  revisado_at         TIMESTAMPTZ,
  observacion         TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by          UUID REFERENCES core.usuario(id),
  updated_by          UUID REFERENCES core.usuario(id),
  CONSTRAINT uq_seguimiento_admin_ot UNIQUE (ot_id),
  CONSTRAINT ck_seguimiento_monto CHECK (monto_liberado_total >= 0)
);

-- SOLPED. La estructura soporta VARIAS por OT (cap. 21.1, 22.2); el MVP presenta
-- la principal/vigente. Una SOLPED confirmada no se borra físicamente: se anula
-- lógicamente tras gestión manual en SAP (cap. 15.1, 18.1, QA-29, QA-30).
CREATE TABLE IF NOT EXISTS core.solped (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES core.tenant(id),
  ot_id               UUID NOT NULL REFERENCES core.orden_trabajo(id),
  version             INT NOT NULL,
  vigente             BOOLEAN NOT NULL DEFAULT true,

  numero_interno      VARCHAR(40),
  numero_sap          VARCHAR(40),          -- lo devuelve SAP; no editable sin flujo auditado (cap. 22.2)
  referencia_externa  VARCHAR(80),          -- clave de idempotencia para evitar duplicados (cap. 22.3)
  estado_integracion  core.solped_estado_integracion NOT NULL DEFAULT 'borrador',

  -- El formulario interno es JSONB a propósito: sus campos exactos son una
  -- decisión pendiente por cliente (cap. 22.4, 38). Modelarlo en columnas fijas
  -- ahora sería inventar un supuesto de desarrollador.
  formulario          JSONB NOT NULL DEFAULT '{}'::jsonb,

  cotizacion_id       UUID REFERENCES core.cotizacion(id),
  monto               NUMERIC(14,2),
  moneda              core.moneda_codigo NOT NULL DEFAULT 'PEN',
  fecha_solped        DATE,

  mensaje_sap         TEXT,                 -- se conservan mensaje e intento en ERROR SAP (cap. 22.3)
  intentos            INT NOT NULL DEFAULT 0,
  ultimo_intento_at   TIMESTAMPTZ,

  anulada             BOOLEAN NOT NULL DEFAULT false,
  motivo_anulacion    TEXT,
  anulada_por         UUID REFERENCES core.usuario(id),
  anulada_at          TIMESTAMPTZ,
  reemplaza_a         UUID REFERENCES core.solped(id),

  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by          UUID REFERENCES core.usuario(id),
  updated_by          UUID REFERENCES core.usuario(id),
  CONSTRAINT uq_solped_version UNIQUE (ot_id, version),
  CONSTRAINT ck_solped_monto CHECK (monto IS NULL OR monto >= 0),
  CONSTRAINT ck_solped_anulacion CHECK (anulada = false OR btrim(coalesce(motivo_anulacion,'')) <> '')
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_solped_vigente
  ON core.solped (ot_id) WHERE vigente = true AND anulada = false;
CREATE INDEX IF NOT EXISTS ix_solped_ot ON core.solped (ot_id, version DESC);
CREATE INDEX IF NOT EXISTS ix_solped_numero_sap ON core.solped (tenant_id, numero_sap) WHERE numero_sap IS NOT NULL;

-- Orden de compra: registro MANUAL de seguimiento. MIP no crea OC (cap. 2.3, 15).
CREATE TABLE IF NOT EXISTS core.orden_compra (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES core.tenant(id),
  ot_id         UUID NOT NULL REFERENCES core.orden_trabajo(id),
  solped_id     UUID REFERENCES core.solped(id),
  numero_oc     VARCHAR(40) NOT NULL,
  fecha_oc      DATE,
  monto         NUMERIC(14,2),
  moneda        core.moneda_codigo NOT NULL DEFAULT 'PEN',
  observacion   TEXT,
  anulada       BOOLEAN NOT NULL DEFAULT false,
  motivo_anulacion TEXT,
  registrada_por UUID NOT NULL REFERENCES core.usuario(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by    UUID REFERENCES core.usuario(id),
  updated_by    UUID REFERENCES core.usuario(id),
  CONSTRAINT ck_orden_compra_monto CHECK (monto IS NULL OR monto >= 0)
);
CREATE INDEX IF NOT EXISTS ix_orden_compra_ot ON core.orden_compra (ot_id, created_at DESC);

-- Liberación: estado manual e historizado. Cada cambio guarda valor anterior y
-- nuevo, usuario, fecha y observación (cap. 15, 31.3, QA-21). El sistema NO debe
-- inferir que el monto liberado equivale al costo final de la OT.
CREATE TABLE IF NOT EXISTS core.liberacion_historial (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Secuencia MONÓTONA. Hace falta porque created_at usa now(), que devuelve el
  -- instante de INICIO DE LA TRANSACCIÓN: dos liberaciones registradas en la
  -- misma transacción comparten timestamp y "la última" se vuelve ambigua.
  -- El estado administrativo consolidado depende de cuál es la última, así que
  -- la ambigüedad no es cosmética: cambia el indicador que ve el usuario.
  secuencia         BIGSERIAL NOT NULL,
  tenant_id         UUID NOT NULL REFERENCES core.tenant(id),
  ot_id             UUID NOT NULL REFERENCES core.orden_trabajo(id),
  orden_compra_id   UUID REFERENCES core.orden_compra(id),
  estado_anterior   core.estado_liberacion,
  estado_nuevo      core.estado_liberacion NOT NULL,
  monto_anterior    NUMERIC(14,2),
  monto_nuevo       NUMERIC(14,2) NOT NULL DEFAULT 0,
  moneda            core.moneda_codigo NOT NULL DEFAULT 'PEN',
  observacion       TEXT,
  actor_id          UUID NOT NULL REFERENCES core.usuario(id),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT ck_liberacion_monto_positivo CHECK (monto_nuevo >= 0),
  CONSTRAINT ck_liberacion_monto_anterior CHECK (monto_anterior IS NULL OR monto_anterior >= 0)
);
CREATE INDEX IF NOT EXISTS ix_liberacion_ot ON core.liberacion_historial (ot_id, secuencia DESC);

-- ── Conversación contextual ──────────────────────────────────────────────────
-- Un canal por OT (cap. 21.1). Tras cerrar, queda en solo lectura salvo
-- reapertura o permiso excepcional (cap. 13, 30.2).
CREATE TABLE IF NOT EXISTS core.conversacion (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    UUID NOT NULL REFERENCES core.tenant(id),
  ot_id        UUID NOT NULL REFERENCES core.orden_trabajo(id),
  solo_lectura BOOLEAN NOT NULL DEFAULT false,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_conversacion_ot UNIQUE (ot_id)
);

CREATE TABLE IF NOT EXISTS core.conversacion_participante (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES core.tenant(id),
  conversacion_id UUID NOT NULL REFERENCES core.conversacion(id),
  usuario_id      UUID NOT NULL REFERENCES core.usuario(id),
  puede_escribir  BOOLEAN NOT NULL DEFAULT true,
  ve_notas_internas BOOLEAN NOT NULL DEFAULT false,  -- el solicitante NO ve notas internas (cap. 13, QA-18)
  invitado_por    UUID REFERENCES core.usuario(id),
  activo          BOOLEAN NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_conversacion_participante UNIQUE (conversacion_id, usuario_id)
);

-- Mensajes humanos y eventos de sistema comparten la línea de tiempo, pero con
-- tipos distintos (regla 23.1). Un mensaje NUNCA cambia el estado operativo ni
-- sustituye un registro formal (cap. 13, 30.2).
CREATE TABLE IF NOT EXISTS core.mensaje (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         UUID NOT NULL REFERENCES core.tenant(id),
  conversacion_id   UUID NOT NULL REFERENCES core.conversacion(id),
  tipo              core.tipo_mensaje NOT NULL DEFAULT 'humano',
  visibilidad       core.visibilidad_mensaje NOT NULL DEFAULT 'canal',
  estado            core.estado_mensaje NOT NULL DEFAULT 'publicado',
  cuerpo            TEXT NOT NULL,
  cuerpo_anterior   TEXT,                    -- la edición conserva el contenido previo (cap. 30.2)
  responde_a        UUID REFERENCES core.mensaje(id),
  autor_id          UUID REFERENCES core.usuario(id),   -- NULL cuando tipo = 'sistema'
  menciones         UUID[] NOT NULL DEFAULT '{}',
  editado_at        TIMESTAMPTZ,
  retirado_at       TIMESTAMPTZ,             -- el retiro es lógico: no se borra el rastro
  retirado_por      UUID REFERENCES core.usuario(id),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT ck_mensaje_autor CHECK (tipo = 'sistema' OR autor_id IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS ix_mensaje_conversacion ON core.mensaje (conversacion_id, created_at);

-- ── Adjuntos ─────────────────────────────────────────────────────────────────
-- Polimórfico pero SIEMPRE con contexto: entidad, etapa y autor. No debe haber
-- archivos sueltos (regla 23.1). Los límites del cap. 28.3 son configurables por
-- tenant, así que se validan en el SP, no en un CHECK rígido.
CREATE TABLE IF NOT EXISTS core.adjunto (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES core.tenant(id),
  ot_id         UUID REFERENCES core.orden_trabajo(id),      -- desnormalizado a propósito: hace barato el árbol
  entidad_tipo  VARCHAR(40) NOT NULL,   -- 'solicitud_trabajo','diagnostico','cotizacion','ot_avance',…
  entidad_id    UUID NOT NULL,
  etapa         core.etapa_adjunto NOT NULL,
  tipo          core.tipo_adjunto NOT NULL,
  nombre        VARCHAR(255) NOT NULL,
  nombre_original VARCHAR(255),
  mime_type     VARCHAR(120),
  tamano_bytes  BIGINT,
  storage_key   TEXT NOT NULL,          -- ruta en MinIO/S3
  checksum      VARCHAR(80),
  estado        core.estado_adjunto NOT NULL DEFAULT 'vigente',
  visibilidad   core.visibilidad_mensaje NOT NULL DEFAULT 'canal',
  autor_id      UUID NOT NULL REFERENCES core.usuario(id),
  retirado_at   TIMESTAMPTZ,
  retirado_por  UUID REFERENCES core.usuario(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT ck_adjunto_tamano CHECK (tamano_bytes IS NULL OR tamano_bytes >= 0)
);
CREATE INDEX IF NOT EXISTS ix_adjunto_entidad ON core.adjunto (entidad_tipo, entidad_id);
CREATE INDEX IF NOT EXISTS ix_adjunto_ot ON core.adjunto (ot_id, etapa) WHERE estado = 'vigente';

-- ── Motor de costos unitarios ────────────────────────────────────────────────
-- Cap. 32: no existen registros sin procedencia, el texto original es INMUTABLE
-- y la normalización nunca lo destruye.
CREATE TABLE IF NOT EXISTS core.descripcion_normalizada (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES core.tenant(id),
  etiqueta      VARCHAR(200) NOT NULL,
  version       INT NOT NULL DEFAULT 1,
  vigente       BOOLEAN NOT NULL DEFAULT true,
  tipo_trabajo_id UUID REFERENCES core.tipo_trabajo(id),
  aprobada_por  UUID REFERENCES core.usuario(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_descripcion_normalizada UNIQUE (tenant_id, etiqueta, version)
);

-- Sinónimos y equivalencias aprobadas (cap. 32.3). Nunca se fusionan conceptos
-- ambiguos de forma automática: baja confianza va a revisión.
CREATE TABLE IF NOT EXISTS core.regla_normalizacion (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      UUID NOT NULL REFERENCES core.tenant(id),
  patron         TEXT NOT NULL,
  descripcion_normalizada_id UUID NOT NULL REFERENCES core.descripcion_normalizada(id),
  confianza      NUMERIC(4,3) NOT NULL DEFAULT 1.0,
  aprobada       BOOLEAN NOT NULL DEFAULT false,
  aprobada_por   UUID REFERENCES core.usuario(id),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT ck_regla_confianza CHECK (confianza >= 0 AND confianza <= 1)
);

CREATE TABLE IF NOT EXISTS core.costo_unitario (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID NOT NULL REFERENCES core.tenant(id),
  ot_id               UUID NOT NULL REFERENCES core.orden_trabajo(id),
  cotizacion_id       UUID REFERENCES core.cotizacion(id),

  fuente              core.fuente_costo NOT NULL,   -- no hay registros sin procedencia (cap. 32.2)
  texto_original      TEXT NOT NULL,                -- INMUTABLE: exacto del PDF/formulario
  descripcion_normalizada_id UUID REFERENCES core.descripcion_normalizada(id),
  tipo_trabajo_id     UUID REFERENCES core.tipo_trabajo(id),
  concepto            core.concepto_costo,

  cantidad            NUMERIC(14,4),
  unidad              VARCHAR(30),
  monto_total         NUMERIC(14,2) NOT NULL,
  -- Sólo se calcula si la cantidad es positiva y la unidad es compatible; si no,
  -- se conserva el costo total y este campo queda NULL (cap. 32.2).
  costo_unitario      NUMERIC(14,4),
  moneda              core.moneda_codigo NOT NULL DEFAULT 'PEN',
  fecha_referencia    DATE,

  -- Contexto que explica las diferencias de precio (cap. 16.2)
  proveedor_id        UUID REFERENCES core.proveedor(id),
  sucursal_id         UUID REFERENCES core.sucursal(id),
  empresa_ruc_id      UUID REFERENCES core.empresa_ruc(id),
  area_id             UUID REFERENCES core.area(id),
  fue_emergencia      BOOLEAN NOT NULL DEFAULT false,
  ot_es_derivada      BOOLEAN NOT NULL DEFAULT false,

  -- Calidad: nunca se presenta un cotizado como contable (cap. 32.4)
  estado_validacion   core.estado_validacion_costo NOT NULL DEFAULT 'sin_validar',
  confianza           NUMERIC(4,3),
  es_outlier          BOOLEAN NOT NULL DEFAULT false,   -- se marca, NUNCA se borra (cap. 16.3)
  outlier_justificacion TEXT,
  es_comparable       BOOLEAN NOT NULL DEFAULT true,    -- alcance mixto/extraordinario => false (cap. 32.3)

  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by          UUID REFERENCES core.usuario(id),
  updated_by          UUID REFERENCES core.usuario(id),
  CONSTRAINT ck_costo_monto CHECK (monto_total >= 0),
  CONSTRAINT ck_costo_cantidad CHECK (cantidad IS NULL OR cantidad > 0),
  CONSTRAINT ck_costo_confianza CHECK (confianza IS NULL OR (confianza >= 0 AND confianza <= 1))
);
CREATE INDEX IF NOT EXISTS ix_costo_ot ON core.costo_unitario (ot_id);
CREATE INDEX IF NOT EXISTS ix_costo_busqueda ON core.costo_unitario
  (tenant_id, tipo_trabajo_id, empresa_ruc_id, fecha_referencia DESC) WHERE es_comparable = true;
CREATE INDEX IF NOT EXISTS ix_costo_texto_trgm ON core.costo_unitario USING gin (texto_original gin_trgm_ops);

-- ── Transversales ────────────────────────────────────────────────────────────

-- Notificación: correo es una COPIA de la interna, no la fuente de verdad, y un
-- fallo de entrega no revierte la operación de negocio (cap. 34.1).
CREATE TABLE IF NOT EXISTS core.notificacion (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      UUID NOT NULL REFERENCES core.tenant(id),
  destinatario_id UUID NOT NULL REFERENCES core.usuario(id),
  evento         VARCHAR(60) NOT NULL,
  titulo         VARCHAR(200) NOT NULL,
  cuerpo         TEXT,
  entidad_tipo   VARCHAR(40),
  entidad_id     UUID,
  ot_id          UUID REFERENCES core.orden_trabajo(id),
  canal          core.canal_notificacion NOT NULL DEFAULT 'interno',
  estado         core.estado_notificacion NOT NULL DEFAULT 'pendiente',
  leida_at       TIMESTAMPTZ,
  error_envio    TEXT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_notificacion_destinatario
  ON core.notificacion (destinatario_id, created_at DESC) WHERE leida_at IS NULL;

-- ══════════════════════════════════════════════════════════════════════════════
-- core.ot_evento — BITÁCORA APPEND-ONLY de todo lo que le pasa a una OT.
--
-- Es la evidencia de los cap. 18 y 33: un renglón por hecho relevante, con actor,
-- instante, valores anterior/nuevo y motivo. No admite UPDATE ni DELETE: esos
-- privilegios se revocan en 90_grants.sql y ningún SP los ejerce.
--
-- Se embebe en el árbol de trazabilidad como `eventos[]`.
-- ══════════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS core.ot_evento (
  id            BIGSERIAL PRIMARY KEY,
  tenant_id     UUID NOT NULL REFERENCES core.tenant(id),
  ot_id         UUID NOT NULL REFERENCES core.orden_trabajo(id),
  dominio       core.dominio_evento NOT NULL,
  evento        VARCHAR(60) NOT NULL,        -- 'estado_cambiado','diagnostico_reemplazado',…
  entidad_tipo  VARCHAR(40),
  entidad_id    UUID,
  valor_anterior JSONB,
  valor_nuevo   JSONB,
  motivo        TEXT,
  actor_id      UUID REFERENCES core.usuario(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_ot_evento_ot ON core.ot_evento (ot_id, created_at);
CREATE INDEX IF NOT EXISTS ix_ot_evento_dominio ON core.ot_evento (tenant_id, dominio, created_at DESC);

COMMENT ON TABLE core.ot_evento IS
  'Bitácora append-only e inmutable de la OT (cap. 18, 33). Sin UPDATE ni DELETE: los privilegios se revocan en 90_grants.sql.';

-- Auditoría técnica completa: consulta restringida, con diff campo a campo (cap. 18, 33).
CREATE TABLE IF NOT EXISTS audit.audit_log (
  id            BIGSERIAL PRIMARY KEY,
  tenant_id     UUID,
  actor_id      UUID,
  accion        VARCHAR(40) NOT NULL,
  entidad       VARCHAR(60) NOT NULL,
  entidad_id    UUID,
  valor_anterior JSONB,
  valor_nuevo   JSONB,
  diff          JSONB,
  motivo        TEXT,
  ip            INET,
  user_agent    TEXT,
  request_id    VARCHAR(60),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_audit_log_entidad ON audit.audit_log (entidad, entidad_id, created_at DESC);
CREATE INDEX IF NOT EXISTS ix_audit_log_tenant ON audit.audit_log (tenant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS ix_audit_log_actor ON audit.audit_log (actor_id, created_at DESC);
