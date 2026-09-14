-- =============================================================================
-- 29_app_ejecucion.sql · Ejecución, avances, incidencias y pausas (cap. 12, 29)
--
-- Dos formas de arrancar (cap. 29.1):
--   Normal      · cotización vigente + responsable + inicio real + confirmación.
--   Emergencia  · bandera + justificación + responsable + inicio real. La
--                 cotización y la SOLPED pueden faltar, pero queda marcada la
--                 REGULARIZACIÓN PENDIENTE. La emergencia cambia el orden
--                 administrativo; no lo elimina.
-- =============================================================================
SET search_path = app, core, internal, public;

CREATE OR REPLACE FUNCTION app.sp_ejecucion_iniciar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_responsable_id UUID, p_inicio_real TIMESTAMPTZ DEFAULT NULL,
  p_observaciones TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_inicio TIMESTAMPTZ := coalesce(p_inicio_real, now());
  v_hay_cotiz BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ejecucion:iniciar');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);

  IF p_responsable_id IS NULL THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El inicio exige responsable de ejecución','responsable_id'));
  END IF;
  IF v_inicio > now() THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El inicio real no puede estar en el futuro','inicio_real'));
  END IF;

  SELECT EXISTS (SELECT 1 FROM core.cotizacion c
                  WHERE c.ot_id = p_ot_id AND c.vigente AND NOT c.invalidada)
    INTO v_hay_cotiz;

  -- El ejecutor debe estar fijado antes de que validar_transicion_ot lo compruebe.
  UPDATE core.orden_trabajo
     SET ejecutor_id = p_responsable_id, fecha_inicio_real = v_inicio, updated_by = p_user_id
   WHERE id = p_ot_id;

  PERFORM internal.validar_transicion_ot(p_ot_id, o.estado, 'en_trabajo', p_observaciones);

  INSERT INTO core.ejecucion (tenant_id, ot_id, responsable_id, inicio_real, confirmado_por,
                              inicio_sin_cotizacion, observaciones, created_by, updated_by)
  VALUES (p_tenant_id, p_ot_id, p_responsable_id, v_inicio, p_user_id,
          NOT v_hay_cotiz, p_observaciones, p_user_id, p_user_id)
  ON CONFLICT (ot_id) DO UPDATE
    SET responsable_id = EXCLUDED.responsable_id,
        inicio_real    = EXCLUDED.inicio_real,
        confirmado_por = EXCLUDED.confirmado_por,
        updated_at     = now();

  UPDATE core.orden_trabajo
     SET estado = 'en_trabajo',
         -- Arrancar sin cotización deja pendiente la regularización, siempre.
         regularizacion_pendiente = CASE WHEN NOT v_hay_cotiz THEN true ELSE regularizacion_pendiente END,
         updated_by = p_user_id
   WHERE id = p_ot_id;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id, motivo_texto)
  VALUES (p_tenant_id, p_ot_id, o.estado, 'en_trabajo', p_user_id,
          CASE WHEN NOT v_hay_cotiz THEN 'Inicio en emergencia, sin cotización vigente' END);

  INSERT INTO core.conversacion_participante (tenant_id, conversacion_id, usuario_id, ve_notas_internas)
  SELECT p_tenant_id, c.id, p_responsable_id, false FROM core.conversacion c WHERE c.ot_id = p_ot_id
  ON CONFLICT DO NOTHING;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'ejecucion_iniciada',
    p_user_id, 'ejecucion', p_ot_id, jsonb_build_object('estado', o.estado),
    jsonb_build_object('estado','en_trabajo','inicio_real', v_inicio,
                       'sin_cotizacion', NOT v_hay_cotiz), p_observaciones);

  PERFORM internal.notificar(p_tenant_id, p_responsable_id, 'ot_asignada',
    format('Inició la ejecución de la OT %s', o.numero_ot), NULL, p_ot_id, 'orden_trabajo', p_ot_id);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'iniciar', 'ejecucion', p_ot_id);
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado','en_trabajo', 'inicio_real', v_inicio,
    'regularizacion_pendiente', NOT v_hay_cotiz));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── EJ-01 · Registrar avance ─────────────────────────────────────────────────
