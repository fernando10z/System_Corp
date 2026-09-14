-- =============================================================================
-- 37_app_dashboards.sql · Tableros y KPIs (cap. 20, 35)
--
-- El tablero del coordinador no es una pantalla de cifras: es una BANDEJA
-- ACCIONABLE (cap. 35.1). Cada bloque existe porque habilita una acción concreta,
-- y por eso cada uno devuelve las OT que la necesitan, no sólo el conteo.
-- =============================================================================
SET search_path = app, core, internal, public;

CREATE OR REPLACE FUNCTION app.fn_dashboard_coordinador(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v_global BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(

    -- Bloque 1 · Solicitudes pendientes de primera revisión, ordenadas por
    -- prioridad percibida y antigüedad. Acción: abrir, tomar, decidir o derivar.
    'solicitudes_nuevas', jsonb_build_object(
      'total', (SELECT count(*) FROM core.solicitud_trabajo s
                 WHERE s.tenant_id = p_tenant_id AND s.deleted_at IS NULL
                   AND s.estado IN ('enviada','en_revision')),
      'items', coalesce((SELECT jsonb_agg(jsonb_build_object(
                  'id', s.id, 'numero', s.numero, 'titulo', s.titulo,
                  'prioridad_percibida', s.prioridad_percibida,
                  'area', ar.nombre, 'estado', s.estado,
                  'horas_espera', round(extract(epoch FROM (now() - s.fecha_envio))/3600.0, 1))
                  ORDER BY s.prioridad_percibida NULLS LAST, s.fecha_envio)
                FROM core.solicitud_trabajo s LEFT JOIN core.area ar ON ar.id = s.area_id
               WHERE s.tenant_id = p_tenant_id AND s.deleted_at IS NULL
                 AND s.estado IN ('enviada','en_revision')), '[]'::jsonb)),

    -- Bloque 2 · OT sin diagnóstico vigente completo. Acción: completar o asignar técnico.
    'sin_diagnostico', jsonb_build_object(
      'total', (SELECT count(*) FROM core.orden_trabajo o
                 WHERE o.tenant_id = p_tenant_id AND o.deleted_at IS NULL
                   AND o.estado IN ('creada','en_diagnostico')
                   AND NOT EXISTS (SELECT 1 FROM core.diagnostico d WHERE d.ot_id=o.id AND d.vigente)),
      'items', coalesce((SELECT jsonb_agg(jsonb_build_object(
                  'id', o.id, 'numero_ot', o.numero_ot, 'estado', o.estado,
                  'prioridad', o.prioridad_tecnica, 'es_emergencia', o.es_emergencia,
                  'dias_abierta', round(extract(epoch FROM (now() - o.fecha_creacion))/86400.0, 1))
                  ORDER BY o.prioridad_tecnica NULLS LAST, o.fecha_creacion)
                FROM core.orden_trabajo o
               WHERE o.tenant_id = p_tenant_id AND o.deleted_at IS NULL
                 AND o.estado IN ('creada','en_diagnostico')
                 AND NOT EXISTS (SELECT 1 FROM core.diagnostico d WHERE d.ot_id=o.id AND d.vigente)), '[]'::jsonb)),

    -- Bloque 3 · En cotización sin PDF vigente, o con el plazo ofrecido vencido.
    'cotizacion_pendiente', jsonb_build_object(
      'total', (SELECT count(*) FROM core.orden_trabajo o
                 WHERE o.tenant_id = p_tenant_id AND o.deleted_at IS NULL
                   AND o.estado = 'en_cotizacion'
                   AND NOT EXISTS (SELECT 1 FROM core.cotizacion c
                                    WHERE c.ot_id=o.id AND c.vigente AND NOT c.invalidada)),
      'plazo_vencido', (SELECT count(*) FROM core.orden_trabajo o
                          JOIN core.cotizacion c ON c.ot_id = o.id AND c.vigente AND NOT c.invalidada
                         WHERE o.tenant_id = p_tenant_id AND o.estado = 'en_cotizacion'
                           AND c.plazo_ofrecido_dias IS NOT NULL
                           AND c.fecha_cotizacion + c.plazo_ofrecido_dias < current_date)),

    -- Bloque 4 · Ejecución: en trabajo, pausadas, sin avance reciente y emergencias.
    'ejecucion', jsonb_build_object(
      'en_trabajo', (SELECT count(*) FROM core.orden_trabajo
                      WHERE tenant_id=p_tenant_id AND deleted_at IS NULL AND estado='en_trabajo'),
      'pausadas',   (SELECT count(*) FROM core.orden_trabajo
                      WHERE tenant_id=p_tenant_id AND deleted_at IS NULL AND condicion='pausada'),
      'emergencias_activas', (SELECT count(*) FROM core.orden_trabajo
                               WHERE tenant_id=p_tenant_id AND deleted_at IS NULL
                                 AND es_emergencia AND estado NOT IN ('cerrada','cancelada')),
      'regularizacion_pendiente', (SELECT count(*) FROM core.orden_trabajo
                                    WHERE tenant_id=p_tenant_id AND deleted_at IS NULL
                                      AND regularizacion_pendiente AND estado NOT IN ('cancelada')),
      'sin_avance_7d', (SELECT count(*) FROM core.orden_trabajo o
                         WHERE o.tenant_id=p_tenant_id AND o.deleted_at IS NULL AND o.estado='en_trabajo'
                           AND NOT EXISTS (SELECT 1 FROM core.ot_avance a
                                            WHERE a.ot_id=o.id AND a.created_at > now() - interval '7 days'))),

    -- Bloque 5 · Trabajo realizado esperando revisión del coordinador.
    'revision_final', jsonb_build_object(
      'total', (SELECT count(*) FROM core.orden_trabajo
                 WHERE tenant_id=p_tenant_id AND deleted_at IS NULL AND estado='trabajo_realizado'),
      'items', coalesce((SELECT jsonb_agg(jsonb_build_object(
                  'id', o.id, 'numero_ot', o.numero_ot,
                  'declarado_at', t.created_at,
                  'declarado_por', u.nombres||' '||u.apellidos)
                  ORDER BY t.created_at)
                FROM core.orden_trabajo o
                JOIN core.trabajo_realizado t ON t.ot_id=o.id AND t.vigente
                LEFT JOIN core.usuario u ON u.id = t.declarado_por
               WHERE o.tenant_id=p_tenant_id AND o.deleted_at IS NULL
                 AND o.estado='trabajo_realizado'), '[]'::jsonb)),

    -- Bloque 6 · Cerradas con pendiente administrativo. Acción: registrar el
    -- seguimiento SIN reabrir la OT (cap. 35.1, QA-20).
    'administracion_pendiente', jsonb_build_object(
      'total', (SELECT count(*) FROM core.orden_trabajo
                 WHERE tenant_id=p_tenant_id AND deleted_at IS NULL AND estado='cerrada'
                   AND estado_administrativo <> 'administracion_completa'),
      'por_estado', coalesce((SELECT jsonb_object_agg(estado_administrativo, n) FROM (
                      SELECT estado_administrativo, count(*) AS n FROM core.orden_trabajo
                       WHERE tenant_id=p_tenant_id AND deleted_at IS NULL AND estado='cerrada'
                         AND estado_administrativo <> 'administracion_completa'
                       GROUP BY 1) z), '{}'::jsonb)),

    -- Bloque 7 · Jerarquías bloqueadas: padres que no pueden cerrar (cap. 27.3).
    'bloqueos_cierre', coalesce((SELECT jsonb_agg(jsonb_build_object(
        'id', o.id, 'numero_ot', o.numero_ot,
        'derivadas_bloqueantes', (SELECT count(*) FROM core.orden_trabajo h
                                   WHERE h.ot_padre_id=o.id AND h.deleted_at IS NULL
                                     AND h.es_bloqueante_para_padre
                                     AND h.estado NOT IN ('cerrada','cancelada'))))
      FROM core.orden_trabajo o
     WHERE o.tenant_id=p_tenant_id AND o.deleted_at IS NULL
       AND o.estado = 'trabajo_realizado'
       AND EXISTS (SELECT 1 FROM core.orden_trabajo h
                    WHERE h.ot_padre_id=o.id AND h.deleted_at IS NULL
                      AND h.es_bloqueante_para_padre
                      AND h.estado NOT IN ('cerrada','cancelada'))), '[]'::jsonb)
  ));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Tablero del solicitante: sus casos, sin costos ni datos internos (cap. 20.1, QA-18).
