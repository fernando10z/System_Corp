-- =============================================================================
-- 28_app_cotizaciones.sql · Cotización seleccionada (cap. 11, 28)
--
-- MIP NO compara proveedores ni calcula puntajes de adjudicación. Esa gestión
-- ocurre fuera del sistema; MIP recibe la cotización FINAL YA ELEGIDA que
-- respalda la intervención (cap. 11).
--
-- Una vigente por OT. Si hay proveedores o alcances independientes, eso son OT
-- derivadas, no varias cotizaciones vigentes.
-- =============================================================================
SET search_path = app, core, internal, public;

-- ── CT-01 · Cargar cotización ────────────────────────────────────────────────
-- La firma cambió al añadir p_validez_dias. CREATE OR REPLACE no reemplaza una
-- función cuando varía el número de argumentos: crearía una segunda sobrecarga
-- y la llamada quedaría ambigua. Por eso se elimina la anterior primero.
DROP FUNCTION IF EXISTS app.sp_cotizacion_cargar(
  UUID, UUID, BOOLEAN, UUID, UUID, TEXT, TEXT, TEXT, DATE, NUMERIC, TEXT, INT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION app.sp_cotizacion_cargar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_proveedor_id UUID DEFAULT NULL,
  p_proveedor_nombre TEXT DEFAULT NULL, p_proveedor_ruc TEXT DEFAULT NULL,
  p_numero_cotizacion TEXT DEFAULT NULL, p_fecha_cotizacion DATE DEFAULT NULL,
  p_monto NUMERIC DEFAULT NULL, p_moneda TEXT DEFAULT 'PEN',
  p_plazo_ofrecido_dias INT DEFAULT NULL, p_validez_dias INT DEFAULT NULL,
  p_observaciones TEXT DEFAULT NULL, p_motivo_reemplazo TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_vigente core.cotizacion%ROWTYPE;
  v core.cotizacion%ROWTYPE;
  v_version INT;
  v_tenia_solped BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'cotizaciones:cargar');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);

  -- Se carga con la OT en cotización, o durante la regularización de una
  -- emergencia que arrancó sin ella (cap. 28.1).
  IF o.estado NOT IN ('en_cotizacion','en_diagnostico','en_trabajo') THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE', format('No se carga cotización con la OT en %s', o.estado)));
  END IF;

  SELECT * INTO v_vigente FROM core.cotizacion
   WHERE ot_id = p_ot_id AND vigente AND NOT invalidada;

  -- Reemplazar exige motivo. No borra nada: crea una versión nueva y la anterior
  -- conserva archivo, metadatos, usuario y fecha (cap. 28.2, QA-09).
  IF v_vigente.id IS NOT NULL AND btrim(coalesce(p_motivo_reemplazo,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','Reemplazar la cotización vigente exige motivo','motivo_reemplazo'));
  END IF;

  SELECT coalesce(max(version),0)+1 INTO v_version FROM core.cotizacion WHERE ot_id = p_ot_id;

  UPDATE core.cotizacion SET vigente = false, updated_by = p_user_id
   WHERE ot_id = p_ot_id AND vigente;

  INSERT INTO core.cotizacion (
    tenant_id, ot_id, version, vigente, proveedor_id, proveedor_ruc, proveedor_nombre,
    numero_cotizacion, fecha_cotizacion, monto, moneda, plazo_ofrecido_dias, validez_dias,
    observaciones, motivo_reemplazo, reemplaza_a, cargada_por, created_by, updated_by)
  VALUES (
    p_tenant_id, p_ot_id, v_version, true, p_proveedor_id,
    nullif(regexp_replace(coalesce(p_proveedor_ruc,''),'\D','','g'),''),
    p_proveedor_nombre, p_numero_cotizacion, p_fecha_cotizacion,
    p_monto, coalesce(p_moneda,'PEN')::core.moneda_codigo, p_plazo_ofrecido_dias, p_validez_dias,
    p_observaciones, p_motivo_reemplazo, v_vigente.id, p_user_id, p_user_id, p_user_id)
  RETURNING * INTO v;

  -- Cargar la cotización mueve la OT a 'en_cotizacion'. Desde 'en_trabajo' NO se
  -- retrocede: ahí la carga es la regularización de una emergencia que arrancó
  -- sin cotización, y el estado ya es el correcto (cap. 28.1).
  IF o.estado = 'en_diagnostico' THEN
    PERFORM internal.avanzar_estado_ot(p_tenant_id, p_ot_id, o.estado, 'en_cotizacion',
      p_user_id, 'Cotización seleccionada cargada');
  END IF;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'cotizacion',
    CASE WHEN v_vigente.id IS NULL THEN 'cotizacion_cargada' ELSE 'cotizacion_reemplazada' END,
    p_user_id, 'cotizacion', v.id,
    CASE WHEN v_vigente.id IS NOT NULL
         THEN jsonb_build_object('version', v_vigente.version, 'monto', v_vigente.monto) END,
    jsonb_build_object('version', v_version, 'monto', p_monto, 'moneda', p_moneda),
    p_motivo_reemplazo);

  -- Si ya existía una SOLPED, hay que advertir: MIP no modifica SAP automáticamente
  -- y el formulario interno puede haber quedado desalineado (cap. 28.2).
  SELECT EXISTS (SELECT 1 FROM core.solped WHERE ot_id = p_ot_id AND NOT anulada)
    INTO v_tenia_solped;

  IF o.coordinador_id IS DISTINCT FROM p_user_id THEN
    PERFORM internal.notificar(p_tenant_id, o.coordinador_id, 'cotizacion_cargada',
      format('Cotización cargada en la OT %s', o.numero_ot),
      coalesce(p_proveedor_nombre,'') || ' · ' || coalesce(p_monto::text,'s/monto'),
      p_ot_id, 'cotizacion', v.id);
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id,
    CASE WHEN v_vigente.id IS NULL THEN 'cargar' ELSE 'reemplazar' END,
    'cotizacion', v.id, to_jsonb(v_vigente), to_jsonb(v), p_motivo_reemplazo);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'version', v_version, 'reemplaza_a', v_vigente.id,
    'advertencia', CASE WHEN v_tenia_solped AND v_vigente.id IS NOT NULL
      THEN 'Esta OT ya tiene una SOLPED. MIP no modifica SAP automáticamente: revise el formulario interno y regularice manualmente si corresponde.'
      END));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Invalidar sin sustituta: deja la OT sin cotización vigente, con rastro.
