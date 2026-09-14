-- =============================================================================
-- 30_app_cierre.sql · Revisión, cierre y reapertura (cap. 14, 31.2)
--
-- El punto delicado del producto: la OT PUEDE cerrarse con pendientes
-- administrativos (sin OC, sin liberación total), pero sólo si el coordinador
-- confirma explícitamente que revisó el seguimiento y deja constancia escrita
-- del pendiente (cap. 14.3, 31.2, QA-19).
--
-- Y al revés: actualizar la OC o la liberación después NO reabre la OT (QA-20).
-- Eso lo garantiza el trigger de estado administrativo, que está exento de la
-- guarda de OT cerrada.
-- =============================================================================
SET search_path = app, core, internal, public;

-- ── Revisión del coordinador (cap. 14.2) ─────────────────────────────────────
CREATE OR REPLACE FUNCTION app.sp_trabajo_revisar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_resultado TEXT, p_observacion TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  t core.trabajo_realizado%ROWTYPE;
  v_res core.resultado_revision := p_resultado::core.resultado_revision;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:revisar');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF o.estado <> 'trabajo_realizado' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE','Sólo se revisa una OT en trabajo realizado'));
  END IF;

  SELECT * INTO t FROM core.trabajo_realizado WHERE ot_id = p_ot_id AND vigente;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('NOT_FOUND','No hay trabajo realizado vigente que revisar'));
  END IF;

  -- Devolver a corrección exige observación: el ejecutor tiene que saber qué
  -- corregir (cap. 14.2, QA-14).
  IF v_res = 'correccion_solicitada' AND btrim(coalesce(p_observacion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','Solicitar correcciones exige registrar la observación','observacion'));
  END IF;

  UPDATE core.trabajo_realizado
     SET resultado_revision = v_res, revision_observacion = p_observacion,
         revisado_por = p_user_id, revisado_at = now(), updated_by = p_user_id
   WHERE id = t.id;

  IF v_res = 'correccion_solicitada' THEN
    UPDATE core.orden_trabajo SET estado = 'en_trabajo', fecha_termino_real = NULL, updated_by = p_user_id
     WHERE id = p_ot_id;
    INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id, motivo_texto)
    VALUES (p_tenant_id, p_ot_id, 'trabajo_realizado', 'en_trabajo', p_user_id, p_observacion);

    PERFORM internal.notificar(p_tenant_id, coalesce(t.declarado_por, o.ejecutor_id),
      'correccion_solicitada', format('Se solicitaron correcciones en la OT %s', o.numero_ot),
      p_observacion, p_ot_id, 'trabajo_realizado', t.id);
  END IF;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'trabajo_revisado',
    p_user_id, 'trabajo_realizado', t.id, NULL,
    jsonb_build_object('resultado', v_res), p_observacion);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'revisar', 'trabajo_realizado',
                                       t.id, NULL, jsonb_build_object('resultado', v_res), p_observacion);
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'resultado', v_res,
    'estado', CASE WHEN v_res = 'correccion_solicitada' THEN 'en_trabajo' ELSE o.estado END));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Conformidad del solicitante: opcional, NO bloquea el cierre (cap. 14.2).