CREATE OR REPLACE FUNCTION app.fn_dashboard_solicitante(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'resumen', (SELECT jsonb_object_agg(estado, n) FROM (
                  SELECT estado::text, count(*) AS n FROM core.solicitud_trabajo
                   WHERE solicitante_id = p_user_id AND deleted_at IS NULL GROUP BY 1) z),
    'solicitudes', coalesce((SELECT jsonb_agg(jsonb_build_object(
        'id', s.id, 'numero', s.numero, 'titulo', s.titulo, 'estado', s.estado,
        'fecha', s.created_at, 'observacion', s.observacion_actual,
        'ot', (SELECT jsonb_build_object('numero', o.numero_ot, 'estado', o.estado)
                 FROM core.orden_trabajo o WHERE o.solicitud_origen_id = s.id))
        ORDER BY s.created_at DESC)
      FROM core.solicitud_trabajo s
     WHERE s.solicitante_id = p_user_id AND s.deleted_at IS NULL), '[]'::jsonb),
    'no_leidas', (SELECT count(*) FROM core.notificacion
                   WHERE destinatario_id = p_user_id AND leida_at IS NULL)));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- KPIs de gerencia (cap. 20.2, 35.2). Cada bloque lleva su definición para que
-- nadie tenga que adivinar cómo se calculó el número que está mirando.
--
-- Todo en UNA sentencia con CTE: una función STABLE no puede crear tablas
-- temporales, y así el conjunto de OT del periodo se evalúa una sola vez.
CREATE OR REPLACE FUNCTION app.fn_kpis(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_filtros JSONB DEFAULT '{}'::jsonb)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v_desde DATE := coalesce((p_filtros->>'desde')::date, current_date - 90);
  v_hasta DATE := coalesce((p_filtros->>'hasta')::date, current_date);
  v_suc   TEXT := p_filtros->>'sucursal_id';
  v_emp   TEXT := p_filtros->>'empresa_ruc_id';
  v_area  TEXT := p_filtros->>'area_id';
  v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'reportes:ver');

  WITH ot_periodo AS (
    SELECT o.* FROM core.orden_trabajo o
     WHERE o.tenant_id = p_tenant_id AND o.deleted_at IS NULL
       AND o.fecha_creacion::date BETWEEN v_desde AND v_hasta
       AND (v_suc  IS NULL OR o.sucursal_id = v_suc::uuid)
       AND (v_emp  IS NULL OR o.empresa_ruc_id = v_emp::uuid)
       AND (v_area IS NULL OR o.area_id = v_area::uuid)
  ),
  sol_periodo AS (
    SELECT s.* FROM core.solicitud_trabajo s
     WHERE s.tenant_id = p_tenant_id AND s.deleted_at IS NULL
       AND s.estado <> 'borrador'
       AND s.created_at::date BETWEEN v_desde AND v_hasta
  )
  SELECT jsonb_build_object(
    'periodo', jsonb_build_object('desde', v_desde, 'hasta', v_hasta),

    'solicitudes', (SELECT jsonb_build_object(
        'creadas',    count(*),
        'atendidas',  count(*) FILTER (WHERE estado = 'convertida_en_ot'),
        'observadas', count(*) FILTER (WHERE estado = 'observada'),
        'rechazadas', count(*) FILTER (WHERE estado = 'rechazada'),
        -- Tiempo de primera revisión = primera decisión − envío, sin borradores.
        'horas_primera_revision_promedio',
          round(avg(extract(epoch FROM (fecha_primera_revision - fecha_envio))/3600.0)
                FILTER (WHERE fecha_primera_revision IS NOT NULL)::numeric, 1))
      FROM sol_periodo),

    'ot', (SELECT jsonb_build_object(
        'total',      count(*),
        'abiertas',   count(*) FILTER (WHERE estado NOT IN ('cerrada','cancelada')),
        'cerradas',   count(*) FILTER (WHERE estado = 'cerrada'),
        'canceladas', count(*) FILTER (WHERE estado = 'cancelada'),
        'derivadas',  count(*) FILTER (WHERE ot_padre_id IS NOT NULL),
        'reabiertas', count(*) FILTER (WHERE veces_reabierta > 0),
        'por_estado', (SELECT coalesce(jsonb_object_agg(e, n), '{}'::jsonb) FROM (
                        SELECT estado::text e, count(*) n FROM ot_periodo GROUP BY 1) z),
        'por_prioridad', (SELECT coalesce(jsonb_object_agg(coalesce(pr,'sin_prioridad'), n), '{}'::jsonb) FROM (
                        SELECT prioridad_tecnica::text pr, count(*) n FROM ot_periodo GROUP BY 1) z))
      FROM ot_periodo),

    -- Duración = término real − inicio real, en días calendario. Las pausas se
    -- reportan por separado, nunca descontadas en silencio (cap. 35.2).
    'duracion', (SELECT jsonb_build_object(
        'dias_promedio', round(avg(extract(epoch FROM (o.fecha_termino_real - o.fecha_inicio_real))/86400.0)::numeric, 2),
        'casos', count(*),
        'horas_pausa_promedio', round(coalesce(avg((
            SELECT sum(extract(epoch FROM (pa.fecha_reanudacion - pa.fecha_pausa))/3600.0)
              FROM core.ot_pausa pa WHERE pa.ot_id = o.id AND pa.fecha_reanudacion IS NOT NULL)),0)::numeric, 1))
      FROM ot_periodo o
     WHERE o.fecha_inicio_real IS NOT NULL AND o.fecha_termino_real IS NOT NULL),

    'emergencias', (SELECT jsonb_build_object(
        'cantidad', count(*) FILTER (WHERE es_emergencia),
        'porcentaje', CASE WHEN count(*) = 0 THEN 0
                           ELSE round(100.0 * count(*) FILTER (WHERE es_emergencia) / count(*), 1) END,
        'regularizacion_pendiente', count(*) FILTER (WHERE regularizacion_pendiente))
      FROM ot_periodo),

    -- Cerrar con pendiente administrativo NO implica incumplimiento técnico
    -- (cap. 35.2). El KPI lo dice explícitamente para evitar malas lecturas.
    'cierre_con_pendiente', (SELECT jsonb_build_object(
        'total', count(*) FILTER (WHERE estado='cerrada' AND estado_administrativo <> 'administracion_completa'),
        'oc_pendiente', count(*) FILTER (WHERE estado='cerrada' AND estado_administrativo='oc_pendiente'),
        'liberacion_pendiente', count(*) FILTER (WHERE estado='cerrada' AND estado_administrativo='liberacion_pendiente'),
        'liberacion_parcial', count(*) FILTER (WHERE estado='cerrada' AND estado_administrativo='liberacion_parcial'),
        'nota','No implica incumplimiento técnico.')
      FROM ot_periodo),

    'costos', (SELECT jsonb_build_object(
        'ot_con_cotizacion', count(DISTINCT c.ot_id),
        'monto_cotizado_total', round(coalesce(sum(c.monto),0)::numeric, 2),
        'advertencia','Monto COTIZADO, no contable. Ver la regla de calidad del cap. 16.4.')
      FROM ot_periodo o
      JOIN core.cotizacion c ON c.ot_id = o.id AND c.vigente AND NOT c.invalidada)
  ) INTO v;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