-- Un avance es narrativo. El porcentaje NO es obligatorio y el avance por sí solo
-- no cambia el estado de la OT (cap. 29.2).
CREATE OR REPLACE FUNCTION app.sp_avance_registrar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_descripcion TEXT, p_porcentaje NUMERIC DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE o core.orden_trabajo%ROWTYPE; v core.ot_avance%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ejecucion:avanzar');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF o.estado NOT IN ('en_trabajo','trabajo_realizado') THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE', format('No se registran avances con la OT en %s', o.estado)));
  END IF;
  IF btrim(coalesce(p_descripcion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El avance exige una descripción','descripcion'));
  END IF;

  INSERT INTO core.ot_avance (tenant_id, ot_id, descripcion, porcentaje, autor_id)
  VALUES (p_tenant_id, p_ot_id, btrim(p_descripcion), p_porcentaje, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'avance_registrado',
    p_user_id, 'ot_avance', v.id, NULL,
    jsonb_build_object('porcentaje', p_porcentaje));

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_incidencia_registrar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_descripcion TEXT, p_tipo_id UUID DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE o core.orden_trabajo%ROWTYPE; v core.ot_incidencia%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ejecucion:avanzar');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  INSERT INTO core.ot_incidencia (tenant_id, ot_id, tipo_id, descripcion, autor_id)
  VALUES (p_tenant_id, p_ot_id, p_tipo_id, btrim(p_descripcion), p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'incidencia_registrada',
    p_user_id, 'ot_incidencia', v.id, NULL, jsonb_build_object('descripcion', p_descripcion));

  -- Una incidencia es algo sobre lo que el coordinador puede tener que actuar.
  IF o.coordinador_id IS DISTINCT FROM p_user_id THEN
    PERFORM internal.notificar(p_tenant_id, o.coordinador_id, 'incidencia_registrada',
      format('Incidencia en la OT %s', o.numero_ot), p_descripcion, p_ot_id, 'ot_incidencia', v.id);
  END IF;

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── EJ-02 · Pausa y reanudación (cap. 29.3) ─────────────────────────────────
CREATE OR REPLACE FUNCTION app.sp_pausa_registrar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_motivo_texto TEXT, p_motivo_id UUID DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE o core.orden_trabajo%ROWTYPE; v core.ot_pausa%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ejecucion:pausar');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF o.estado <> 'en_trabajo' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','Sólo se pausa una OT en trabajo'));
  END IF;
  IF btrim(coalesce(p_motivo_texto,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La pausa exige motivo','motivo_texto'));
  END IF;

  -- No se permite una nueva pausa si hay una vigente: evita intervalos ambiguos
  -- (cap. 29.3, QA-12). El índice único lo garantiza; aquí damos el mensaje claro.
  IF EXISTS (SELECT 1 FROM core.ot_pausa WHERE ot_id = p_ot_id AND fecha_reanudacion IS NULL) THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'CONFLICT','La OT ya tiene una pausa vigente. Reanude antes de volver a pausar'));
  END IF;

  INSERT INTO core.ot_pausa (tenant_id, ot_id, motivo_id, motivo_texto, pausada_por)
  VALUES (p_tenant_id, p_ot_id, p_motivo_id, btrim(p_motivo_texto), p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'pausa_registrada',
    p_user_id, 'ot_pausa', v.id, NULL, jsonb_build_object('fecha_pausa', v.fecha_pausa), p_motivo_texto);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  -- La condición 'pausada' la pone el trigger trg_pausa_condicion.
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'fecha_pausa', v.fecha_pausa, 'condicion', 'pausada'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_pausa_reanudar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_observacion TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v core.ot_pausa%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ejecucion:pausar');

  SELECT * INTO v FROM core.ot_pausa WHERE ot_id = p_ot_id AND fecha_reanudacion IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('NOT_FOUND','La OT no tiene una pausa vigente'));
  END IF;

  UPDATE core.ot_pausa
     SET fecha_reanudacion = now(), reanudada_por = p_user_id,
         observacion_reanudacion = p_observacion
   WHERE id = v.id
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'pausa_reanudada',
    p_user_id, 'ot_pausa', v.id, jsonb_build_object('fecha_pausa', v.fecha_pausa),
    jsonb_build_object('fecha_reanudacion', v.fecha_reanudacion), p_observacion);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'fecha_reanudacion', v.fecha_reanudacion, 'condicion','activa'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── EJ-03 · Declarar trabajo realizado (cap. 29.4) ──────────────────────────
