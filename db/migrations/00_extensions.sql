-- =============================================================================
-- 00_extensions.sql
--
-- Extensiones que MIP da por sentadas en el resto de migraciones.
--   pgcrypto    · gen_random_uuid() para todas las PK.
--   pg_trgm     · búsqueda difusa en títulos de solicitud/OT y razones sociales.
--   unaccent    · normalización de descripciones para el motor de costos (cap. 32.3).
--   btree_gin   · índices mixtos (tenant_id + jsonb) sobre la trazabilidad.
-- =============================================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS btree_gin;
