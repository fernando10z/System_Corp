-- =============================================================================
-- smoke-verificar.sql
--
-- Se ejecuta después de smoke-trazabilidad.sql y comprueba que el árbol contiene
-- realmente TODO lo que la OT generó, y que el snapshot cacheado coincide con la
-- función autoritativa.
-- =============================================================================
\set ON_ERROR_STOP on
SET search_path = app, core, internal, public;

\echo ''
\echo '════ Contenido del árbol de trazabilidad de OT-000001 ════'
SELECT jsonb_pretty(jsonb_build_object(
  'ot',                      trazabilidad->'ot'->>'numero',
  'estado',                  trazabilidad->'ot'->>'estado',
  'estado_administrativo',   trazabilidad->'ot'->>'estado_administrativo',
  'veces_reabierta',        (trazabilidad->'ot'->>'veces_reabierta')::int,
  'solicitud_origen',        trazabilidad->'origen'->'solicitud'->>'numero',
  'diagnosticos',            jsonb_array_length(trazabilidad->'diagnosticos'),
  'diagnostico_vigente_v',  (SELECT d->>'version' FROM jsonb_array_elements(trazabilidad->'diagnosticos') d
                              WHERE (d->>'vigente')::boolean),
  'cotizaciones',            jsonb_array_length(trazabilidad->'cotizaciones'),
  'cotizacion_vigente_monto',(SELECT c->>'monto' FROM jsonb_array_elements(trazabilidad->'cotizaciones') c
                              WHERE (c->>'vigente')::boolean),
  'avances',                 jsonb_array_length(trazabilidad->'ejecucion'->'avances'),
  'incidencias',             jsonb_array_length(trazabilidad->'ejecucion'->'incidencias'),
  'pausas',                  jsonb_array_length(trazabilidad->'ejecucion'->'pausas'),
  'trabajos_realizados',     jsonb_array_length(trazabilidad->'cierre'->'trabajo_realizado'),
  'cierres',                 jsonb_array_length(trazabilidad->'cierre'->'cierres'),
  'reaperturas',             jsonb_array_length(trazabilidad->'cierre'->'reaperturas'),
  'solped',                  jsonb_array_length(trazabilidad->'administrativo'->'solped'),
  'solped_sap',              trazabilidad->'administrativo'->'solped'->0->>'numero_sap',
  'ordenes_compra',          jsonb_array_length(trazabilidad->'administrativo'->'oc'),
  'liberaciones',            jsonb_array_length(trazabilidad->'administrativo'->'liberaciones'),
  'derivadas_directas',      jsonb_array_length(trazabilidad->'derivadas'),
  'nieta',                   trazabilidad->'derivadas'->0->'derivadas'->0->'ot'->>'numero',
  'mensajes',                jsonb_array_length(trazabilidad->'conversacion'->'mensajes'),
  'costos',                  jsonb_array_length(trazabilidad->'costos'->'registros'),
  'eventos',                 jsonb_array_length(trazabilidad->'eventos'),
  'total_nodos',             trazabilidad->'_meta'->>'total_nodos',
  'profundidad',             trazabilidad->'_meta'->>'profundidad_arbol'
))
FROM core.orden_trabajo WHERE numero_ot = 'OT-000001';

\echo ''
\echo '════ Integridad: snapshot cacheado vs. función autoritativa ════'
-- Primero se vacía la cola de pendientes, igual que hace el camino de lectura
-- perezoso. Cerrar la OT padre deja marcadas a sus hijas, porque el árbol de una
-- derivada embebe el estado de su padre.
SELECT app.sp_trazabilidad_refrescar_pendientes() AS refresco_previo;
SELECT numero_ot,
       trazabilidad_version AS version,
       NOT trazabilidad_dirty AS al_dia,
       -- Se compara contra la MISMA forma con la que se guarda el snapshot:
       -- profundidad 10 y resumido = false. Se descarta _meta porque lleva el
       -- instante de generación.
       (trazabilidad - '_meta') IS NOT DISTINCT FROM
       (internal.fn_ot_trazabilidad(id, 10, false) - '_meta') AS coincide
  FROM core.orden_trabajo
 ORDER BY numero_ot;

\echo ''
\echo '════ La historia se conserva: nada se sobrescribió ════'
SELECT 'diagnósticos conservados'      AS comprobacion, count(*) AS n FROM core.diagnostico
UNION ALL SELECT 'cotizaciones conservadas',   count(*) FROM core.cotizacion
UNION ALL SELECT 'cierres conservados',        count(*) FROM core.ot_cierre
UNION ALL SELECT 'reaperturas',                count(*) FROM core.ot_reapertura
UNION ALL SELECT 'eventos en la bitácora',     count(*) FROM core.ot_evento
UNION ALL SELECT 'entradas de auditoría',      count(*) FROM audit.audit_log
UNION ALL SELECT 'notificaciones generadas',   count(*) FROM core.notificacion
UNION ALL SELECT 'OT eliminadas físicamente',  count(*) FROM core.orden_trabajo WHERE deleted_at IS NOT NULL;
