-- =============================================================================
-- 34_app_costos.sql · Motor de costos unitarios (cap. 16, 32)
--
-- Lo que este motor NO hace, y es tan importante como lo que hace:
--   · No recomienda proveedor ni aprueba cotizaciones (cap. 32.5).
--   · No presenta un costo como contablemente final si sólo tiene una cotización
--     o un monto de liberación (cap. 16.4, "regla de calidad").
--   · No borra valores atípicos: los marca y conserva su contexto (cap. 16.3).
--   · No destruye el texto original al normalizar (cap. 32.5).
--
-- Y una regla de presentación que el código hace cumplir: un promedio NO se
-- devuelve si la muestra no llega al umbral configurable. Mostrar "promedio: 1"
-- sobre un solo caso es falsa precisión (cap. 32.4).
-- =============================================================================
SET search_path = app, core, internal, public;

CREATE OR REPLACE FUNCTION app.sp_costo_registrar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_texto_original TEXT, p_monto_total NUMERIC,
  p_fuente TEXT DEFAULT 'cotizacion', p_concepto TEXT DEFAULT NULL,
  p_cantidad NUMERIC DEFAULT NULL, p_unidad TEXT DEFAULT NULL,
  p_moneda TEXT DEFAULT 'PEN', p_cotizacion_id UUID DEFAULT NULL,
  p_descripcion_normalizada_id UUID DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v core.costo_unitario%ROWTYPE;
  v_unitario NUMERIC;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'costos:registrar');

  IF btrim(coalesce(p_texto_original,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','El texto original del documento es obligatorio: no hay registros sin procedencia','texto_original'));
  END IF;

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  -- Costo unitario SÓLO si la cantidad es positiva; si no, se conserva el total
  -- y el unitario queda NULL. Dividir por una cantidad ausente inventaría un dato
  -- (cap. 32.2).
  v_unitario := CASE WHEN coalesce(p_cantidad,0) > 0
                     THEN round(p_monto_total / p_cantidad, 4) END;

  INSERT INTO core.costo_unitario (
    tenant_id, ot_id, cotizacion_id, fuente, texto_original,
    descripcion_normalizada_id, tipo_trabajo_id, concepto,
    cantidad, unidad, monto_total, costo_unitario, moneda, fecha_referencia,
    proveedor_id, sucursal_id, empresa_ruc_id, area_id,
    fue_emergencia, ot_es_derivada, created_by, updated_by)
  SELECT
    p_tenant_id, p_ot_id, coalesce(p_cotizacion_id, c.id), p_fuente::core.fuente_costo,
    btrim(p_texto_original), p_descripcion_normalizada_id, o.tipo_trabajo_id,
    nullif(p_concepto,'')::core.concepto_costo,
    p_cantidad, p_unidad, p_monto_total, v_unitario,
    coalesce(p_moneda, c.moneda::text, 'PEN')::core.moneda_codigo,
    coalesce(c.fecha_cotizacion, current_date),
    c.proveedor_id, o.sucursal_id, o.empresa_ruc_id, o.area_id,
    o.es_emergencia, o.ot_padre_id IS NOT NULL, p_user_id, p_user_id
  FROM (SELECT 1) dummy
  LEFT JOIN core.cotizacion c
    ON c.id = coalesce(p_cotizacion_id,
                       (SELECT id FROM core.cotizacion
                         WHERE ot_id = p_ot_id AND vigente AND NOT invalidada LIMIT 1))
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'costos', 'costo_registrado',
    p_user_id, 'costo_unitario', v.id, NULL,
    jsonb_build_object('monto', p_monto_total, 'moneda', v.moneda, 'fuente', p_fuente));
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Al cerrar la OT hay que calificar si el caso es comparable o si su alcance
-- mixto/extraordinario exige marca de excepción (cap. 32.3).
CREATE OR REPLACE FUNCTION app.sp_costo_calificar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_costo_id UUID, p_es_comparable BOOLEAN,
  p_es_outlier BOOLEAN DEFAULT false, p_justificacion TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v core.costo_unitario%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'costos:registrar');

  IF p_es_outlier AND btrim(coalesce(p_justificacion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','Marcar un valor como atípico exige justificación consultable','justificacion'));
  END IF;

  UPDATE core.costo_unitario
     SET es_comparable = coalesce(p_es_comparable, es_comparable),
         es_outlier = coalesce(p_es_outlier, es_outlier),
         outlier_justificacion = coalesce(p_justificacion, outlier_justificacion),
         estado_validacion = CASE WHEN p_es_outlier THEN 'excepcion'::core.estado_validacion_costo
                                  ELSE 'validado'::core.estado_validacion_costo END,
         updated_by = p_user_id
   WHERE id = p_costo_id
  RETURNING * INTO v;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Registro de costo no encontrado'));
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'calificar', 'costo_unitario',
                                       v.id, NULL, to_jsonb(v), p_justificacion);
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── Histórico y referencias (cap. 16.4, 32.4) ───────────────────────────────
-- Devuelve SIEMPRE número de casos, filtros usados y moneda. Sin ese contexto un
-- promedio es un número que engaña, y el documento lo prohíbe expresamente.
--
-- Todo en una sentencia con CTE: una función STABLE no puede crear tablas.
CREATE OR REPLACE FUNCTION app.fn_costo_historico(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_filtros JSONB DEFAULT '{}'::jsonb)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v_umbral INT;
  v JSONB;
  v_tipo     TEXT := p_filtros->>'tipo_trabajo_id';
  v_empresa  TEXT := p_filtros->>'empresa_ruc_id';
  v_sucursal TEXT := p_filtros->>'sucursal_id';
  v_area     TEXT := p_filtros->>'area_id';
  v_prov     TEXT := p_filtros->>'proveedor_id';
  v_moneda   TEXT := coalesce(p_filtros->>'moneda','PEN');
  v_desde    TEXT := p_filtros->>'desde';
  v_hasta    TEXT := p_filtros->>'hasta';
  v_outliers BOOLEAN := coalesce((p_filtros->>'incluir_outliers')::boolean, false);
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'costos:ver');

  -- Umbral configurable por tenant: por debajo no se publica promedio (cap. 32.4).
  v_umbral := coalesce((internal.config(p_tenant_id,'umbral_muestra_costos')->>'minimo')::int, 3);

  WITH comparables AS (
    SELECT cu.*
      FROM core.costo_unitario cu
     WHERE cu.tenant_id = p_tenant_id
       AND cu.es_comparable = true
       AND cu.moneda::text = v_moneda
       AND (v_outliers OR cu.es_outlier = false)
       AND (v_tipo     IS NULL OR cu.tipo_trabajo_id = v_tipo::uuid)
       AND (v_empresa  IS NULL OR cu.empresa_ruc_id = v_empresa::uuid)
       AND (v_sucursal IS NULL OR cu.sucursal_id = v_sucursal::uuid)
       AND (v_area     IS NULL OR cu.area_id = v_area::uuid)
       AND (v_prov     IS NULL OR cu.proveedor_id = v_prov::uuid)
       AND (v_desde    IS NULL OR cu.fecha_referencia >= v_desde::date)
       AND (v_hasta    IS NULL OR cu.fecha_referencia <= v_hasta::date)
  ),
  conteo AS (SELECT count(*)::int AS casos FROM comparables)
  SELECT jsonb_build_object(
    'ultimo_costo', (
      SELECT jsonb_build_object(
               'id', cu.id, 'monto', cu.monto_total, 'costo_unitario', cu.costo_unitario,
               'moneda', cu.moneda, 'fecha', cu.fecha_referencia,
               'proveedor', pr.razon_social, 'fuente', cu.fuente,
               'texto_original', cu.texto_original, 'ot', o.numero_ot)
        FROM comparables cu
        LEFT JOIN core.proveedor pr    ON pr.id = cu.proveedor_id
        LEFT JOIN core.orden_trabajo o ON o.id = cu.ot_id
       ORDER BY cu.fecha_referencia DESC NULLS LAST, cu.created_at DESC
       LIMIT 1),

    -- Promedio y rango SÓLO con muestra suficiente. Si no, se explica por qué:
    -- mostrar "promedio" sobre un caso es falsa precisión (cap. 32.4).
    'estadisticas', CASE
      WHEN (SELECT casos FROM conteo) >= v_umbral THEN (
        SELECT jsonb_build_object(
          'promedio',  round(avg(monto_total)::numeric, 2),
          'minimo',    min(monto_total),
          'maximo',    max(monto_total),
          'mediana',   round((percentile_cont(0.5) WITHIN GROUP (ORDER BY monto_total))::numeric, 2),
          'promedio_unitario', round(avg(costo_unitario)::numeric, 4))
          FROM comparables)
      ELSE jsonb_build_object(
        'promedio', NULL,
        'motivo_sin_promedio',
          format('La muestra tiene %s caso(s) y el umbral configurado es %s. Un promedio con menos casos sería falsa precisión.',
                 (SELECT casos FROM conteo), v_umbral))
      END,

    'registros', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', cu.id, 'texto_original', cu.texto_original,
               'descripcion_normalizada', dn.etiqueta,
               'monto', cu.monto_total, 'costo_unitario', cu.costo_unitario,
               'cantidad', cu.cantidad, 'unidad', cu.unidad, 'moneda', cu.moneda,
               'fecha', cu.fecha_referencia, 'proveedor', pr.razon_social,
               'ot', o.numero_ot, 'fuente', cu.fuente,
               'emergencia', cu.fue_emergencia, 'es_outlier', cu.es_outlier)
             ORDER BY cu.fecha_referencia DESC NULLS LAST)
        FROM comparables cu
        LEFT JOIN core.descripcion_normalizada dn ON dn.id = cu.descripcion_normalizada_id
        LEFT JOIN core.proveedor pr               ON pr.id = cu.proveedor_id
        LEFT JOIN core.orden_trabajo o            ON o.id = cu.ot_id), '[]'::jsonb),

    -- Contexto obligatorio de presentación (cap. 32.4): sin esto los números mienten.
    'contexto', jsonb_build_object(
      'casos', (SELECT casos FROM conteo),
      'umbral_minimo', v_umbral,
      'moneda', v_moneda,
      'outliers_incluidos', v_outliers,
      'filtros', p_filtros,
      'advertencia', 'Costo observado y cotizado. NO es un costo contable final: MIP no tiene integración contable definida.')
  ) INTO v;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
