-- =============================================================================
-- 03_tables_organizacion.sql
--
-- Estructura organizacional, identidad y catálogos configurables.
--
-- La jerarquía funcional del cap. 5 es Tenant -> Sucursal -> Empresa/RUC -> Area.
-- Dos reglas que el modelo tiene que hacer cumplir, no sugerir:
--   · Una sucursal puede contener varias empresas/RUC (relación N a N).
--   · Un área pertenece EXCLUSIVAMENTE a una empresa/RUC. El mismo nombre de área
--     bajo otra razón social es una entidad distinta, no la misma.
--
-- Todo lleva tenant_id porque el cap. 21.3 lo pone como restricción de integridad
-- dura: "Todo registro relevante debe contener tenant_id; nunca se mezclan datos
-- de clientes".
-- =============================================================================
SET search_path = core, internal, public;

-- ── Tenant ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS core.tenant (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo             VARCHAR(30)  NOT NULL,
  nombre             VARCHAR(150) NOT NULL,
  zona_horaria       VARCHAR(60)  NOT NULL DEFAULT 'America/Lima',  -- regla 23.1: toda fecha se muestra en la zona del tenant
  moneda_base        core.moneda_codigo NOT NULL DEFAULT 'PEN',
  estado             core.estado_registro NOT NULL DEFAULT 'activo',
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at         TIMESTAMPTZ,
  created_by         UUID,
  updated_by         UUID,
  CONSTRAINT uq_tenant_codigo UNIQUE (codigo)
);

-- ── Sucursal ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS core.sucursal (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    UUID NOT NULL REFERENCES core.tenant(id),
  codigo       VARCHAR(30)  NOT NULL,
  nombre       VARCHAR(150) NOT NULL,
  direccion    TEXT,
  estado       core.estado_registro NOT NULL DEFAULT 'activo',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at   TIMESTAMPTZ,
  created_by   UUID,
  updated_by   UUID,
  CONSTRAINT uq_sucursal_codigo UNIQUE (tenant_id, codigo)
);
CREATE INDEX IF NOT EXISTS ix_sucursal_tenant ON core.sucursal (tenant_id) WHERE deleted_at IS NULL;