CREATE OR REPLACE FUNCTION app.sp_conformidad_registrar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_conformidad TEXT, p_comentario TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE t core.trabajo_realizado%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT * INTO t FROM core.trabajo_realizado WHERE ot_id = p_ot_id AND vigente;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('NOT_FOUND','Aún no hay trabajo realizado sobre el que pronunciarse'));
  END IF;

  UPDATE core.trabajo_realizado
     SET conformidad = p_conformidad::core.conformidad_solicitante,
         conformidad_comentario = p_comentario, conformidad_at = now(), updated_by = p_user_id
   WHERE id = t.id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'conformidad_registrada',
    p_user_id, 'trabajo_realizado', t.id, NULL,
    jsonb_build_object('conformidad', p_conformidad), p_comentario);
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('conformidad', p_conformidad));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── AD-01 · Cerrar, con o sin pendientes administrativos ────────────────────
CREATE OR REPLACE FUNCTION app.sp_ot_cerrar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_admin_revisado BOOLEAN DEFAULT false,
  p_observacion_pendiente TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_admin core.estado_administrativo;
  v_hay_pendiente BOOLEAN;
  v_secuencia INT;
  v_cierre core.ot_cierre%ROWTYPE;
  v_hijas JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:cerrar');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  -- Exige revisión aprobada y derivadas bloqueantes resueltas (Anexo A, QA-16).
  PERFORM internal.validar_transicion_ot(p_ot_id, o.estado, 'cerrada', NULL);

  v_admin := core.consolidar_estado_administrativo(p_ot_id);
  v_hay_pendiente := v_admin <> 'administracion_completa';

  -- La regla que define el producto: se PUEDE cerrar con pendiente, pero sólo con
  -- confirmación explícita y observación escrita (cap. 31.2, QA-19).
  IF v_hay_pendiente THEN
    IF NOT coalesce(p_admin_revisado,false) THEN
      RETURN jsonb_build_object('ok', false,
        'error', internal.error_jsonb('BUSINESS_RULE',
          format('El seguimiento administrativo está en "%s". Confirme que lo revisó para poder cerrar.', v_admin)),
        'data', jsonb_build_object('estado_administrativo', v_admin,
                                   'requiere_confirmacion', true));
    END IF;
    IF btrim(coalesce(p_observacion_pendiente,'')) = '' THEN
      RETURN jsonb_build_object('ok', false,
        'error', internal.error_jsonb('VALIDATION',
          'Cerrar con pendiente administrativo exige una observación que lo explique','observacion_pendiente'));
    END IF;
  END IF;

  -- Derivadas NO bloqueantes que siguen abiertas: no impiden el cierre, pero se
  -- muestran como pendiente visible (cap. 27.2).
  SELECT coalesce(jsonb_agg(jsonb_build_object('numero', h.numero_ot, 'estado', h.estado)), '[]'::jsonb)
    INTO v_hijas
    FROM core.orden_trabajo h
   WHERE h.ot_padre_id = p_ot_id AND h.deleted_at IS NULL
     AND h.estado NOT IN ('cerrada','cancelada');

  SELECT coalesce(max(secuencia),0)+1 INTO v_secuencia FROM core.ot_cierre WHERE ot_id = p_ot_id;
  UPDATE core.ot_cierre SET vigente = false WHERE ot_id = p_ot_id AND vigente;

  INSERT INTO core.ot_cierre (
    tenant_id, ot_id, secuencia, vigente, cerrado_por, admin_revisado,
    estado_admin_al_cierre, observacion_pendiente, derivadas_bloqueantes_resueltas)
  VALUES (p_tenant_id, p_ot_id, v_secuencia, true, p_user_id, coalesce(p_admin_revisado,false),
          v_admin, p_observacion_pendiente, true)
  RETURNING * INTO v_cierre;

  UPDATE core.orden_trabajo
     SET estado = 'cerrada', fecha_cierre = now(), updated_by = p_user_id
   WHERE id = p_ot_id;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id, motivo_texto)
  VALUES (p_tenant_id, p_ot_id, o.estado, 'cerrada', p_user_id, p_observacion_pendiente);

  -- Tras cerrar, la conversación queda en solo lectura (cap. 30.2).
  UPDATE core.conversacion SET solo_lectura = true WHERE ot_id = p_ot_id;

  UPDATE core.seguimiento_administrativo
     SET revisado_por = CASE WHEN p_admin_revisado THEN p_user_id ELSE revisado_por END,
         revisado_at  = CASE WHEN p_admin_revisado THEN now() ELSE revisado_at END,
         observacion  = coalesce(p_observacion_pendiente, observacion),
         updated_by   = p_user_id
   WHERE ot_id = p_ot_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ot', 'ot_cerrada', p_user_id,
    'ot_cierre', v_cierre.id, jsonb_build_object('estado', o.estado),
    jsonb_build_object('estado','cerrada','estado_administrativo', v_admin,
                       'con_pendiente', v_hay_pendiente), p_observacion_pendiente);

  PERFORM internal.notificar(p_tenant_id,
    (SELECT solicitante_id FROM core.solicitud_trabajo WHERE id = o.solicitud_origen_id),
    'ot_cerrada', format('La OT %s fue cerrada', o.numero_ot), NULL, p_ot_id, 'orden_trabajo', p_ot_id);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'cerrar', 'orden_trabajo',
    p_ot_id, jsonb_build_object('estado', o.estado),
    jsonb_build_object('estado','cerrada','estado_administrativo', v_admin), p_observacion_pendiente);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  IF o.ot_padre_id IS NOT NULL THEN
    PERFORM app.sp_ot_trazabilidad_refrescar(o.ot_padre_id, true);
  END IF;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado','cerrada',
    'estado_administrativo', v_admin,
    -- El indicador combinado que se muestra en listas y tablero (cap. 14.3):
    -- por ejemplo 'CERRADA - OC PENDIENTE'.
    'indicador', CASE WHEN v_hay_pendiente
                      THEN 'CERRADA - ' || upper(replace(v_admin::text,'_',' '))
                      ELSE 'CERRADA' END,
    'derivadas_no_bloqueantes_abiertas', v_hijas,
    'secuencia_cierre', v_secuencia));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── Reapertura (cap. 14.4, QA-22) ───────────────────────────────────────────
