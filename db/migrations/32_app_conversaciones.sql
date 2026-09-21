-- =============================================================================
-- 32_app_conversaciones.sql · Conversación contextual (cap. 13, 30)
--
-- Reglas que el módulo hace cumplir:
--   · Un mensaje NUNCA cambia el estado operativo ni sustituye un registro formal.
--   · El solicitante no ve notas internas ni costos (QA-18).
--   · Editar deja marca y conserva el contenido anterior; retirar es lógico.
--   · Al cerrar la OT la conversación pasa a solo lectura (cap. 30.2).
--   · Las menciones sólo notifican a quien tiene permiso de ver la OT.
-- =============================================================================
SET search_path = app, core, internal, public;

CREATE OR REPLACE FUNCTION app.sp_mensaje_publicar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_cuerpo TEXT, p_visibilidad TEXT DEFAULT 'canal',
  p_responde_a UUID DEFAULT NULL, p_menciones UUID[] DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  c core.conversacion%ROWTYPE;
  o core.orden_trabajo%ROWTYPE;
  v core.mensaje%ROWTYPE;
  pa core.conversacion_participante%ROWTYPE;
  m UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'conversacion:escribir');

  IF btrim(coalesce(p_cuerpo,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El mensaje no puede estar vacío','cuerpo'));
  END IF;

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  SELECT * INTO c FROM core.conversacion WHERE ot_id = p_ot_id;
  IF NOT FOUND THEN
    INSERT INTO core.conversacion (tenant_id, ot_id) VALUES (p_tenant_id, p_ot_id) RETURNING * INTO c;
  END IF;

  IF c.solo_lectura AND NOT p_is_super_admin THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE','La conversación está en solo lectura porque la OT está cerrada'));
  END IF;

  SELECT * INTO pa FROM core.conversacion_participante
   WHERE conversacion_id = c.id AND usuario_id = p_user_id AND activo;

  IF NOT FOUND AND NOT p_is_super_admin THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'FORBIDDEN','No participa en la conversación de esta OT'));
  END IF;
  IF FOUND AND NOT pa.puede_escribir THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'FORBIDDEN','Su acceso a esta conversación es de sólo lectura'));
  END IF;
  -- Una nota interna sólo la publica quien puede verlas (cap. 30.1).
  IF p_visibilidad = 'interna' AND FOUND AND NOT pa.ve_notas_internas AND NOT p_is_super_admin THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'FORBIDDEN','No puede publicar notas internas'));
  END IF;

  INSERT INTO core.mensaje (tenant_id, conversacion_id, tipo, visibilidad, cuerpo,
                            responde_a, autor_id, menciones)
  VALUES (p_tenant_id, c.id, 'humano', coalesce(p_visibilidad,'canal')::core.visibilidad_mensaje,
          btrim(p_cuerpo), p_responde_a, p_user_id, coalesce(p_menciones, '{}'))
  RETURNING * INTO v;

  -- Notificar a los participantes; las menciones sólo llegan a quien participa,
  -- que es la forma de garantizar "sólo usuarios con permiso de ver la OT".
  FOR m IN
    SELECT pp.usuario_id FROM core.conversacion_participante pp
     WHERE pp.conversacion_id = c.id AND pp.activo AND pp.usuario_id <> p_user_id
       AND (coalesce(p_visibilidad,'canal') <> 'interna' OR pp.ve_notas_internas)
  LOOP
    PERFORM internal.notificar(p_tenant_id, m, 'mensaje_nuevo',
      format('Nuevo mensaje en la OT %s', o.numero_ot),
      left(btrim(p_cuerpo), 200), p_ot_id, 'mensaje', v.id);
  END LOOP;

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'fecha', v.created_at, 'visibilidad', v.visibilidad));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Editar deja marca 'editado' y conserva el contenido anterior (cap. 30.2).
CREATE OR REPLACE FUNCTION app.sp_mensaje_editar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_mensaje_id UUID, p_cuerpo TEXT)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v core.mensaje%ROWTYPE; v_ot UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT * INTO v FROM core.mensaje WHERE id = p_mensaje_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Mensaje no encontrado'));
  END IF;
  IF v.autor_id IS DISTINCT FROM p_user_id AND NOT p_is_super_admin THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('FORBIDDEN','Sólo el autor puede editar su mensaje'));
  END IF;
  IF v.estado = 'retirado' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','El mensaje fue retirado'));
  END IF;

  UPDATE core.mensaje
     SET cuerpo_anterior = coalesce(cuerpo_anterior, cuerpo),
         cuerpo = btrim(p_cuerpo), estado = 'editado', editado_at = now()
   WHERE id = p_mensaje_id;

  SELECT ot_id INTO v_ot FROM core.conversacion WHERE id = v.conversacion_id;
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'editar', 'mensaje', v.id,
    jsonb_build_object('cuerpo', v.cuerpo), jsonb_build_object('cuerpo', btrim(p_cuerpo)));
  PERFORM app.sp_ot_trazabilidad_refrescar(v_ot, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('editado', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Retirar es LÓGICO: no se elimina el rastro de que el mensaje existió (cap. 30.2).
CREATE OR REPLACE FUNCTION app.sp_mensaje_retirar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_mensaje_id UUID, p_motivo TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v core.mensaje%ROWTYPE; v_ot UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT * INTO v FROM core.mensaje WHERE id = p_mensaje_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Mensaje no encontrado'));
  END IF;
  IF v.autor_id IS DISTINCT FROM p_user_id AND NOT p_is_super_admin THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('FORBIDDEN','Sólo el autor o un administrador puede retirar el mensaje'));
  END IF;

  UPDATE core.mensaje
     SET estado = 'retirado', retirado_at = now(), retirado_por = p_user_id,
         cuerpo_anterior = coalesce(cuerpo_anterior, cuerpo)
   WHERE id = p_mensaje_id;

  SELECT ot_id INTO v_ot FROM core.conversacion WHERE id = v.conversacion_id;
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'retirar', 'mensaje', v.id,
                                       jsonb_build_object('cuerpo', v.cuerpo), NULL, p_motivo);
  PERFORM app.sp_ot_trazabilidad_refrescar(v_ot, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('retirado', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- El coordinador invita participantes y decide su visibilidad (cap. 30.1).
CREATE OR REPLACE FUNCTION app.sp_conversacion_invitar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_usuario_id UUID,
  p_puede_escribir BOOLEAN DEFAULT true, p_ve_notas_internas BOOLEAN DEFAULT false)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE c core.conversacion%ROWTYPE; o core.orden_trabajo%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'conversacion:invitar');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  SELECT * INTO c FROM core.conversacion WHERE ot_id = p_ot_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no tiene conversación'));
  END IF;

  INSERT INTO core.conversacion_participante (tenant_id, conversacion_id, usuario_id,
                                              puede_escribir, ve_notas_internas, invitado_por)
  VALUES (p_tenant_id, c.id, p_usuario_id, coalesce(p_puede_escribir,true),
          coalesce(p_ve_notas_internas,false), p_user_id)
  ON CONFLICT (conversacion_id, usuario_id) DO UPDATE
    SET puede_escribir = EXCLUDED.puede_escribir,
        ve_notas_internas = EXCLUDED.ve_notas_internas,
        activo = true, updated_at = now();

  PERFORM internal.notificar(p_tenant_id, p_usuario_id, 'conversacion_invitado',
    format('Se le incorporó a la conversación de la OT %s', o.numero_ot),
    NULL, p_ot_id, 'conversacion', c.id);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('invitado', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Línea de tiempo unificada: mensajes humanos + eventos de sistema, ordenados
-- juntos pero DIFERENCIADOS por tipo, tal como pide el cap. 13.
CREATE OR REPLACE FUNCTION app.fn_ot_linea_tiempo(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_ot_id UUID)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB; v_ve_internas BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:ver');

  SELECT coalesce(bool_or(pp.ve_notas_internas), false) INTO v_ve_internas
    FROM core.conversacion_participante pp
    JOIN core.conversacion c ON c.id = pp.conversacion_id
   WHERE c.ot_id = p_ot_id AND pp.usuario_id = p_user_id;
  v_ve_internas := v_ve_internas OR p_is_super_admin;

  SELECT coalesce(jsonb_agg(x ORDER BY (x->>'fecha')), '[]'::jsonb) INTO v FROM (
    SELECT jsonb_build_object(
             'clase','mensaje', 'tipo', m.tipo, 'id', m.id,
             'cuerpo', CASE WHEN m.estado='retirado' THEN NULL ELSE m.cuerpo END,
             'visibilidad', m.visibilidad, 'estado', m.estado,
             'autor', u.nombres||' '||u.apellidos, 'fecha', m.created_at) AS x
      FROM core.mensaje m
      JOIN core.conversacion c ON c.id = m.conversacion_id
      LEFT JOIN core.usuario u ON u.id = m.autor_id
     WHERE c.ot_id = p_ot_id
       AND (v_ve_internas OR m.visibilidad <> 'interna')
    UNION ALL
    SELECT jsonb_build_object(
             'clase','evento', 'tipo','sistema', 'id', e.id::text,
             'dominio', e.dominio, 'evento', e.evento,
             'anterior', e.valor_anterior, 'nuevo', e.valor_nuevo, 'motivo', e.motivo,
             'autor', eu.nombres||' '||eu.apellidos, 'fecha', e.created_at) AS x
      FROM core.ot_evento e LEFT JOIN core.usuario eu ON eu.id = e.actor_id
     WHERE e.ot_id = p_ot_id
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
