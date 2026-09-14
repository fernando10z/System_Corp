-- =============================================================================
-- 27_app_diagnosticos.sql · Diagnóstico y planificación técnica (cap. 9, 26)
--
-- Regla central: un cambio de diagnóstico NO sobrescribe la historia. Cada
-- guardado formal crea una versión y la anterior se conserva con su autor, fecha
-- y motivo de sustitución (cap. 9, QA-06).
--
-- No toda corrección de diagnóstico exige crear una OT derivada: la hija se usa
-- para dividir trabajo, alcance, proveedor o contratación (cap. 9, 27.1).
-- =============================================================================
SET search_path = app, core, internal, public;

-- ── DG-01 · Registrar diagnóstico ────────────────────────────────────────────
CREATE OR REPLACE FUNCTION app.sp_diagnostico_registrar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_diagnostico TEXT, p_causa_probable TEXT,
  p_alcance TEXT, p_trabajo_a_realizar TEXT,
  p_observaciones TEXT DEFAULT NULL, p_lecturas_instrumentos TEXT DEFAULT NULL,
  p_motivo_cambio TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_vigente core.diagnostico%ROWTYPE;
  v core.diagnostico%ROWTYPE;
  v_version INT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'diagnosticos:registrar');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);

  -- Sólo en CREADA/EN DIAGNOSTICO, salvo reapertura o permiso especial (cap. 26.1).
  IF o.estado NOT IN ('creada','en_diagnostico','en_cotizacion','en_trabajo') THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE', format('No se registra diagnóstico con la OT en %s', o.estado)));
  END IF;

  -- Los cuatro campos técnicos son obligatorios (cap. 9, QA-07).
  IF btrim(coalesce(p_diagnostico,'')) = '' OR btrim(coalesce(p_causa_probable,'')) = ''
     OR btrim(coalesce(p_alcance,'')) = '' OR btrim(coalesce(p_trabajo_a_realizar,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','Diagnóstico, causa probable, alcance y trabajo a realizar son obligatorios'));
  END IF;

  SELECT * INTO v_vigente FROM core.diagnostico WHERE ot_id = p_ot_id AND vigente;

  -- A partir de la segunda versión el motivo del cambio es obligatorio: es lo que
  -- permite entender después por qué evolucionó el diagnóstico (QA-06).
  IF v_vigente.id IS NOT NULL AND btrim(coalesce(p_motivo_cambio,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','Reemplazar el diagnóstico vigente exige explicar el motivo del cambio','motivo_cambio'));
  END IF;

  SELECT coalesce(max(version),0)+1 INTO v_version FROM core.diagnostico WHERE ot_id = p_ot_id;

  -- Bajar la vigencia ANTES de insertar: el índice único parcial garantiza que
  -- nunca haya dos vigentes, así que el orden importa.
  UPDATE core.diagnostico SET vigente = false, updated_by = p_user_id
   WHERE ot_id = p_ot_id AND vigente;

  INSERT INTO core.diagnostico (
    tenant_id, ot_id, version, vigente, diagnostico, causa_probable, alcance,
    trabajo_a_realizar, observaciones, lecturas_instrumentos, autor_id,
    motivo_cambio, reemplaza_a, created_by, updated_by)
  VALUES (
    p_tenant_id, p_ot_id, v_version, true,
    btrim(p_diagnostico), btrim(p_causa_probable), btrim(p_alcance), btrim(p_trabajo_a_realizar),
    p_observaciones,
    -- Las lecturas de instrumentos se guardan como TEXTO. El MVP no modela
    -- unidades ni series medibles, y hacerlo aquí sería inventar alcance (cap. 9).
    p_lecturas_instrumentos,
    p_user_id, p_motivo_cambio, v_vigente.id, p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'diagnostico',
    CASE WHEN v_vigente.id IS NULL THEN 'diagnostico_creado' ELSE 'diagnostico_reemplazado' END,
    p_user_id, 'diagnostico', v.id,
    CASE WHEN v_vigente.id IS NOT NULL THEN jsonb_build_object('version', v_vigente.version) END,
    jsonb_build_object('version', v_version), p_motivo_cambio);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id,
    CASE WHEN v_vigente.id IS NULL THEN 'crear' ELSE 'reemplazar' END,
    'diagnostico', v.id, to_jsonb(v_vigente), to_jsonb(v), p_motivo_cambio);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'version', v_version, 'reemplaza_a', v_vigente.id));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- El coordinador puede aprobar el diagnóstico de un técnico (cap. 26.1).
CREATE OR REPLACE FUNCTION app.sp_diagnostico_aprobar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_diagnostico_id UUID, p_observacion TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE d core.diagnostico%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'diagnosticos:aprobar');

  SELECT * INTO d FROM core.diagnostico WHERE id = p_diagnostico_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Diagnóstico no encontrado'));
  END IF;
  IF NOT d.vigente THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE','Sólo se aprueba el diagnóstico vigente'));
  END IF;

  UPDATE core.diagnostico
     SET aprobado_por = p_user_id, aprobado_at = now(),
         observaciones = coalesce(nullif(btrim(coalesce(p_observacion,'')),''), observaciones),
         updated_by = p_user_id
   WHERE id = p_diagnostico_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, d.ot_id, 'diagnostico', 'diagnostico_aprobado',
    p_user_id, 'diagnostico', d.id, NULL, jsonb_build_object('version', d.version), p_observacion);
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'aprobar', 'diagnostico', d.id);
  PERFORM app.sp_ot_trazabilidad_refrescar(d.ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('aprobado', true, 'version', d.version));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.fn_diagnostico_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_ot_id UUID)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  RETURN jsonb_build_object('ok', true, 'data', internal.fn_ot_diagnosticos(p_ot_id));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
