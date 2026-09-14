-- =============================================================================
-- 36_app_auditoria.sql · Auditoría e historial operativo (cap. 18, 33)
--
-- Dos vistas del mismo hecho, deliberadamente separadas (cap. 33):
--   · El HISTORIAL OPERATIVO resume los hechos en lenguaje de negocio y lo ve
--     quien puede ver la OT.
--   · La AUDITORÍA TÉCNICA conserva el detalle de control y es de consulta
--     restringida; exportarla exige permiso y respeta el alcance organizacional.
-- =============================================================================
SET search_path = app, core, internal, public;

CREATE OR REPLACE FUNCTION app.fn_ot_historial(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_ot_id UUID)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:ver');
  RETURN jsonb_build_object('ok', true, 'data', internal.fn_ot_eventos(p_ot_id, 1000));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.fn_auditoria_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_filtros JSONB DEFAULT '{}'::jsonb, p_page INT DEFAULT 1, p_page_size INT DEFAULT 50)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, audit, app, internal, public AS $$
DECLARE
  v_size INT := least(greatest(coalesce(p_page_size,50),1),200);
  v_off  INT := (greatest(coalesce(p_page,1),1)-1)*v_size;
  v_total INT; v_data JSONB;
  v_entidad TEXT := p_filtros->>'entidad';
  v_entidad_id TEXT := p_filtros->>'entidad_id';
  v_actor   TEXT := p_filtros->>'actor_id';
  v_accion  TEXT := p_filtros->>'accion';
  v_desde   TEXT := p_filtros->>'desde';
  v_hasta   TEXT := p_filtros->>'hasta';
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  -- Consulta restringida: exige permiso explícito (cap. 33).
  PERFORM internal.assert_permiso(p_user_id, 'auditoria:ver');

  SELECT count(*) INTO v_total FROM audit.audit_log a
   WHERE a.tenant_id = p_tenant_id
     AND (v_entidad    IS NULL OR a.entidad = v_entidad)
     AND (v_entidad_id IS NULL OR a.entidad_id = v_entidad_id::uuid)
     AND (v_actor      IS NULL OR a.actor_id = v_actor::uuid)
     AND (v_accion     IS NULL OR a.accion = v_accion)
     AND (v_desde      IS NULL OR a.created_at >= v_desde::timestamptz)
     AND (v_hasta      IS NULL OR a.created_at < (v_hasta::date + 1)::timestamptz);

  SELECT coalesce(jsonb_agg(x ORDER BY (x->>'fecha') DESC), '[]'::jsonb) INTO v_data FROM (
    SELECT jsonb_build_object(
      'id', a.id, 'accion', a.accion, 'entidad', a.entidad, 'entidad_id', a.entidad_id,
      'actor', u.nombres||' '||u.apellidos, 'actor_id', a.actor_id,
      'diff', a.diff, 'motivo', a.motivo,
      'request_id', a.request_id, 'fecha', a.created_at) AS x
      FROM audit.audit_log a LEFT JOIN core.usuario u ON u.id = a.actor_id
     WHERE a.tenant_id = p_tenant_id
       AND (v_entidad    IS NULL OR a.entidad = v_entidad)
       AND (v_entidad_id IS NULL OR a.entidad_id = v_entidad_id::uuid)
       AND (v_actor      IS NULL OR a.actor_id = v_actor::uuid)
       AND (v_accion     IS NULL OR a.accion = v_accion)
       AND (v_desde      IS NULL OR a.created_at >= v_desde::timestamptz)
       AND (v_hasta      IS NULL OR a.created_at < (v_hasta::date + 1)::timestamptz)
     ORDER BY a.created_at DESC
     LIMIT v_size OFFSET v_off
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v_data,
                            'meta', internal.meta_paginacion(v_total, p_page, v_size));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
