-- =============================================================================
-- Deja la base con SÓLO su configuración: roles, permisos, catálogos, la
-- organización sembrada y el super admin. Borra todo lo transaccional y todo lo
-- que hayan dejado las pruebas.
--
-- Está pensado para dos momentos:
--   · después de pasar la suite, para no quedarse con 137 OT de mentira;
--   · antes de entregar un entorno, para partir de limpio.
--
-- NO se usa en producción con datos reales: ahí no se borra nada, ése es el
-- principio del producto. Por eso exige confirmación explícita.
-- =============================================================================
\set ON_ERROR_STOP on

DO $$
BEGIN
  IF coalesce(current_setting('mip.confirmo_borrado', true), '') <> 'si' THEN
    RAISE EXCEPTION E'Borrado no confirmado.\nEjecute con:  psql -v confirmo=si ... o SET mip.confirmo_borrado = ''si'';';
  END IF;
END $$;

BEGIN;

-- 1 · Todo lo transaccional. CASCADE resuelve el orden de las dependencias.
TRUNCATE
  core.orden_trabajo,
  core.solicitud_trabajo,
  core.solicitud_decision,
  core.diagnostico,
  core.cotizacion,
  core.ejecucion,
  core.ot_avance,
  core.ot_incidencia,
  core.ot_pausa,
  core.ot_cierre,
  core.ot_reapertura,
  core.ot_estado_historial,
  core.ot_evento,
  core.trabajo_realizado,
  core.seguimiento_administrativo,
  core.solped,
  core.orden_compra,
  core.liberacion_historial,
  core.conversacion,
  core.conversacion_participante,
  core.mensaje,
  core.adjunto,
  core.costo_unitario,
  core.notificacion,
  audit.audit_log
RESTART IDENTITY CASCADE;

-- 2 · Los correlativos vuelven a empezar: si no, la demo arrancaría en OT-000138.
DELETE FROM core.correlativo;

-- 3 · Todo lo que crearon las pruebas fuera del tenant sembrado.
DELETE FROM core.usuario_alcance WHERE usuario_id IN (
  SELECT id FROM core.usuario WHERE tenant_id <> (SELECT id FROM core.tenant WHERE codigo='demo'));
DELETE FROM core.usuario_rol WHERE usuario_id IN (
  SELECT id FROM core.usuario WHERE tenant_id <> (SELECT id FROM core.tenant WHERE codigo='demo'));
DELETE FROM core.usuario WHERE tenant_id <> (SELECT id FROM core.tenant WHERE codigo='demo');
DELETE FROM core.area          WHERE tenant_id <> (SELECT id FROM core.tenant WHERE codigo='demo');
DELETE FROM core.cecos         WHERE tenant_id <> (SELECT id FROM core.tenant WHERE codigo='demo');
DELETE FROM core.sucursal_empresa_ruc WHERE tenant_id <> (SELECT id FROM core.tenant WHERE codigo='demo');
DELETE FROM core.empresa_ruc   WHERE tenant_id <> (SELECT id FROM core.tenant WHERE codigo='demo');
DELETE FROM core.sucursal      WHERE tenant_id <> (SELECT id FROM core.tenant WHERE codigo='demo');
DELETE FROM core.tenant_configuracion WHERE tenant_id <> (SELECT id FROM core.tenant WHERE codigo='demo');
DELETE FROM core.rol           WHERE tenant_id IS NOT NULL
                                 AND tenant_id <> (SELECT id FROM core.tenant WHERE codigo='demo');
DELETE FROM core.tenant        WHERE codigo <> 'demo';

-- 4 · Dentro del tenant sembrado, lo que dejaron las pruebas. Se conserva el
--     super admin y la estructura de 89_seeds.sql.
DELETE FROM core.usuario_alcance WHERE usuario_id IN (
  SELECT id FROM core.usuario WHERE email <> 'admin@mip.local');
DELETE FROM core.usuario_rol WHERE usuario_id IN (
  SELECT id FROM core.usuario WHERE email <> 'admin@mip.local');
DELETE FROM core.usuario WHERE email <> 'admin@mip.local';

DELETE FROM core.area WHERE codigo NOT IN ('MANTTO','PROD','ALMAC');
DELETE FROM core.sucursal_empresa_ruc WHERE empresa_ruc_id IN (
  SELECT id FROM core.empresa_ruc WHERE ruc <> '20100000001');
DELETE FROM core.empresa_ruc WHERE ruc <> '20100000001';
DELETE FROM core.sucursal WHERE codigo <> 'PLANTA-01';

-- La empresa sembrada pudo quedar inactivada por la prueba QA-24.
UPDATE core.empresa_ruc SET estado = 'activo' WHERE ruc = '20100000001';
UPDATE core.usuario SET estado='activo', intentos_fallidos=0, bloqueado_hasta=NULL
 WHERE email = 'admin@mip.local';

COMMIT;

SELECT 'ot='            || (SELECT count(*) FROM core.orden_trabajo)
    || ' solicitudes='  || (SELECT count(*) FROM core.solicitud_trabajo)
    || ' usuarios='     || (SELECT count(*) FROM core.usuario)
    || ' tenants='      || (SELECT count(*) FROM core.tenant)
    || ' eventos='      || (SELECT count(*) FROM core.ot_evento)
    || ' auditoria='    || (SELECT count(*) FROM audit.audit_log) AS despues_de_limpiar;
