-- =============================================================================
-- 31_app_administrativo.sql · SOLPED, OC y liberación (cap. 15, 22, 31)
--
-- SOBRE SAP — leer antes de tocar nada aquí:
--
-- El cap. 22.4 deja EXPLÍCITAMENTE pendientes los campos exactos de SOLPED, la
-- versión de SAP por cliente, las APIs, las imputaciones y los desarrollos Z. El
-- cap. 38 cierra con una regla de gobernanza: "una decisión pendiente no debe
-- resolverse con un supuesto de desarrollador".
--
-- Por eso aquí hay estructura y flujo manual, pero NO hay conector:
--   · El formulario interno es JSONB, porque su forma la define cada cliente.
--   · El botón "Crear SOLPED" prepara el registro y lo deja LISTA_PARA_ENVIAR.
--   · El número SAP se captura A MANO hasta que exista integración.
--   · MIP nunca modifica ni elimina un documento SAP ya creado (cap. 15.1, 22.2).
-- =============================================================================
SET search_path = app, core, internal, public;

-- ── SOLPED ───────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION app.sp_solped_preparar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_formulario JSONB DEFAULT '{}'::jsonb,
  p_cotizacion_id UUID DEFAULT NULL, p_numero_interno TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v core.solped%ROWTYPE;
  v_version INT;
  v_cotiz core.cotizacion%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:solped');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  SELECT * INTO v_cotiz FROM core.cotizacion
   WHERE id = coalesce(p_cotizacion_id,
                       (SELECT id FROM core.cotizacion
                         WHERE ot_id = p_ot_id AND vigente AND NOT invalidada LIMIT 1));

  SELECT coalesce(max(version),0)+1 INTO v_version FROM core.solped WHERE ot_id = p_ot_id;
  UPDATE core.solped SET vigente = false, updated_by = p_user_id
   WHERE ot_id = p_ot_id AND vigente AND NOT anulada;

  INSERT INTO core.solped (
    tenant_id, ot_id, version, vigente, numero_interno, referencia_externa,
    estado_integracion, formulario, cotizacion_id, monto, moneda,
    fecha_solped, created_by, updated_by)
  VALUES (
    p_tenant_id, p_ot_id, v_version, true,
    coalesce(p_numero_interno, o.numero_ot || '-SP' || v_version),
    -- Clave de idempotencia: si algún día el conector no sabe si SAP creó el
    -- documento, se consulta por esta referencia en vez de arriesgar un duplicado
    -- (cap. 22.3, estado CONFIRMACION PENDIENTE).
    o.numero_ot || '-' || v_version || '-' || substr(gen_random_uuid()::text, 1, 8),
    'borrador', coalesce(p_formulario,'{}'::jsonb), v_cotiz.id,
    v_cotiz.monto, coalesce(v_cotiz.moneda,'PEN'), current_date, p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'administracion', 'solped_preparada',
    p_user_id, 'solped', v.id, NULL,
    jsonb_build_object('version', v_version, 'numero_interno', v.numero_interno));
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'preparar', 'solped', v.id, NULL, to_jsonb(v));
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'version', v_version, 'numero_interno', v.numero_interno,
    'estado_integracion', v.estado_integracion,
    'referencia_externa', v.referencia_externa));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- El botón "Crear SOLPED" del cap. 22.2. Sin conector, sólo valida y marca la
