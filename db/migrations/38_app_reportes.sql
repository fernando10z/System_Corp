-- =============================================================================
-- 38_app_reportes.sql · Reportes con filtros y exportación (cap. 20.3)
--
-- Los reportes filtran al menos por periodo, sucursal, empresa/RUC, área, estado,
-- prioridad, emergencia, responsable y tipo de trabajo, y RESPETAN el alcance y
-- los permisos del usuario que consulta.
-- =============================================================================
SET search_path = app, core, internal, public;

CREATE OR REPLACE FUNCTION app.fn_reporte_ot(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_filtros JSONB DEFAULT '{}'::jsonb, p_limite INT DEFAULT 5000)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v JSONB; v_global BOOLEAN; v_ve_costos BOOLEAN;
  v_desde TEXT := p_filtros->>'desde';       v_hasta TEXT := p_filtros->>'hasta';
  v_suc   TEXT := p_filtros->>'sucursal_id'; v_emp   TEXT := p_filtros->>'empresa_ruc_id';
  v_area  TEXT := p_filtros->>'area_id';     v_estado TEXT := p_filtros->>'estado';
  v_prio  TEXT := p_filtros->>'prioridad_tecnica';
  v_tipo  TEXT := p_filtros->>'tipo_trabajo_id';
  v_resp  TEXT := p_filtros->>'responsable_id';
  v_emerg BOOLEAN := (p_filtros->>'emergencia')::boolean;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'reportes:ver');
  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  v_ve_costos := p_is_super_admin OR EXISTS (
    SELECT 1 FROM core.usuario_rol ur JOIN core.rol_permiso rp ON rp.rol_id=ur.rol_id
      JOIN core.permiso p ON p.id=rp.permiso_id
     WHERE ur.usuario_id=p_user_id AND p.codigo='costos:ver');

  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'numero_ot', o.numero_ot,
    'estado', o.estado, 'estado_administrativo', o.estado_administrativo,
    'titulo', coalesce(s.titulo, o.motivo_derivacion_texto),
    'solicitud', s.numero,
    'ot_padre', pa.numero_ot,
    'nivel', o.nivel,
    'sucursal', su.nombre, 'empresa_ruc', er.razon_social, 'ruc', er.ruc,
    'area', ar.nombre, 'cecos', ce.codigo,
    'tipo_mantenimiento', tm.nombre, 'tipo_trabajo', tt.nombre,
    'prioridad_tecnica', o.prioridad_tecnica,
    'prioridad_percibida', s.prioridad_percibida,
    'es_emergencia', o.es_emergencia,
    'coordinador', co.nombres||' '||co.apellidos,
    'ejecutor', ej.nombres||' '||ej.apellidos,
    'fecha_creacion', o.fecha_creacion, 'fecha_inicio', o.fecha_inicio_real,
    'fecha_termino', o.fecha_termino_real, 'fecha_cierre', o.fecha_cierre,
    'duracion_dias', CASE WHEN o.fecha_inicio_real IS NOT NULL AND o.fecha_termino_real IS NOT NULL
                          THEN round(extract(epoch FROM (o.fecha_termino_real-o.fecha_inicio_real))/86400.0,2) END,
    'veces_reabierta', o.veces_reabierta,
    'proveedor', CASE WHEN v_ve_costos THEN coalesce(pr.razon_social, c.proveedor_nombre) END,
    'monto_cotizado', CASE WHEN v_ve_costos THEN c.monto END,
    'moneda', CASE WHEN v_ve_costos THEN c.moneda END,
    'solped_sap', CASE WHEN v_ve_costos THEN sp.numero_sap END,
    'oc', CASE WHEN v_ve_costos THEN oc.numero_oc END,
    'monto_liberado', CASE WHEN v_ve_costos THEN sa.monto_liberado_total END
  ) ORDER BY o.fecha_creacion DESC), '[]'::jsonb) INTO v
  FROM core.orden_trabajo o
  LEFT JOIN core.solicitud_trabajo s ON s.id = o.solicitud_origen_id
  LEFT JOIN core.orden_trabajo pa    ON pa.id = o.ot_padre_id
  LEFT JOIN core.sucursal su         ON su.id = o.sucursal_id
  LEFT JOIN core.empresa_ruc er      ON er.id = o.empresa_ruc_id
  LEFT JOIN core.area ar             ON ar.id = o.area_id
  LEFT JOIN core.cecos ce            ON ce.id = o.cecos_id
  LEFT JOIN core.catalogo_item tm    ON tm.id = o.tipo_mantenimiento_id
  LEFT JOIN core.tipo_trabajo tt     ON tt.id = o.tipo_trabajo_id
  LEFT JOIN core.usuario co          ON co.id = o.coordinador_id
  LEFT JOIN core.usuario ej          ON ej.id = o.ejecutor_id
  LEFT JOIN core.cotizacion c        ON c.ot_id = o.id AND c.vigente AND NOT c.invalidada
  LEFT JOIN core.proveedor pr        ON pr.id = c.proveedor_id
  LEFT JOIN core.solped sp           ON sp.ot_id = o.id AND sp.vigente AND NOT sp.anulada
  LEFT JOIN core.seguimiento_administrativo sa ON sa.ot_id = o.id
  LEFT JOIN LATERAL (SELECT numero_oc FROM core.orden_compra
                      WHERE ot_id = o.id AND NOT anulada
                      ORDER BY created_at DESC LIMIT 1) oc ON true
  WHERE o.deleted_at IS NULL
    AND (v_global OR o.tenant_id = p_tenant_id)
    AND (v_desde  IS NULL OR o.fecha_creacion >= v_desde::timestamptz)
    AND (v_hasta  IS NULL OR o.fecha_creacion < (v_hasta::date + 1)::timestamptz)
    AND (v_suc    IS NULL OR o.sucursal_id = v_suc::uuid)
    AND (v_emp    IS NULL OR o.empresa_ruc_id = v_emp::uuid)
    AND (v_area   IS NULL OR o.area_id = v_area::uuid)
    AND (v_estado IS NULL OR o.estado::text = v_estado)
    AND (v_prio   IS NULL OR o.prioridad_tecnica::text = v_prio)
    AND (v_tipo   IS NULL OR o.tipo_trabajo_id = v_tipo::uuid)
    AND (v_resp   IS NULL OR o.coordinador_id = v_resp::uuid OR o.ejecutor_id = v_resp::uuid)
    AND (v_emerg  IS NULL OR o.es_emergencia = v_emerg)
    AND (v_global
         OR NOT EXISTS (SELECT 1 FROM core.usuario_alcance ua WHERE ua.usuario_id = p_user_id)
         OR EXISTS (SELECT 1 FROM core.usuario_alcance ua
                     WHERE ua.usuario_id = p_user_id
                       AND (ua.sucursal_id    IS NULL OR ua.sucursal_id    = o.sucursal_id)
                       AND (ua.empresa_ruc_id IS NULL OR ua.empresa_ruc_id = o.empresa_ruc_id)
                       AND (ua.area_id        IS NULL OR ua.area_id        = o.area_id)));

  RETURN jsonb_build_object('ok', true, 'data', v,
    'meta', jsonb_build_object('filtros', p_filtros, 'incluye_costos', v_ve_costos));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
