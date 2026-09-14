-- =============================================================================
-- 01_schemas.sql
--
-- Cuatro schemas con responsabilidades separadas. La regla de oro del proyecto:
-- el usuario PostgreSQL del backend (mip_app_user) sólo tiene EXECUTE en `app`.
-- No tiene SELECT ni sobre una sola tabla. Ver 90_grants.sql.
-- =============================================================================
CREATE SCHEMA IF NOT EXISTS core;       -- tablas, ENUMs y triggers
CREATE SCHEMA IF NOT EXISTS app;        -- SP y FN públicos: única superficie del backend
CREATE SCHEMA IF NOT EXISTS internal;   -- helpers privados (validaciones, cálculos, asserts)
CREATE SCHEMA IF NOT EXISTS audit;      -- auditoría dedicada

COMMENT ON SCHEMA core     IS 'Tablas, ENUMs y triggers. NUNCA accedido directamente por el backend.';
COMMENT ON SCHEMA app      IS 'Stored procedures y funciones públicas. Única superficie expuesta al backend.';
COMMENT ON SCHEMA internal IS 'Helpers privados SECURITY DEFINER. Sin EXECUTE para el rol de aplicación.';
COMMENT ON SCHEMA audit    IS 'Auditoría y bitácoras de retención larga.';
