-- =============================================================================
-- 20_app_auth.sql · Identidad y sesión
--
-- El hash de contraseña se calcula y verifica AQUÍ, con pgcrypto, para que la
-- contraseña en claro no exista fuera de la transacción. El backend nunca ve el
-- hash: recibe el perfil ya resuelto con roles, permisos y alcance.
-- =============================================================================
SET search_path = app, core, internal, public;

-- Devuelve el perfil completo que el backend mete en el JWT y el frontend usa
-- para pintar el menú: roles, permisos efectivos y alcance organizacional.
CREATE OR REPLACE FUNCTION app.fn_auth_perfil(p_user_id UUID)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB;
BEGIN
  SELECT jsonb_build_object(
    'id', u.id, 'email', u.email,
    'nombres', u.nombres, 'apellidos', u.apellidos,
    'nombre', u.nombres || ' ' || u.apellidos,
    'cargo', u.cargo, 'telefono', u.telefono,
    'tenant_id', u.tenant_id,
    'tenant', (SELECT jsonb_build_object('id', t.id, 'nombre', t.nombre,
                                         'zona_horaria', t.zona_horaria,
                                         'moneda_base', t.moneda_base)
                 FROM core.tenant t WHERE t.id = u.tenant_id),
    'is_super_admin', u.is_super_admin,
    'estado', u.estado,
    'preferencias', u.preferencias,
    'roles', coalesce((SELECT jsonb_agg(r.codigo ORDER BY r.codigo)
                         FROM core.usuario_rol ur JOIN core.rol r ON r.id = ur.rol_id
                        WHERE ur.usuario_id = u.id), '[]'::jsonb),
    'permisos', coalesce((SELECT jsonb_agg(DISTINCT p.codigo)
                            FROM core.usuario_rol ur
                            JOIN core.rol_permiso rp ON rp.rol_id = ur.rol_id
                            JOIN core.permiso p      ON p.id = rp.permiso_id
                           WHERE ur.usuario_id = u.id), '[]'::jsonb),
    'acceso_global', internal.es_acceso_global(u.id, u.is_super_admin),
    -- El alcance viaja al frontend para poder filtrar selectores sin ida y vuelta.
    'alcance', coalesce((SELECT jsonb_agg(jsonb_build_object(
                            'sucursal_id', a.sucursal_id, 'empresa_ruc_id', a.empresa_ruc_id,
                            'area_id', a.area_id))
                           FROM core.usuario_alcance a WHERE a.usuario_id = u.id), '[]'::jsonb)
  ) INTO v
  FROM core.usuario u
  WHERE u.id = p_user_id AND u.deleted_at IS NULL;

  IF v IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Usuario no encontrado'));
  END IF;
  RETURN jsonb_build_object('ok', true, 'data', v);
END; $$;

CREATE OR REPLACE FUNCTION app.sp_auth_login(p_email TEXT, p_password TEXT)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE u core.usuario%ROWTYPE;
BEGIN
  SELECT * INTO u FROM core.usuario
   WHERE lower(email) = lower(btrim(p_email)) AND deleted_at IS NULL;

  -- Mismo mensaje para usuario inexistente y contraseña incorrecta: no se le
  -- regala a un atacante la confirmación de qué correos existen.
  IF NOT FOUND OR u.password_hash IS NULL
     OR u.password_hash <> crypt(p_password, u.password_hash) THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('UNAUTHORIZED','Credenciales inválidas'));
  END IF;

  IF u.estado <> 'activo' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('FORBIDDEN','La cuenta está ' || u.estado));
  END IF;

  UPDATE core.usuario SET ultimo_acceso_at = now() WHERE id = u.id;
  PERFORM internal.registrar_auditoria(u.id, u.tenant_id, 'login', 'usuario', u.id);
  RETURN app.fn_auth_perfil(u.id);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_auth_cambiar_password(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_password_actual TEXT, p_password_nueva TEXT)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v_hash TEXT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT password_hash INTO v_hash FROM core.usuario WHERE id = p_user_id AND deleted_at IS NULL;
  IF v_hash IS NULL OR v_hash <> crypt(p_password_actual, v_hash) THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('UNAUTHORIZED','La contraseña actual no coincide'));
  END IF;
  IF length(coalesce(p_password_nueva,'')) < 10 THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La contraseña debe tener al menos 10 caracteres','password_nueva'));
  END IF;

  UPDATE core.usuario
     SET password_hash = crypt(p_password_nueva, gen_salt('bf', 12)), updated_by = p_user_id
   WHERE id = p_user_id;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'cambiar_password', 'usuario', p_user_id);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('cambiada', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