CREATE OR REPLACE FUNCTION app.sp_cotizacion_invalidar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_cotizacion_id UUID, p_motivo TEXT)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE c core.cotizacion%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'cotizaciones:cargar');

  IF btrim(coalesce(p_motivo,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Invalidar una cotización exige motivo','motivo'));
  END IF;

  SELECT * INTO c FROM core.cotizacion WHERE id = p_cotizacion_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Cotización no encontrada'));
  END IF;

  -- Invalidación LÓGICA: el archivo y los metadatos se conservan (cap. 18.1).
  UPDATE core.cotizacion
     SET invalidada = true, vigente = false, motivo_reemplazo = p_motivo, updated_by = p_user_id
   WHERE id = p_cotizacion_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, c.ot_id, 'cotizacion', 'cotizacion_invalidada',
    p_user_id, 'cotizacion', c.id, jsonb_build_object('version', c.version), NULL, p_motivo);
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'invalidar', 'cotizacion',
                                       c.id, to_jsonb(c), NULL, p_motivo);
  PERFORM app.sp_ot_trazabilidad_refrescar(c.ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('invalidada', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.fn_cotizacion_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_ot_id UUID)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'cotizaciones:ver');
  RETURN jsonb_build_object('ok', true, 'data', internal.fn_ot_cotizaciones(p_ot_id));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
