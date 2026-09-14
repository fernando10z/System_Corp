-- =============================================================================
-- 22_app_usuarios.sql · Usuarios, roles asignados y alcance
--
-- Regla dura del Anexo C: un usuario con historial NO se elimina, se inactiva.
-- Sus OT, mensajes, diagnósticos y auditoría conservan la autoría original (QA-23).
-- =============================================================================
SET search_path = app, core, internal, public;

CREATE OR REPLACE FUNCTION app.fn_usuario_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_filtros JSONB DEFAULT '{}'::jsonb, p_page INT DEFAULT 1, p_page_size INT DEFAULT 20)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v_size INT := least(greatest(coalesce(p_page_size,20),1),100);
  v_off  INT := (greatest(coalesce(p_page,1),1)-1) * v_size;
  v_total INT; v_data JSONB; v_global BOOLEAN;
  v_buscar TEXT := internal.normalizar_busqueda(p_filtros->>'buscar');
  v_estado TEXT := p_filtros->>'estado';
  v_rol    TEXT := p_filtros->>'rol';
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'usuarios:listar');
  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  SELECT count(*) INTO v_total
    FROM core.usuario u
   WHERE u.deleted_at IS NULL
     AND (v_global OR u.tenant_id = p_tenant_id)
     AND (v_estado IS NULL OR u.estado::text = v_estado)
     AND (nullif(v_buscar,'') IS NULL
          OR internal.normalizar_busqueda(u.nombres||' '||u.apellidos||' '||u.email) LIKE '%'||v_buscar||'%')
     AND (v_rol IS NULL OR EXISTS (SELECT 1 FROM core.usuario_rol ur JOIN core.rol r ON r.id=ur.rol_id
                                    WHERE ur.usuario_id=u.id AND r.codigo=v_rol));

  SELECT coalesce(jsonb_agg(d ORDER BY d->>'apellidos'), '[]'::jsonb) INTO v_data FROM (
    SELECT jsonb_build_object(
      'id', u.id, 'email', u.email, 'nombres', u.nombres, 'apellidos', u.apellidos,
      'nombre', u.nombres||' '||u.apellidos,
      'documento', u.documento, 'telefono', u.telefono, 'cargo', u.cargo,
      'estado', u.estado, 'is_super_admin', u.is_super_admin,
      'ultimo_acceso_at', u.ultimo_acceso_at,
      'roles', coalesce((SELECT jsonb_agg(jsonb_build_object('id',r.id,'codigo',r.codigo,'nombre',r.nombre))
                           FROM core.usuario_rol ur JOIN core.rol r ON r.id=ur.rol_id
                          WHERE ur.usuario_id=u.id), '[]'::jsonb)
    ) AS d
    FROM core.usuario u
    WHERE u.deleted_at IS NULL
      AND (v_global OR u.tenant_id = p_tenant_id)
      AND (v_estado IS NULL OR u.estado::text = v_estado)
      AND (nullif(v_buscar,'') IS NULL
           OR internal.normalizar_busqueda(u.nombres||' '||u.apellidos||' '||u.email) LIKE '%'||v_buscar||'%')
      AND (v_rol IS NULL OR EXISTS (SELECT 1 FROM core.usuario_rol ur JOIN core.rol r ON r.id=ur.rol_id
                                     WHERE ur.usuario_id=u.id AND r.codigo=v_rol))
    ORDER BY u.apellidos, u.nombres
    LIMIT v_size OFFSET v_off
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v_data,
                            'meta', internal.meta_paginacion(v_total, p_page, v_size));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_usuario_crear(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_email TEXT, p_nombres TEXT, p_apellidos TEXT, p_password TEXT,
  p_rol_codigos TEXT[] DEFAULT NULL, p_cargo TEXT DEFAULT NULL,
  p_documento TEXT DEFAULT NULL, p_telefono TEXT DEFAULT NULL,
  p_alcance JSONB DEFAULT '[]'::jsonb)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v core.usuario%ROWTYPE; c TEXT; a JSONB; v_rol UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'usuarios:crear');

  IF length(coalesce(p_password,'')) < 10 THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La contraseña debe tener al menos 10 caracteres','password'));
  END IF;

  INSERT INTO core.usuario (tenant_id, email, password_hash, nombres, apellidos,
                            documento, telefono, cargo, created_by, updated_by)
  VALUES (p_tenant_id, lower(btrim(p_email)), crypt(p_password, gen_salt('bf', 12)),
          btrim(p_nombres), btrim(p_apellidos), p_documento, p_telefono, p_cargo,
          p_user_id, p_user_id)
  RETURNING * INTO v;

  IF p_rol_codigos IS NOT NULL THEN
    FOREACH c IN ARRAY p_rol_codigos LOOP
      SELECT id INTO v_rol FROM core.rol
       WHERE codigo = c AND (tenant_id = p_tenant_id OR tenant_id IS NULL)
       ORDER BY tenant_id NULLS LAST LIMIT 1;
      IF v_rol IS NOT NULL THEN
        INSERT INTO core.usuario_rol (usuario_id, rol_id, created_by)
        VALUES (v.id, v_rol, p_user_id) ON CONFLICT DO NOTHING;
      END IF;
    END LOOP;
  END IF;

  -- Alcance organizacional: [{sucursal_id, empresa_ruc_id, area_id}, …]. NULL en
  -- un nivel significa "todo ese nivel" (cap. 4.1).
  FOR a IN SELECT * FROM jsonb_array_elements(coalesce(p_alcance,'[]'::jsonb)) LOOP
    INSERT INTO core.usuario_alcance (tenant_id, usuario_id, sucursal_id, empresa_ruc_id, area_id, created_by)
    VALUES (p_tenant_id, v.id,
            nullif(a->>'sucursal_id','')::uuid,
            nullif(a->>'empresa_ruc_id','')::uuid,
            nullif(a->>'area_id','')::uuid, p_user_id);
  END LOOP;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'usuario', v.id,
                                       NULL, to_jsonb(v) - 'password_hash');
  RETURN app.fn_auth_perfil(v.id);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Inactivar, nunca borrar: la historia conserva al autor inactivo (Anexo C, QA-23).
CREATE OR REPLACE FUNCTION app.sp_usuario_inactivar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_usuario_id UUID, p_motivo TEXT)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v_antes JSONB; v_ot INT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'usuarios:editar');

  SELECT to_jsonb(u) - 'password_hash' INTO v_antes FROM core.usuario u WHERE u.id = p_usuario_id;
  IF v_antes IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Usuario no encontrado'));
  END IF;

  SELECT count(*) INTO v_ot
    FROM core.orden_trabajo
   WHERE (coordinador_id = p_usuario_id OR ejecutor_id = p_usuario_id)
     AND estado NOT IN ('cerrada','cancelada') AND deleted_at IS NULL;

  UPDATE core.usuario SET estado = 'inactivo', updated_by = p_user_id WHERE id = p_usuario_id;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'inactivar', 'usuario',
                                       p_usuario_id, v_antes, NULL, p_motivo);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'inactivado', true,
    'ot_asignadas_abiertas', v_ot,
    'alerta', CASE WHEN v_ot > 0
                   THEN format('El usuario tiene %s OT abiertas asignadas; reasígnelas.', v_ot) END));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
