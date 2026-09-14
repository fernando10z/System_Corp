-- =============================================================================
-- 23_app_roles_permisos.sql · Roles, permisos y matriz del Anexo B
--
-- La matriz del Anexo B es una BASE FUNCIONAL, no la política de seguridad final
-- de cada organización: por eso los permisos marcados con asterisco se habilitan
-- o restringen por configuración, y estos SP permiten reasignarlos.
-- =============================================================================
SET search_path = app, core, internal, public;

CREATE OR REPLACE FUNCTION app.fn_rol_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'roles:listar');

  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'id', r.id, 'codigo', r.codigo, 'nombre', r.nombre, 'descripcion', r.descripcion,
    'scope', r.scope, 'es_sistema', r.es_sistema,
    'usuarios', (SELECT count(*) FROM core.usuario_rol ur WHERE ur.rol_id = r.id),
    'permisos', coalesce((SELECT jsonb_agg(p.codigo ORDER BY p.codigo)
                            FROM core.rol_permiso rp JOIN core.permiso p ON p.id = rp.permiso_id
                           WHERE rp.rol_id = r.id), '[]'::jsonb)
  ) ORDER BY r.nombre), '[]'::jsonb) INTO v
  FROM core.rol r
  WHERE r.deleted_at IS NULL AND (r.tenant_id = p_tenant_id OR r.tenant_id IS NULL);

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.fn_permiso_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id', p.id, 'codigo', p.codigo, 'modulo', p.modulo,
           'accion', p.accion, 'descripcion', p.descripcion) ORDER BY p.modulo, p.accion), '[]'::jsonb)
    INTO v FROM core.permiso p;
  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Reemplaza el set completo de permisos de un rol. Auditado con el valor anterior
-- y el nuevo, porque el cap. 33 exige rastro en los cambios de seguridad.
CREATE OR REPLACE FUNCTION app.sp_rol_asignar_permisos(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_rol_id UUID, p_permiso_codigos TEXT[])
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v_antes JSONB; v_despues JSONB; c TEXT; v_permiso UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'roles:editar');

  SELECT coalesce(jsonb_agg(p.codigo ORDER BY p.codigo), '[]'::jsonb) INTO v_antes
    FROM core.rol_permiso rp JOIN core.permiso p ON p.id = rp.permiso_id
   WHERE rp.rol_id = p_rol_id;

  DELETE FROM core.rol_permiso WHERE rol_id = p_rol_id;
  FOREACH c IN ARRAY coalesce(p_permiso_codigos, ARRAY[]::TEXT[]) LOOP
    SELECT id INTO v_permiso FROM core.permiso WHERE codigo = c;
    IF v_permiso IS NOT NULL THEN
      INSERT INTO core.rol_permiso (rol_id, permiso_id) VALUES (p_rol_id, v_permiso)
      ON CONFLICT DO NOTHING;
    END IF;
  END LOOP;

  SELECT coalesce(jsonb_agg(p.codigo ORDER BY p.codigo), '[]'::jsonb) INTO v_despues
    FROM core.rol_permiso rp JOIN core.permiso p ON p.id = rp.permiso_id
   WHERE rp.rol_id = p_rol_id;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'asignar_permisos', 'rol', p_rol_id,
                                       jsonb_build_object('permisos', v_antes),
                                       jsonb_build_object('permisos', v_despues));
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('permisos', v_despues));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
