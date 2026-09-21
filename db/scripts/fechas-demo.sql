-- =============================================================================
-- Reparte en el tiempo las fechas de un juego de datos de DEMOSTRACIÓN.
--
-- Al sembrar por la API todo nace con la marca de tiempo del momento, y la
-- demo queda con catorce OT creadas "hace 0 h". Esto desplaza cada OT y todo lo
-- que cuelga de ella por un mismo intervalo, así que el orden relativo de los
-- hechos se conserva exactamente: el diagnóstico sigue después de la solicitud
-- y antes de la cotización.
--
-- ⚠  SÓLO PARA DATOS DE DEMOSTRACIÓN.
--
-- Para tocar core.ot_evento hay que desactivar un instante el trigger que
-- garantiza que la bitácora es append-only (cap. 18.1). Ésa es una garantía
-- central del producto y no se debilita: el trigger se vuelve a activar dentro
-- de la MISMA transacción, de modo que si algo falla el ROLLBACK lo restituye y
-- la base nunca queda con la bitácora desprotegida. Nada de esto es alcanzable
-- desde la aplicación: exige ser owner de la base y confirmarlo a mano.
--
-- NO ejecutar contra datos reales: alteraría hechos auditados.
-- =============================================================================
\set ON_ERROR_STOP on

DO $$
BEGIN
  IF coalesce(current_setting('mip.confirmo_fechas_demo', true), '') <> 'si' THEN
    RAISE EXCEPTION E'Sin confirmar.\nEjecute antes:  SET mip.confirmo_fechas_demo = ''si'';';
  END IF;
END $$;

BEGIN;

-- La guarda de OT cerrada exige este permiso explícito de sesión (cap. 21.3).
SET LOCAL mip.permitir_update_cerrada = 'on';
ALTER TABLE core.ot_evento DISABLE TRIGGER trg_ot_evento_inmutable;

-- Un desplazamiento por OT: las cerradas hacia atrás, las abiertas más cerca de
-- hoy. Determinista a partir del número de OT, para que dos ejecuciones den el
-- mismo resultado.
CREATE TEMP TABLE desplazamiento ON COMMIT DROP AS
SELECT o.id AS ot_id,
       o.solicitud_origen_id,
       make_interval(days => CASE
         WHEN o.estado IN ('cerrada','cancelada') THEN 34 + (right(o.numero_ot,3)::int % 38)
         WHEN o.estado IN ('trabajo_realizado','en_trabajo') THEN 9 + (right(o.numero_ot,3)::int % 16)
         ELSE 1 + (right(o.numero_ot,3)::int % 8) END,
         hours => (right(o.numero_ot,3)::int * 7) % 11) AS atras
  FROM core.orden_trabajo o;

UPDATE core.orden_trabajo t SET
  fecha_creacion = t.fecha_creacion - d.atras,
  created_at = t.created_at - d.atras,
  updated_at = t.updated_at - d.atras,
  fecha_inicio_real = t.fecha_inicio_real - d.atras,
  fecha_termino_real = t.fecha_termino_real - d.atras,
  fecha_cierre = t.fecha_cierre - d.atras,
  fecha_cancelacion = t.fecha_cancelacion - d.atras,
  emergencia_declarada_at = t.emergencia_declarada_at - d.atras,
  trazabilidad_dirty = true
FROM desplazamiento d WHERE t.id = d.ot_id;

UPDATE core.solicitud_trabajo s SET
  fecha_envio = s.fecha_envio - d.atras,
  fecha_primera_revision = s.fecha_primera_revision - d.atras,
  created_at = s.created_at - d.atras,
  updated_at = s.updated_at - d.atras
FROM desplazamiento d WHERE s.id = d.solicitud_origen_id;

UPDATE core.solicitud_decision x SET created_at = x.created_at - d.atras
FROM desplazamiento d WHERE x.solicitud_id = d.solicitud_origen_id;

UPDATE core.diagnostico x SET created_at = x.created_at - d.atras, updated_at = x.updated_at - d.atras,
       aprobado_at = x.aprobado_at - d.atras FROM desplazamiento d WHERE x.ot_id = d.ot_id;

UPDATE core.cotizacion x SET created_at = x.created_at - d.atras, updated_at = x.updated_at - d.atras,
       fecha_cotizacion = x.fecha_cotizacion - (extract(day FROM d.atras)::int)
FROM desplazamiento d WHERE x.ot_id = d.ot_id;

UPDATE core.ejecucion x SET created_at = x.created_at - d.atras, updated_at = x.updated_at - d.atras,
       inicio_real = x.inicio_real - d.atras, termino_real = x.termino_real - d.atras
