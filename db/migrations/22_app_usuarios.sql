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
  -- El rango se aplica al alta del usuario: es la fecha que tiene sentido
  -- acotar en una pantalla de administración ("altas de este mes").
  v_desde  TEXT := nullif(p_filtros->>'desde','');
  v_hasta  TEXT := nullif(p_filtros->>'hasta','');
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
     AND (v_desde IS NULL OR u.created_at >= v_desde::timestamptz)
     AND (v_hasta IS NULL OR u.created_at < (v_hasta::date + 1)::timestamptz)
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
      AND (v_desde IS NULL OR u.created_at >= v_desde::timestamptz)
      AND (v_hasta IS NULL OR u.created_at < (v_hasta::date + 1)::timestamptz)
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

-- ── Personas a las que se puede asignar trabajo ──────────────────────────────
-- Un coordinador necesita elegir coordinador y ejecutor al crear una OT o al
-- iniciar el trabajo, pero NO tiene `usuarios:listar` ni debe tenerlo: eso es la
-- administración de usuarios, con correos, último acceso y estado.
--
-- Esta función devuelve lo mínimo para poblar un selector —nombre, cargo y
-- roles— y la autoriza cualquiera de los permisos que de verdad implican
-- asignar. Hasta que existió, "Aceptar y crear OT" fallaba con "Permiso
-- denegado: usuarios:listar" para el rol que más la usa.
CREATE OR REPLACE FUNCTION app.fn_usuario_asignables(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_filtros JSONB DEFAULT '{}'::jsonb)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v_data JSONB;
  v_global BOOLEAN;
  v_rol TEXT := nullif(p_filtros->>'rol','');
  v_puede BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT p_is_super_admin OR EXISTS (
    SELECT 1 FROM core.usuario_rol ur
      JOIN core.rol_permiso rp ON rp.rol_id = ur.rol_id
      JOIN core.permiso p      ON p.id = rp.permiso_id
     WHERE ur.usuario_id = p_user_id
       AND p.codigo IN ('ot:crear','ot:editar','ejecucion:iniciar','usuarios:listar'))
  INTO v_puede;

  IF NOT v_puede THEN
    RAISE EXCEPTION 'Permiso denegado: asignar responsables' USING ERRCODE = '42501';
  END IF;

  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  SELECT coalesce(jsonb_agg(d ORDER BY d->>'nombre'), '[]'::jsonb) INTO v_data FROM (
    SELECT jsonb_build_object(
      'id', u.id,
      'nombre', u.nombres||' '||u.apellidos,
      'cargo', u.cargo,
      'roles', coalesce((SELECT jsonb_agg(r.codigo)
                           FROM core.usuario_rol ur JOIN core.rol r ON r.id=ur.rol_id
                          WHERE ur.usuario_id=u.id), '[]'::jsonb)
    ) AS d
    FROM core.usuario u
    WHERE u.deleted_at IS NULL
      AND u.estado = 'activo'
      AND (v_global OR u.tenant_id = p_tenant_id)
      AND (v_rol IS NULL OR EXISTS (SELECT 1 FROM core.usuario_rol ur JOIN core.rol r ON r.id=ur.rol_id
                                     WHERE ur.usuario_id=u.id AND r.codigo = v_rol))
    ORDER BY u.nombres, u.apellidos
    LIMIT 200
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v_data);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── Editar los datos de un usuario ───────────────────────────────────────────
-- El correo NO se edita: es la identidad con la que firmó todo su historial y
-- con la que entra. Para cambiarlo se inactiva y se da de alta otro, que es lo
-- que deja rastro de que son dos identidades distintas (Anexo C).
CREATE OR REPLACE FUNCTION app.sp_usuario_actualizar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_usuario_id UUID, p_nombres TEXT DEFAULT NULL, p_apellidos TEXT DEFAULT NULL,
  p_cargo TEXT DEFAULT NULL, p_documento TEXT DEFAULT NULL, p_telefono TEXT DEFAULT NULL,
  p_rol_codigos TEXT[] DEFAULT NULL, p_estado TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  u core.usuario%ROWTYPE;
  v_antes JSONB;
  c TEXT;
  v_rol UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'usuarios:editar');

  SELECT * INTO u FROM core.usuario
   WHERE id = p_usuario_id AND deleted_at IS NULL
     AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','El usuario no existe'));
  END IF;
  v_antes := to_jsonb(u);

  IF p_nombres IS NOT NULL AND btrim(p_nombres) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('VALIDATION','Los nombres no pueden quedar vacíos','nombres'));
  END IF;
  IF p_apellidos IS NOT NULL AND btrim(p_apellidos) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('VALIDATION','Los apellidos no pueden quedar vacíos','apellidos'));
  END IF;

  UPDATE core.usuario SET
    nombres   = coalesce(nullif(btrim(coalesce(p_nombres,'')),''), nombres),
    apellidos = coalesce(nullif(btrim(coalesce(p_apellidos,'')),''), apellidos),
    -- Cargo, documento y teléfono SÍ se pueden vaciar: son opcionales.
    cargo     = CASE WHEN p_cargo     IS NULL THEN cargo     ELSE nullif(btrim(p_cargo),'')     END,
    documento = CASE WHEN p_documento IS NULL THEN documento ELSE nullif(btrim(p_documento),'') END,
    telefono  = CASE WHEN p_telefono  IS NULL THEN telefono  ELSE nullif(btrim(p_telefono),'')  END,
    estado    = coalesce(nullif(p_estado,'')::core.estado_usuario, estado),
    updated_by = p_user_id
  WHERE id = p_usuario_id;

  -- Reasignar roles sólo si vienen: un array vacío deja al usuario sin ninguno,
  -- y eso tiene que poder hacerse a propósito.
  IF p_rol_codigos IS NOT NULL THEN
    DELETE FROM core.usuario_rol WHERE usuario_id = p_usuario_id;
    FOREACH c IN ARRAY p_rol_codigos LOOP
      SELECT id INTO v_rol FROM core.rol
       WHERE codigo = c AND (tenant_id IS NULL OR tenant_id = u.tenant_id)
       ORDER BY tenant_id NULLS LAST LIMIT 1;
      IF v_rol IS NOT NULL THEN
        INSERT INTO core.usuario_rol (usuario_id, rol_id) VALUES (p_usuario_id, v_rol)
        ON CONFLICT DO NOTHING;
      END IF;
    END LOOP;
  END IF;

  SELECT * INTO u FROM core.usuario WHERE id = p_usuario_id;
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'editar', 'usuario', p_usuario_id,
                                       v_antes, to_jsonb(u));

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('id', u.id, 'actualizado', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── Restablecer la contraseña de otro usuario ────────────────────────────────
-- Es una acción de administración, distinta de que el usuario cambie la suya:
-- aquí NO se pide la contraseña anterior, y por eso queda auditada aparte. El
-- hash nunca sale de la transacción y la contraseña previa no se conserva.
CREATE OR REPLACE FUNCTION app.sp_usuario_restablecer_password(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_usuario_id UUID, p_password_nueva TEXT)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE u core.usuario%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'usuarios:editar');

  IF length(coalesce(p_password_nueva,'')) < 10 THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','La contraseña necesita al menos 10 caracteres','password_nueva'));
  END IF;

  SELECT * INTO u FROM core.usuario
   WHERE id = p_usuario_id AND deleted_at IS NULL
     AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','El usuario no existe'));
  END IF;

  UPDATE core.usuario
     SET password_hash = crypt(p_password_nueva, gen_salt('bf', 12)),
         -- Un restablecimiento levanta cualquier bloqueo por intentos fallidos.
         intentos_fallidos = 0, bloqueado_hasta = NULL,
         updated_by = p_user_id
   WHERE id = p_usuario_id;

  -- Sin valores: una auditoría de contraseñas no guarda contraseñas.
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'restablecer_password', 'usuario', p_usuario_id);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('restablecida', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