-- El cierre anterior NUNCA se elimina: se marca como no vigente y queda en el
-- árbol junto a la reapertura que lo revirtió.
CREATE OR REPLACE FUNCTION app.sp_ot_reabrir(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_motivo_texto TEXT, p_estado_retorno TEXT DEFAULT 'en_trabajo',
  p_motivo_id UUID DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  c core.ot_cierre%ROWTYPE;
  v core.ot_reapertura%ROWTYPE;
  v_retorno core.ot_estado := p_estado_retorno::core.ot_estado;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:reabrir');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF o.estado <> 'cerrada' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','Sólo se reabre una OT cerrada'));
  END IF;
  IF btrim(coalesce(p_motivo_texto,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La reapertura exige motivo obligatorio','motivo_texto'));
  END IF;

  PERFORM internal.validar_transicion_ot(p_ot_id, 'cerrada', v_retorno, p_motivo_texto);

  SELECT * INTO c FROM core.ot_cierre WHERE ot_id = p_ot_id AND vigente;

  INSERT INTO core.ot_reapertura (tenant_id, ot_id, cierre_id, motivo_id, motivo_texto,
                                  estado_retorno, reabierta_por)
  VALUES (p_tenant_id, p_ot_id, c.id, p_motivo_id, btrim(p_motivo_texto), v_retorno, p_user_id)
  RETURNING * INTO v;

  -- El cierre deja de ser el vigente, pero la fila permanece con todos sus datos.
  UPDATE core.ot_cierre SET vigente = false WHERE id = c.id;

  -- Aquí sí hay que levantar la guarda: es exactamente el caso legítimo previsto
  -- por el cap. 21.3, "una OT cerrada sólo cambia mediante reapertura auditada".
  PERFORM set_config('mip.permitir_update_cerrada', 'on', true);
  UPDATE core.orden_trabajo
     SET estado = v_retorno, fecha_cierre = NULL,
         veces_reabierta = veces_reabierta + 1, updated_by = p_user_id
   WHERE id = p_ot_id;
  PERFORM set_config('mip.permitir_update_cerrada', 'off', true);

  UPDATE core.conversacion SET solo_lectura = false WHERE ot_id = p_ot_id;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo,
                                        motivo_id, motivo_texto, actor_id)
  VALUES (p_tenant_id, p_ot_id, 'cerrada', v_retorno, p_motivo_id, p_motivo_texto, p_user_id);

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ot', 'ot_reabierta', p_user_id,
    'ot_reapertura', v.id, jsonb_build_object('estado','cerrada','cierre_secuencia', c.secuencia),
    jsonb_build_object('estado', v_retorno), p_motivo_texto);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'reabrir', 'orden_trabajo',
    p_ot_id, jsonb_build_object('estado','cerrada'), jsonb_build_object('estado', v_retorno), p_motivo_texto);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado', v_retorno, 'veces_reabierta', o.veces_reabierta + 1,
    'cierre_conservado', c.secuencia));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