CREATE OR REPLACE FUNCTION app.sp_trabajo_realizado_declarar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_descripcion TEXT, p_fecha_termino TIMESTAMPTZ DEFAULT NULL,
  p_resultado_id UUID DEFAULT NULL, p_resultado_texto TEXT DEFAULT NULL,
  p_observaciones TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v core.trabajo_realizado%ROWTYPE;
  v_version INT;
  v_termino TIMESTAMPTZ := coalesce(p_fecha_termino, now());
  v_inicio  TIMESTAMPTZ;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ejecucion:declarar_trabajo');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF btrim(coalesce(p_descripcion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Describa el trabajo realizado','descripcion'));
  END IF;

  SELECT inicio_real INTO v_inicio FROM core.ejecucion WHERE ot_id = p_ot_id;
  IF v_inicio IS NOT NULL AND v_termino < v_inicio THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','El término no puede ser anterior al inicio','fecha_termino'));
  END IF;

  -- Valida también que no haya una pausa vigente sin resolver (QA-13).
  PERFORM internal.validar_transicion_ot(p_ot_id, o.estado, 'trabajo_realizado', NULL);

  SELECT coalesce(max(version),0)+1 INTO v_version FROM core.trabajo_realizado WHERE ot_id = p_ot_id;
  UPDATE core.trabajo_realizado SET vigente = false, updated_by = p_user_id
   WHERE ot_id = p_ot_id AND vigente;

  INSERT INTO core.trabajo_realizado (
    tenant_id, ot_id, version, vigente, descripcion, resultado_id, resultado_texto,
    fecha_termino, observaciones, declarado_por, created_by, updated_by)
  VALUES (p_tenant_id, p_ot_id, v_version, true, btrim(p_descripcion),
          p_resultado_id, p_resultado_texto, v_termino, p_observaciones,
          p_user_id, p_user_id, p_user_id)
  RETURNING * INTO v;

  UPDATE core.ejecucion SET termino_real = v_termino, updated_by = p_user_id WHERE ot_id = p_ot_id;
  UPDATE core.orden_trabajo
     SET estado = 'trabajo_realizado', fecha_termino_real = v_termino, updated_by = p_user_id
   WHERE id = p_ot_id;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id)
  VALUES (p_tenant_id, p_ot_id, o.estado, 'trabajo_realizado', p_user_id);

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'trabajo_declarado',
    p_user_id, 'trabajo_realizado', v.id, jsonb_build_object('estado', o.estado),
    jsonb_build_object('estado','trabajo_realizado','version', v_version,'termino', v_termino));

  -- El coordinador DEBE revisar: es lo siguiente que tiene que ocurrir (cap. 14.1).
  PERFORM internal.notificar(p_tenant_id, o.coordinador_id, 'trabajo_realizado',
    format('La OT %s está declarada como trabajo realizado', o.numero_ot),
    'Requiere su revisión para poder cerrarse.', p_ot_id, 'trabajo_realizado', v.id);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'declarar', 'trabajo_realizado',
                                       v.id, NULL, to_jsonb(v));
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'version', v_version, 'estado','trabajo_realizado'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