-- ── Empresa / RUC ────────────────────────────────────────────────────────────
-- Entidad jurídica a la que se imputa la OT y, después, la SOLPED (cap. 5).
CREATE TABLE IF NOT EXISTS core.empresa_ruc (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES core.tenant(id),
  ruc           VARCHAR(20)  NOT NULL,
  razon_social  VARCHAR(200) NOT NULL,
  nombre_corto  VARCHAR(80),
  estado        core.estado_registro NOT NULL DEFAULT 'activo',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ,
  created_by    UUID,
  updated_by    UUID,
  CONSTRAINT uq_empresa_ruc_ruc UNIQUE (tenant_id, ruc)
);
CREATE INDEX IF NOT EXISTS ix_empresa_ruc_tenant ON core.empresa_ruc (tenant_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS ix_empresa_ruc_razon_trgm ON core.empresa_ruc USING gin (razon_social gin_trgm_ops);

-- Una sucursal puede asociarse a varias empresas/RUC y viceversa (cap. 5).
CREATE TABLE IF NOT EXISTS core.sucursal_empresa_ruc (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      UUID NOT NULL REFERENCES core.tenant(id),
  sucursal_id    UUID NOT NULL REFERENCES core.sucursal(id),
  empresa_ruc_id UUID NOT NULL REFERENCES core.empresa_ruc(id),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_sucursal_empresa_ruc UNIQUE (sucursal_id, empresa_ruc_id)
);

-- ── Área ─────────────────────────────────────────────────────────────────────
-- Pertenece a UNA sola empresa/RUC. El nombre puede repetirse bajo otra RUC.
CREATE TABLE IF NOT EXISTS core.area (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      UUID NOT NULL REFERENCES core.tenant(id),
  empresa_ruc_id UUID NOT NULL REFERENCES core.empresa_ruc(id),
  codigo         VARCHAR(30)  NOT NULL,
  nombre         VARCHAR(150) NOT NULL,
  estado         core.estado_registro NOT NULL DEFAULT 'activo',
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at     TIMESTAMPTZ,
  created_by     UUID,
  updated_by     UUID,
  -- El código es único DENTRO de la RUC, no dentro del tenant: eso es lo que
  -- permite "Mantenimiento" bajo dos razones sociales como entidades distintas.
  CONSTRAINT uq_area_codigo UNIQUE (empresa_ruc_id, codigo)
);
CREATE INDEX IF NOT EXISTS ix_area_empresa_ruc ON core.area (empresa_ruc_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS ix_area_tenant ON core.area (tenant_id) WHERE deleted_at IS NULL;

-- ── CECOS ────────────────────────────────────────────────────────────────────
-- Dato administrativo asociado a una RUC. Su detalle SAP queda pendiente (cap. 5, 38).
CREATE TABLE IF NOT EXISTS core.cecos (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      UUID NOT NULL REFERENCES core.tenant(id),
  empresa_ruc_id UUID NOT NULL REFERENCES core.empresa_ruc(id),
  area_id        UUID REFERENCES core.area(id),
  codigo         VARCHAR(40)  NOT NULL,
  descripcion    VARCHAR(200) NOT NULL,
  estado         core.estado_registro NOT NULL DEFAULT 'activo',
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at     TIMESTAMPTZ,
  created_by     UUID,
  updated_by     UUID,
  CONSTRAINT uq_cecos_codigo UNIQUE (empresa_ruc_id, codigo)
);

-- ── Roles y permisos ─────────────────────────────────────────────────────────
-- Roles de negocio del cap. 4 + permisos configurables. La matriz base es el Anexo B.
CREATE TABLE IF NOT EXISTS core.rol (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   UUID REFERENCES core.tenant(id),   -- NULL = rol de sistema, compartido
  codigo      VARCHAR(40)  NOT NULL,
  nombre      VARCHAR(100) NOT NULL,
  descripcion TEXT,
  scope       core.scope_rol NOT NULL DEFAULT 'tenant',
  es_sistema  BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ,
  -- NULLS NOT DISTINCT es imprescindible: los roles base llevan tenant_id NULL y,
  -- con la semántica por defecto, dos NULL se consideran distintos y el
  -- ON CONFLICT de las semillas nunca dispararía (duplicando en cada corrida).
  CONSTRAINT uq_rol_codigo UNIQUE NULLS NOT DISTINCT (tenant_id, codigo)
);

CREATE TABLE IF NOT EXISTS core.permiso (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo      VARCHAR(80)  NOT NULL,   -- formato modulo:accion, p.ej. 'ot:cerrar'
  modulo      VARCHAR(40)  NOT NULL,
  accion      VARCHAR(40)  NOT NULL,
  descripcion TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_permiso_codigo UNIQUE (codigo)
);

CREATE TABLE IF NOT EXISTS core.rol_permiso (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rol_id     UUID NOT NULL REFERENCES core.rol(id),
  permiso_id UUID NOT NULL REFERENCES core.permiso(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_rol_permiso UNIQUE (rol_id, permiso_id)
);

-- ── Usuario ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS core.usuario (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id        UUID REFERENCES core.tenant(id),   -- NULL sólo para el super admin de plataforma
  email            VARCHAR(180) NOT NULL,
  password_hash    TEXT,
  nombres          VARCHAR(100) NOT NULL,
  apellidos        VARCHAR(100) NOT NULL,
  documento        VARCHAR(20),
  telefono         VARCHAR(30),
  cargo            VARCHAR(100),
  estado           core.estado_usuario NOT NULL DEFAULT 'activo',
  is_super_admin   BOOLEAN NOT NULL DEFAULT false,
  ultimo_acceso_at TIMESTAMPTZ,
  preferencias     JSONB NOT NULL DEFAULT '{}'::jsonb,  -- preferencias de notificación (cap. 34.1)
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at       TIMESTAMPTZ,
  created_by       UUID,
  updated_by       UUID,
  CONSTRAINT uq_usuario_email UNIQUE (email)
);
CREATE INDEX IF NOT EXISTS ix_usuario_tenant ON core.usuario (tenant_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS ix_usuario_email_lower ON core.usuario (lower(email));

-- Un usuario puede tener varios roles si el cliente lo autoriza (cap. 4, relación N a N).
CREATE TABLE IF NOT EXISTS core.usuario_rol (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES core.usuario(id),
  rol_id     UUID NOT NULL REFERENCES core.rol(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID,
  CONSTRAINT uq_usuario_rol UNIQUE (usuario_id, rol_id)
);

-- ── Alcance organizacional ───────────────────────────────────────────────────
-- Cap. 4.1: los permisos se aplican JUNTO CON el alcance asignado. Un usuario sólo
-- consulta o modifica dentro de su alcance, salvo permisos administrativos globales.
-- Una fila con sucursal_id/empresa_ruc_id/area_id en NULL significa "todo ese nivel".
CREATE TABLE IF NOT EXISTS core.usuario_alcance (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      UUID NOT NULL REFERENCES core.tenant(id),
  usuario_id     UUID NOT NULL REFERENCES core.usuario(id),
  sucursal_id    UUID REFERENCES core.sucursal(id),
  empresa_ruc_id UUID REFERENCES core.empresa_ruc(id),
  area_id        UUID REFERENCES core.area(id),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by     UUID
);
CREATE INDEX IF NOT EXISTS ix_usuario_alcance_usuario ON core.usuario_alcance (usuario_id);

-- ── Catálogos configurables por tenant ───────────────────────────────────────
-- Cap. 17: catálogos, motivos y parámetros varían por cliente; el flujo base no.
CREATE TABLE IF NOT EXISTS core.catalogo_item (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   UUID REFERENCES core.tenant(id),   -- NULL = ítem base, heredado por todos
  tipo        core.tipo_catalogo NOT NULL,
  codigo      VARCHAR(60)  NOT NULL,
  nombre      VARCHAR(150) NOT NULL,
  descripcion TEXT,
  orden       INT NOT NULL DEFAULT 0,
  requiere_comentario BOOLEAN NOT NULL DEFAULT false,  -- el ítem 'Otro' exige texto libre (cap. 24.3)
  estado      core.estado_registro NOT NULL DEFAULT 'activo',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ,
  created_by  UUID,
  updated_by  UUID,
  -- Ídem: los ítems base llevan tenant_id NULL (ver nota en core.rol).
  CONSTRAINT uq_catalogo_item UNIQUE NULLS NOT DISTINCT (tenant_id, tipo, codigo)
);
CREATE INDEX IF NOT EXISTS ix_catalogo_item_tipo ON core.catalogo_item (tipo, tenant_id) WHERE deleted_at IS NULL;

-- ── Tipo de trabajo ──────────────────────────────────────────────────────────
-- Es la agrupación PRINCIPAL del motor de costos (cap. 16.2), así que merece tabla
-- propia y no una fila de catalogo_item: lleva jerarquía y gobierno de sinónimos.
CREATE TABLE IF NOT EXISTS core.tipo_trabajo (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   UUID REFERENCES core.tenant(id),   -- NULL = catálogo base ampliable (filosofía B, cap. 16.2)
  codigo      VARCHAR(60)  NOT NULL,
  nombre      VARCHAR(150) NOT NULL,
  padre_id    UUID REFERENCES core.tipo_trabajo(id),
  descripcion TEXT,
  es_base     BOOLEAN NOT NULL DEFAULT false,
  estado      core.estado_registro NOT NULL DEFAULT 'activo',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ,
  created_by  UUID,
  updated_by  UUID,
  -- Ídem: el catálogo base de tipos de trabajo lleva tenant_id NULL.
  CONSTRAINT uq_tipo_trabajo_codigo UNIQUE NULLS NOT DISTINCT (tenant_id, codigo)
);

-- ── Proveedor ────────────────────────────────────────────────────────────────
-- MIP no compara ni puntúa proveedores (cap. 11). Sólo los identifica para poder
-- ver recurrencia y costo histórico (cap. 16.2).
CREATE TABLE IF NOT EXISTS core.proveedor (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    UUID NOT NULL REFERENCES core.tenant(id),
  ruc          VARCHAR(20),
  razon_social VARCHAR(200) NOT NULL,
  contacto     VARCHAR(150),
  telefono     VARCHAR(30),
  email        VARCHAR(180),
  estado       core.estado_registro NOT NULL DEFAULT 'activo',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at   TIMESTAMPTZ,
  created_by   UUID,
  updated_by   UUID,
  CONSTRAINT uq_proveedor_ruc UNIQUE (tenant_id, ruc)
);
CREATE INDEX IF NOT EXISTS ix_proveedor_razon_trgm ON core.proveedor USING gin (razon_social gin_trgm_ops);

-- ── Configuración por tenant ─────────────────────────────────────────────────
-- Cap. 17: todo lo que cambia entre clientes se configura sin bifurcar el flujo.
CREATE TABLE IF NOT EXISTS core.tenant_configuracion (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   UUID NOT NULL REFERENCES core.tenant(id),
  clave       VARCHAR(80) NOT NULL,
  valor       JSONB NOT NULL,
  descripcion TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_by  UUID,
  CONSTRAINT uq_tenant_configuracion UNIQUE (tenant_id, clave)
);

-- ── Correlativos ─────────────────────────────────────────────────────────────
-- El número de OT es único dentro del tenant y NO se reutiliza (cap. 25.1).
CREATE TABLE IF NOT EXISTS core.correlativo (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      UUID NOT NULL REFERENCES core.tenant(id),
  tipo_documento VARCHAR(20) NOT NULL,   -- 'OT', 'ST', 'SOLPED'
  prefijo        VARCHAR(10) NOT NULL,
  ultimo_numero  INT NOT NULL DEFAULT 0,
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_correlativo UNIQUE (tenant_id, tipo_documento)
);

-- ── Bloqueo por intentos fallidos (OWASP A07) ────────────────────────────────
-- El límite por IP no basta: desde una botnet cada petición llega de una IP
-- distinta. El contador vive junto a la cuenta, que es lo que de verdad se
-- quiere proteger. Se añade con ADD COLUMN IF NOT EXISTS para no romper la
-- idempotencia del archivo.
ALTER TABLE core.usuario ADD COLUMN IF NOT EXISTS intentos_fallidos INT NOT NULL DEFAULT 0;
ALTER TABLE core.usuario ADD COLUMN IF NOT EXISTS bloqueado_hasta TIMESTAMPTZ;
ALTER TABLE core.usuario ADD COLUMN IF NOT EXISTS ultimo_intento_fallido_at TIMESTAMPTZ;