FROM desplazamiento d WHERE x.ot_id = d.ot_id;

UPDATE core.ot_avance x SET created_at = x.created_at - d.atras FROM desplazamiento d WHERE x.ot_id = d.ot_id;
UPDATE core.ot_incidencia x SET created_at = x.created_at - d.atras, updated_at = x.updated_at - d.atras,
       resuelta_at = x.resuelta_at - d.atras FROM desplazamiento d WHERE x.ot_id = d.ot_id;
UPDATE core.ot_pausa x SET created_at = x.created_at - d.atras, updated_at = x.updated_at - d.atras,
       fecha_pausa = x.fecha_pausa - d.atras, fecha_reanudacion = x.fecha_reanudacion - d.atras
FROM desplazamiento d WHERE x.ot_id = d.ot_id;

UPDATE core.trabajo_realizado x SET created_at = x.created_at - d.atras, updated_at = x.updated_at - d.atras,
       fecha_termino = x.fecha_termino - d.atras, revisado_at = x.revisado_at - d.atras,
       conformidad_at = x.conformidad_at - d.atras FROM desplazamiento d WHERE x.ot_id = d.ot_id;

UPDATE core.ot_cierre x SET created_at = x.created_at - d.atras, fecha_cierre = x.fecha_cierre - d.atras
FROM desplazamiento d WHERE x.ot_id = d.ot_id;
UPDATE core.ot_reapertura x SET created_at = x.created_at - d.atras FROM desplazamiento d WHERE x.ot_id = d.ot_id;
UPDATE core.ot_estado_historial x SET created_at = x.created_at - d.atras FROM desplazamiento d WHERE x.ot_id = d.ot_id;
UPDATE core.ot_evento x SET created_at = x.created_at - d.atras FROM desplazamiento d WHERE x.ot_id = d.ot_id;

UPDATE core.solped x SET created_at = x.created_at - d.atras, updated_at = x.updated_at - d.atras,
       fecha_solped = x.fecha_solped - d.atras, ultimo_intento_at = x.ultimo_intento_at - d.atras,
       anulada_at = x.anulada_at - d.atras FROM desplazamiento d WHERE x.ot_id = d.ot_id;
UPDATE core.orden_compra x SET created_at = x.created_at - d.atras, updated_at = x.updated_at - d.atras,
       fecha_oc = x.fecha_oc - (extract(day FROM d.atras)::int) FROM desplazamiento d WHERE x.ot_id = d.ot_id;
UPDATE core.liberacion_historial x SET created_at = x.created_at - d.atras FROM desplazamiento d WHERE x.ot_id = d.ot_id;

UPDATE core.costo_unitario x SET created_at = x.created_at - d.atras, updated_at = x.updated_at - d.atras,
       fecha_referencia = x.fecha_referencia - (extract(day FROM d.atras)::int)
FROM desplazamiento d WHERE x.ot_id = d.ot_id;

UPDATE core.conversacion x SET created_at = x.created_at - d.atras, updated_at = x.updated_at - d.atras
FROM desplazamiento d WHERE x.ot_id = d.ot_id;
UPDATE core.mensaje m SET created_at = m.created_at - d.atras, updated_at = m.updated_at - d.atras,
       editado_at = m.editado_at - d.atras, retirado_at = m.retirado_at - d.atras
FROM core.conversacion c JOIN desplazamiento d ON d.ot_id = c.ot_id WHERE m.conversacion_id = c.id;

UPDATE core.notificacion n SET created_at = n.created_at - d.atras, updated_at = n.updated_at - d.atras
FROM desplazamiento d WHERE n.ot_id = d.ot_id;

UPDATE audit.audit_log a SET created_at = a.created_at - d.atras
FROM desplazamiento d WHERE a.entidad_id = d.ot_id;

-- La bitácora vuelve a ser intocable antes de confirmar.
ALTER TABLE core.ot_evento ENABLE TRIGGER trg_ot_evento_inmutable;

COMMIT;

-- El árbol cacheado guarda las fechas viejas: queda marcado sucio arriba y el
-- motor lo reconstruye solo la próxima vez que se abra cada OT.
SELECT 'OT repartidas en el tiempo: ' || count(*) ||
       ' · la más antigua hace ' || max(date_part('day', now() - fecha_creacion))::int || ' días' ||
       ' · la más reciente hace ' || min(date_part('day', now() - fecha_creacion))::int || ' días'
  FROM core.orden_trabajo;
