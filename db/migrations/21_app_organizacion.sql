-- =============================================================================
-- 21_app_organizacion.sql · Sucursales, empresas/RUC, áreas y CECOS
--
-- Regla del Anexo C que el modelo hace cumplir aquí: si se inactiva una RUC con
-- OT abiertas, se conserva en datos, se IMPIDE usarla en OT nuevas y se avisa;
-- las OT existentes siguen su curso (QA-24).
-- =============================================================================
SET search_path = app, core, internal, public;

CREATE OR REPLACE FUNCTION app.fn_organizacion_arbol(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'id', s.id, 'codigo', s.codigo, 'nombre', s.nombre, 'estado', s.estado,
    'empresas', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
        'id', e.id, 'ruc', e.ruc, 'razon_social', e.razon_social, 'estado', e.estado,
        'areas', coalesce((
          SELECT jsonb_agg(jsonb_build_object('id', a.id, 'codigo', a.codigo,
                                              'nombre', a.nombre, 'estado', a.estado)
                 ORDER BY a.nombre)
            FROM core.area a WHERE a.empresa_ruc_id = e.id AND a.deleted_at IS NULL), '[]'::jsonb)
      ) ORDER BY e.razon_social)
        FROM core.sucursal_empresa_ruc se
        JOIN core.empresa_ruc e ON e.id = se.empresa_ruc_id AND e.deleted_at IS NULL
       WHERE se.sucursal_id = s.id), '[]'::jsonb)
  ) ORDER BY s.nombre), '[]'::jsonb) INTO v
  FROM core.sucursal s
  WHERE s.tenant_id = p_tenant_id AND s.deleted_at IS NULL;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_sucursal_crear(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_codigo TEXT, p_nombre TEXT, p_direccion TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v core.sucursal%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'organizacion:crear');

  INSERT INTO core.sucursal (tenant_id, codigo, nombre, direccion, created_by, updated_by)
  VALUES (p_tenant_id, upper(btrim(p_codigo)), btrim(p_nombre), p_direccion, p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'sucursal', v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_empresa_ruc_crear(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ruc TEXT, p_razon_social TEXT, p_nombre_corto TEXT DEFAULT NULL,
  p_sucursal_ids UUID[] DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v core.empresa_ruc%ROWTYPE; s UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'organizacion:crear');

  IF NOT internal.validar_ruc(p_ruc) THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El RUC no es válido','ruc'));
  END IF;

  INSERT INTO core.empresa_ruc (tenant_id, ruc, razon_social, nombre_corto, created_by, updated_by)
  VALUES (p_tenant_id, regexp_replace(p_ruc,'\D','','g'), btrim(p_razon_social), p_nombre_corto,
          p_user_id, p_user_id)
  RETURNING * INTO v;

  IF p_sucursal_ids IS NOT NULL THEN
    FOREACH s IN ARRAY p_sucursal_ids LOOP
      INSERT INTO core.sucursal_empresa_ruc (tenant_id, sucursal_id, empresa_ruc_id)
      VALUES (p_tenant_id, s, v.id) ON CONFLICT DO NOTHING;
    END LOOP;
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'empresa_ruc', v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Inactivar una RUC no la borra: la conserva, impide usarla en OT nuevas y avisa
-- cuántas OT abiertas quedan para que administración las gestione (Anexo C, QA-24).
CREATE OR REPLACE FUNCTION app.sp_empresa_ruc_inactivar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_empresa_ruc_id UUID, p_motivo TEXT)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v_abiertas INT; v_antes JSONB; v_despues JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'organizacion:editar');

  SELECT to_jsonb(e) INTO v_antes FROM core.empresa_ruc e WHERE e.id = p_empresa_ruc_id;
  IF v_antes IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Empresa/RUC no encontrada'));
  END IF;

  SELECT count(*) INTO v_abiertas
    FROM core.orden_trabajo
   WHERE empresa_ruc_id = p_empresa_ruc_id
     AND estado NOT IN ('cerrada','cancelada') AND deleted_at IS NULL;

  UPDATE core.empresa_ruc SET estado = 'inactivo', updated_by = p_user_id
   WHERE id = p_empresa_ruc_id
  RETURNING to_jsonb(core.empresa_ruc.*) INTO v_despues;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'inactivar', 'empresa_ruc',
                                       p_empresa_ruc_id, v_antes, v_despues, p_motivo);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'inactivada', true,
    'ot_abiertas', v_abiertas,
    'alerta', CASE WHEN v_abiertas > 0
                   THEN format('Quedan %s OT abiertas con esta RUC. Se conservan, pero no podrá usarse en OT nuevas.', v_abiertas)
              END));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_area_crear(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_empresa_ruc_id UUID, p_codigo TEXT, p_nombre TEXT)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v core.area%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'organizacion:crear');

  -- Un área pertenece a UNA sola empresa/RUC (cap. 5). El mismo nombre bajo otra
  -- razón social es otra entidad, y el índice único lo permite explícitamente.
  INSERT INTO core.area (tenant_id, empresa_ruc_id, codigo, nombre, created_by, updated_by)
  VALUES (p_tenant_id, p_empresa_ruc_id, upper(btrim(p_codigo)), btrim(p_nombre), p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'area', v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Áreas visibles para el usuario: respeta su alcance organizacional (cap. 4.1).
CREATE OR REPLACE FUNCTION app.fn_area_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_filtros JSONB DEFAULT '{}'::jsonb)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB; v_global BOOLEAN; v_empresa TEXT := p_filtros->>'empresa_ruc_id';
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id', a.id, 'codigo', a.codigo, 'nombre', a.nombre, 'estado', a.estado,
           'empresa_ruc_id', a.empresa_ruc_id,
           'empresa_ruc', e.razon_social, 'ruc', e.ruc,
           'empresa_activa', e.estado = 'activo'
         ) ORDER BY e.razon_social, a.nombre), '[]'::jsonb) INTO v
  FROM core.area a
  JOIN core.empresa_ruc e ON e.id = a.empresa_ruc_id
  WHERE a.deleted_at IS NULL
    AND (v_global OR a.tenant_id = p_tenant_id)
    AND (v_empresa IS NULL OR a.empresa_ruc_id = v_empresa::uuid)
    AND (v_global
         OR NOT EXISTS (SELECT 1 FROM core.usuario_alcance ua WHERE ua.usuario_id = p_user_id)
         OR EXISTS (SELECT 1 FROM core.usuario_alcance ua
                     WHERE ua.usuario_id = p_user_id
                       AND (ua.area_id IS NULL OR ua.area_id = a.id)
                       AND (ua.empresa_ruc_id IS NULL OR ua.empresa_ruc_id = a.empresa_ruc_id)));

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