-- SOLPED como lista; el envío real llegará cuando el módulo esté definido.
CREATE OR REPLACE FUNCTION app.sp_solped_marcar_lista(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_solped_id UUID)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE s core.solped%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:solped');

  SELECT * INTO s FROM core.solped WHERE id = p_solped_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','SOLPED no encontrada'));
  END IF;
  IF s.anulada THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','La SOLPED está anulada'));
  END IF;
  IF s.estado_integracion <> 'borrador' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE', format('La SOLPED está en %s', s.estado_integracion)));
  END IF;

  UPDATE core.solped SET estado_integracion = 'lista_para_enviar', updated_by = p_user_id
   WHERE id = p_solped_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, s.ot_id, 'administracion', 'solped_lista',
    p_user_id, 'solped', s.id, jsonb_build_object('estado','borrador'),
    jsonb_build_object('estado','lista_para_enviar'));
  PERFORM app.sp_ot_trazabilidad_refrescar(s.ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado_integracion','lista_para_enviar',
    -- Se dice la verdad al usuario en lugar de fingir una integración que no existe.
    'nota','El conector SAP no está definido todavía (cap. 22.4). Registre el número SAP manualmente cuando Compras lo informe.'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Captura manual del número oficial devuelto por SAP (cap. 22.2, QA-29).
CREATE OR REPLACE FUNCTION app.sp_solped_registrar_numero_sap(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_solped_id UUID, p_numero_sap TEXT, p_observacion TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE s core.solped%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:solped');

  IF btrim(coalesce(p_numero_sap,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Indique el número SAP','numero_sap'));
  END IF;

  SELECT * INTO s FROM core.solped WHERE id = p_solped_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','SOLPED no encontrada'));
  END IF;

  -- Corregir un número ya confirmado es posible, pero SIEMPRE por flujo auditado
  -- (cap. 22.2): queda el valor anterior y el nuevo.
  UPDATE core.solped
     SET numero_sap = btrim(p_numero_sap), estado_integracion = 'creada_en_sap',
         fecha_solped = coalesce(fecha_solped, current_date), updated_by = p_user_id
   WHERE id = p_solped_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, s.ot_id, 'administracion', 'solped_numero_sap',
    p_user_id, 'solped', s.id,
    jsonb_build_object('numero_sap', s.numero_sap, 'estado', s.estado_integracion),
    jsonb_build_object('numero_sap', btrim(p_numero_sap), 'estado','creada_en_sap'), p_observacion);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'registrar_numero_sap', 'solped',
    s.id, jsonb_build_object('numero_sap', s.numero_sap),
    jsonb_build_object('numero_sap', btrim(p_numero_sap)), p_observacion);

  PERFORM app.sp_ot_trazabilidad_refrescar(s.ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'numero_sap', btrim(p_numero_sap), 'estado_integracion','creada_en_sap'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- "Eliminar SOLPED" en la interfaz es, internamente, una ANULACIÓN LÓGICA: el
-- registro permanece con su motivo y puede originar una nueva (cap. 15.1, QA-30).
CREATE OR REPLACE FUNCTION app.sp_solped_anular(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_solped_id UUID, p_motivo TEXT)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE s core.solped%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:solped');

  IF btrim(coalesce(p_motivo,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Anular la SOLPED exige motivo','motivo'));
  END IF;

  SELECT * INTO s FROM core.solped WHERE id = p_solped_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','SOLPED no encontrada'));
  END IF;

  UPDATE core.solped
     SET anulada = true, vigente = false, estado_integracion = 'reemplazada_anulada',
         motivo_anulacion = p_motivo, anulada_por = p_user_id, anulada_at = now(),
         updated_by = p_user_id
   WHERE id = p_solped_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, s.ot_id, 'administracion', 'solped_anulada',
    p_user_id, 'solped', s.id, jsonb_build_object('estado', s.estado_integracion, 'numero_sap', s.numero_sap),
    jsonb_build_object('estado','reemplazada_anulada'), p_motivo);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'anular', 'solped',
                                       s.id, to_jsonb(s), NULL, p_motivo);
  PERFORM app.sp_ot_trazabilidad_refrescar(s.ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'anulada', true,
    'nota', CASE WHEN s.numero_sap IS NOT NULL
      THEN 'El documento SAP no se modificó. MIP sólo anuló su registro interno; gestione la anulación en SAP manualmente.' END));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── Orden de compra: registro manual (cap. 15) ──────────────────────────────
-- Registrarla DESPUÉS del cierre no reabre la OT (cap. 14.3, QA-20).
CREATE OR REPLACE FUNCTION app.sp_orden_compra_registrar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_numero_oc TEXT, p_fecha_oc DATE DEFAULT NULL,
  p_monto NUMERIC DEFAULT NULL, p_moneda TEXT DEFAULT 'PEN',
  p_observacion TEXT DEFAULT NULL, p_solped_id UUID DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE o core.orden_trabajo%ROWTYPE; v core.orden_compra%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:oc');

  IF btrim(coalesce(p_numero_oc,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Indique el número de OC','numero_oc'));
  END IF;

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  INSERT INTO core.orden_compra (tenant_id, ot_id, solped_id, numero_oc, fecha_oc,
                                 monto, moneda, observacion, registrada_por, created_by, updated_by)
  VALUES (p_tenant_id, p_ot_id,
          coalesce(p_solped_id, (SELECT id FROM core.solped
                                  WHERE ot_id = p_ot_id AND vigente AND NOT anulada LIMIT 1)),
          btrim(p_numero_oc), p_fecha_oc, p_monto, coalesce(p_moneda,'PEN')::core.moneda_codigo,
          p_observacion, p_user_id, p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'administracion', 'oc_registrada',
    p_user_id, 'orden_compra', v.id, NULL,
    jsonb_build_object('numero_oc', v.numero_oc, 'monto', p_monto), p_observacion);
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'registrar', 'orden_compra',
                                       v.id, NULL, to_jsonb(v), p_observacion);
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'numero_oc', v.numero_oc,
    -- El trigger de estado administrativo ya recalculó el indicador.
    'estado_administrativo', (SELECT estado_administrativo FROM core.orden_trabajo WHERE id = p_ot_id),
    'ot_reabierta', false));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── Liberación: manual e historizada (cap. 31.3, QA-21) ─────────────────────
CREATE OR REPLACE FUNCTION app.sp_liberacion_registrar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_estado TEXT, p_monto NUMERIC,
  p_observacion TEXT DEFAULT NULL, p_orden_compra_id UUID DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v_anterior core.liberacion_historial%ROWTYPE;
  v core.liberacion_historial%ROWTYPE;
  v_nuevo core.estado_liberacion := p_estado::core.estado_liberacion;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:liberacion');

  IF coalesce(p_monto,0) < 0 THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El monto liberado no puede ser negativo','monto'));
  END IF;

  SELECT * INTO v_anterior FROM core.liberacion_historial
   WHERE ot_id = p_ot_id ORDER BY secuencia DESC LIMIT 1;

  -- Cada cambio guarda valor anterior, nuevo, usuario, fecha y observación.
  INSERT INTO core.liberacion_historial (
    tenant_id, ot_id, orden_compra_id, estado_anterior, estado_nuevo,
    monto_anterior, monto_nuevo, observacion, actor_id)
  VALUES (p_tenant_id, p_ot_id,
          coalesce(p_orden_compra_id, (SELECT id FROM core.orden_compra
                                        WHERE ot_id = p_ot_id AND NOT anulada
                                        ORDER BY created_at DESC LIMIT 1)),
          v_anterior.estado_nuevo, v_nuevo,
          v_anterior.monto_nuevo, coalesce(p_monto,0), p_observacion, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'administracion', 'liberacion_actualizada',
    p_user_id, 'liberacion_historial', v.id,
    jsonb_build_object('estado', v_anterior.estado_nuevo, 'monto', v_anterior.monto_nuevo),
    jsonb_build_object('estado', v_nuevo, 'monto', coalesce(p_monto,0)), p_observacion);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'registrar', 'liberacion',
    p_ot_id, jsonb_build_object('estado', v_anterior.estado_nuevo, 'monto', v_anterior.monto_nuevo),
    jsonb_build_object('estado', v_nuevo, 'monto', coalesce(p_monto,0)), p_observacion);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado', v_nuevo, 'monto_liberado', coalesce(p_monto,0),
    'estado_administrativo', (SELECT estado_administrativo FROM core.orden_trabajo WHERE id = p_ot_id),
    -- Advertencia que el cap. 31.3 exige no perder de vista.
    'nota','El monto liberado NO equivale al costo final de la OT.'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.fn_administrativo_obtener(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_ot_id UUID)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:ver');
  RETURN jsonb_build_object('ok', true, 'data', internal.fn_ot_administrativo(p_ot_id));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
