-- =============================================================================
-- 35_app_notificaciones.sql · Notificaciones y SLA (cap. 19, 34)
--
-- El correo es una COPIA de la notificación interna, no la fuente de verdad, y un
-- fallo de entrega NO revierte la operación de negocio: se registra para soporte
-- (cap. 34.1). Por eso el estado 'fallida' existe y no dispara ningún rollback.
-- =============================================================================
SET search_path = app, core, internal, public;

CREATE OR REPLACE FUNCTION app.fn_notificacion_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_solo_no_leidas BOOLEAN DEFAULT false, p_limite INT DEFAULT 50)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB; v_no_leidas INT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT count(*) INTO v_no_leidas FROM core.notificacion
   WHERE destinatario_id = p_user_id AND leida_at IS NULL;

  SELECT coalesce(jsonb_agg(x ORDER BY (x->>'fecha') DESC), '[]'::jsonb) INTO v FROM (
    SELECT jsonb_build_object(
      'id', n.id, 'evento', n.evento, 'titulo', n.titulo, 'cuerpo', n.cuerpo,
      'ot_id', n.ot_id, 'ot_numero', o.numero_ot,
      'entidad_tipo', n.entidad_tipo, 'entidad_id', n.entidad_id,
      'leida', n.leida_at IS NOT NULL, 'fecha', n.created_at) AS x
      FROM core.notificacion n
      LEFT JOIN core.orden_trabajo o ON o.id = n.ot_id
     WHERE n.destinatario_id = p_user_id
       AND (NOT p_solo_no_leidas OR n.leida_at IS NULL)
     ORDER BY n.created_at DESC
     LIMIT least(coalesce(p_limite,50), 200)
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v,
                            'meta', jsonb_build_object('no_leidas', v_no_leidas));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_notificacion_marcar_leida(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_notificacion_id UUID DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v_n INT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  -- Sin id se marcan todas: es el "marcar todo como leído" de la campana.
  UPDATE core.notificacion
     SET leida_at = now(), estado = 'leida'
   WHERE destinatario_id = p_user_id AND leida_at IS NULL
     AND (p_notificacion_id IS NULL OR id = p_notificacion_id);
  GET DIAGNOSTICS v_n = ROW_COUNT;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('marcadas', v_n));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Cola de correo pendiente. El backend la consume y marca el resultado; MIP no
-- depende de que ese envío funcione (cap. 34.1).
CREATE OR REPLACE FUNCTION app.fn_notificacion_pendientes_correo(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_limite INT DEFAULT 100)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id', n.id, 'email', u.email,
           'nombre', u.nombres||' '||u.apellidos,
           'evento', n.evento, 'titulo', n.titulo, 'cuerpo', n.cuerpo,
           'ot_numero', o.numero_ot)), '[]'::jsonb) INTO v
  FROM core.notificacion n
  JOIN core.usuario u ON u.id = n.destinatario_id AND u.estado = 'activo'
  LEFT JOIN core.orden_trabajo o ON o.id = n.ot_id
  WHERE n.tenant_id = p_tenant_id AND n.estado = 'pendiente'
    -- Cada usuario puede ajustar sus preferencias; los eventos críticos pueden
    -- ser obligatorios por tenant (cap. 34.1).
    AND coalesce((u.preferencias->'correo'->>n.evento)::boolean, true)
  LIMIT least(coalesce(p_limite,100), 500);

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_notificacion_marcar_enviada(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_notificacion_id UUID, p_exito BOOLEAN, p_error TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  UPDATE core.notificacion
     SET estado = CASE WHEN p_exito THEN 'enviada'::core.estado_notificacion
                       ELSE 'fallida'::core.estado_notificacion END,
         error_envio = p_error
   WHERE id = p_notificacion_id;
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('registrado', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── SLA de primera revisión (cap. 34.2) ─────────────────────────────────────
-- Son OBJETIVOS DE ATENCIÓN, no estimaciones de ejecución. El tablero mide
-- incumplimientos pero NO cierra nada automáticamente.
CREATE OR REPLACE FUNCTION app.fn_sla_solicitudes(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB; v_sla JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  -- Minutos máximos de primera revisión, configurables por tenant.
  v_sla := coalesce(internal.config(p_tenant_id, 'sla_primera_revision'),
                    '{"critica":15,"alta":60,"media":480,"baja":1440}'::jsonb);

  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'prioridad', pr,
    'sla_minutos', (v_sla->>pr)::int,
    'pendientes', pendientes,
    'incumplidas', incumplidas
  ) ORDER BY pr), '[]'::jsonb) INTO v
  FROM (
    SELECT coalesce(s.prioridad_percibida::text,'baja') AS pr,
           count(*) FILTER (WHERE s.fecha_primera_revision IS NULL) AS pendientes,
           count(*) FILTER (
             WHERE s.fecha_primera_revision IS NULL
               AND s.fecha_envio IS NOT NULL
               AND now() - s.fecha_envio >
                   make_interval(mins => coalesce((v_sla->>coalesce(s.prioridad_percibida::text,'baja'))::int, 1440))
           ) AS incumplidas
      FROM core.solicitud_trabajo s
     WHERE s.tenant_id = p_tenant_id AND s.deleted_at IS NULL
       AND s.estado IN ('enviada','en_revision')
     GROUP BY 1
  ) x;

  RETURN jsonb_build_object('ok', true, 'data', v,
    'meta', jsonb_build_object('nota',
      'Los SLA son objetivos de atención, no estimaciones de ejecución. No cierran solicitudes automáticamente.'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
