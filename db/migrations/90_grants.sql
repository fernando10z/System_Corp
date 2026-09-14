-- =============================================================================
-- 90_grants.sql · Superficie de acceso del backend
--
-- La regla de oro del proyecto: el usuario PostgreSQL del backend tiene EXECUTE
-- en el schema `app` y NADA MÁS. Ni un SELECT sobre una sola tabla.
--
-- Eso significa que toda la lógica de negocio, la validación de tenant, el
-- alcance organizacional y la auditoría ocurren dentro de la base, y que un
-- backend comprometido no puede leer datos de otro cliente ni saltarse una regla.
--
-- Además, core.ot_evento es append-only: se concede INSERT pero se revocan
-- UPDATE y DELETE incluso a nivel de tabla, además del trigger que ya los bloquea.
-- =============================================================================

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mip_app_user') THEN
    CREATE ROLE mip_app_user LOGIN PASSWORD 'cambiar_en_deploy';
  END IF;
END $$;

-- ── Cerrar todo lo que no es `app` ───────────────────────────────────────────
REVOKE ALL ON ALL TABLES    IN SCHEMA core     FROM mip_app_user;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA core     FROM mip_app_user;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA core     FROM mip_app_user;
REVOKE ALL ON SCHEMA core                      FROM mip_app_user;

REVOKE ALL ON ALL TABLES    IN SCHEMA audit    FROM mip_app_user;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA audit    FROM mip_app_user;
REVOKE ALL ON SCHEMA audit                     FROM mip_app_user;

REVOKE ALL ON ALL FUNCTIONS IN SCHEMA internal FROM mip_app_user;
REVOKE ALL ON SCHEMA internal                  FROM mip_app_user;

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT  USAGE ON SCHEMA public TO mip_app_user;

-- ── Abrir únicamente `app` ───────────────────────────────────────────────────
GRANT USAGE ON SCHEMA app TO mip_app_user;
GRANT EXECUTE ON ALL FUNCTIONS  IN SCHEMA app TO mip_app_user;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA app TO mip_app_user;

-- En ALTER DEFAULT PRIVILEGES, ROUTINES cubre funciones, procedimientos y
-- agregados; PROCEDURES sólo es válido en el GRANT directo de arriba.
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT EXECUTE ON ROUTINES TO mip_app_user;

-- ── Bitácora append-only, también a nivel de privilegios ────────────────────
-- El trigger trg_ot_evento_inmutable ya lo impide; esto lo hace explícito y
-- protege también contra un cambio futuro que quitara el trigger por descuido.
REVOKE UPDATE, DELETE, TRUNCATE ON core.ot_evento   FROM mip_app_user;
REVOKE UPDATE, DELETE, TRUNCATE ON audit.audit_log  FROM mip_app_user;

-- ── Comprobación ─────────────────────────────────────────────────────────────
-- Deja constancia en el log de que la superficie quedó como debe.
DO $$
DECLARE v_tablas INT; v_funciones INT;
BEGIN
  SELECT count(*) INTO v_tablas
    FROM information_schema.table_privileges
   WHERE grantee = 'mip_app_user' AND table_schema IN ('core','audit');

  SELECT count(*) INTO v_funciones
    FROM information_schema.routine_privileges
   WHERE grantee = 'mip_app_user' AND routine_schema = 'app';

  IF v_tablas > 0 THEN
    RAISE EXCEPTION 'mip_app_user conserva % privilegio(s) sobre tablas de core/audit. Revise 90_grants.sql', v_tablas
      USING ERRCODE = 'MIP04';
  END IF;

  RAISE NOTICE 'Superficie OK · % rutinas ejecutables en app, 0 privilegios sobre tablas', v_funciones;
END $$;
