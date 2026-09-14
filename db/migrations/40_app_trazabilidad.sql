-- =============================================================================
-- 40_app_trazabilidad.sql · La API de consulta del árbol
--
-- Todo lo de aquí lee la columna orden_trabajo.trazabilidad (garantizando
-- frescura) o consulta dentro de ella. Es la superficie que usan la ficha de OT,
-- la vista de trazabilidad y la exportación.
-- =============================================================================
SET search_path = app, core, internal, public;

-- El árbol completo y fresco de una OT.
CREATE OR REPLACE FUNCTION app.fn_ot_trazabilidad(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_profundidad INT DEFAULT 10)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE o core.orden_trabajo%ROWTYPE; v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:ver');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);

  -- Con la profundidad por defecto se sirve el snapshot; con otra se recalcula,
  -- porque el snapshot siempre se guarda a profundidad 10.
  IF coalesce(p_profundidad,10) = 10 THEN
    v := internal.fn_ot_trazabilidad_fresca(p_ot_id);
  ELSE
    v := internal.fn_ot_trazabilidad(p_ot_id, p_profundidad, false);
  END IF;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Sólo el esqueleto de la jerarquía: para pintar el árbol de derivadas sin
-- traerse megabytes de conversación y eventos.
CREATE OR REPLACE FUNCTION app.fn_ot_arbol_jerarquia(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_ot_id UUID)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v_raiz UUID; v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:ver');

  -- Se sube hasta la raíz para poder mostrar la jerarquía COMPLETA aunque el
  -- usuario haya abierto una nieta.
  WITH RECURSIVE arriba AS (
    SELECT id, ot_padre_id, 0 AS salto FROM core.orden_trabajo WHERE id = p_ot_id
    UNION ALL
    SELECT o.id, o.ot_padre_id, a.salto+1
      FROM core.orden_trabajo o JOIN arriba a ON o.id = a.ot_padre_id
     WHERE a.salto < 100)
  SELECT id INTO v_raiz FROM arriba WHERE ot_padre_id IS NULL LIMIT 1;
  v_raiz := coalesce(v_raiz, p_ot_id);

  WITH RECURSIVE abajo AS (
    SELECT o.id, o.ot_padre_id, o.numero_ot, o.estado, o.condicion,
           o.estado_administrativo, o.prioridad_tecnica, o.es_emergencia,
           o.es_bloqueante_para_padre, o.independizada_de_padre, o.nivel, 0 AS profundidad
      FROM core.orden_trabajo o WHERE o.id = v_raiz AND o.deleted_at IS NULL
    UNION ALL
    SELECT h.id, h.ot_padre_id, h.numero_ot, h.estado, h.condicion,
           h.estado_administrativo, h.prioridad_tecnica, h.es_emergencia,
           h.es_bloqueante_para_padre, h.independizada_de_padre, h.nivel, ab.profundidad+1
      FROM core.orden_trabajo h JOIN abajo ab ON h.ot_padre_id = ab.id
     WHERE h.deleted_at IS NULL AND ab.profundidad < 20)
  SELECT jsonb_build_object(
    'raiz', v_raiz,
    'ot_consultada', p_ot_id,
    'nodos', coalesce(jsonb_agg(jsonb_build_object(
      'id', id, 'ot_padre_id', ot_padre_id, 'numero_ot', numero_ot,
      'estado', estado, 'condicion', condicion,
      'estado_administrativo', estado_administrativo,
      'prioridad', prioridad_tecnica, 'es_emergencia', es_emergencia,
      'es_bloqueante', es_bloqueante_para_padre,
      'independizada', independizada_de_padre,
      'nivel', nivel, 'es_actual', id = p_ot_id) ORDER BY nivel, numero_ot), '[]'::jsonb),
    'total', count(*),
    -- Lo que impide cerrar la raíz, listo para mostrarlo en la ficha (cap. 27.3).
    'bloqueantes_abiertas', count(*) FILTER (
      WHERE es_bloqueante_para_padre AND estado NOT IN ('cerrada','cancelada') AND ot_padre_id IS NOT NULL))
  INTO v FROM abajo;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Consolidación informativa de descendientes (cap. 27.3). NO fusiona estados ni
-- reescribe los historiales de las derivadas: sólo resume.
CREATE OR REPLACE FUNCTION app.fn_ot_consolidado(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_ot_id UUID)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB; v_ve_costos BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:ver');

  v_ve_costos := p_is_super_admin OR EXISTS (
    SELECT 1 FROM core.usuario_rol ur JOIN core.rol_permiso rp ON rp.rol_id=ur.rol_id
      JOIN core.permiso p ON p.id=rp.permiso_id
     WHERE ur.usuario_id=p_user_id AND p.codigo='costos:ver');

  WITH RECURSIVE desc_ot AS (
    SELECT o.id, 0 AS profundidad FROM core.orden_trabajo o
     WHERE o.ot_padre_id = p_ot_id AND o.deleted_at IS NULL
    UNION ALL
    SELECT h.id, d.profundidad+1 FROM core.orden_trabajo h
      JOIN desc_ot d ON h.ot_padre_id = d.id
     WHERE h.deleted_at IS NULL AND d.profundidad < 20)
  SELECT jsonb_build_object(
    'total_descendientes', count(*),
    'por_estado', coalesce((SELECT jsonb_object_agg(e, n) FROM (
        SELECT o2.estado::text e, count(*) n FROM desc_ot d2
          JOIN core.orden_trabajo o2 ON o2.id = d2.id GROUP BY 1) z), '{}'::jsonb),
    'por_estado_administrativo', coalesce((SELECT jsonb_object_agg(e, n) FROM (
        SELECT o3.estado_administrativo::text e, count(*) n FROM desc_ot d3
          JOIN core.orden_trabajo o3 ON o3.id = d3.id GROUP BY 1) z), '{}'::jsonb),
    'bloquean_cierre', (SELECT count(*) FROM desc_ot d4
                          JOIN core.orden_trabajo o4 ON o4.id = d4.id
                         WHERE o4.es_bloqueante_para_padre
                           AND o4.estado NOT IN ('cerrada','cancelada')),
    -- El sum() va en una subconsulta propia: jsonb_agg(... sum() ...) sería un
    -- agregado dentro de otro, y Postgres no lo admite.
    'costo_cotizado_descendientes', CASE WHEN v_ve_costos THEN (
        SELECT coalesce(jsonb_agg(x), '[]'::jsonb) FROM (
          SELECT jsonb_build_object('moneda', c.moneda, 'total', sum(c.monto)) AS x
            FROM desc_ot d5
            JOIN core.cotizacion c ON c.ot_id = d5.id AND c.vigente AND NOT c.invalidada
           GROUP BY c.moneda) z) END,
    'nota','Consolidación informativa. No fusiona estados ni reescribe los historiales de las derivadas.')
  INTO v FROM desc_ot;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Verificación de integridad del motor: compara el snapshot cacheado contra la
-- función autoritativa. Debería devolver siempre lista vacía; si no, hay un
-- trigger de marcado que no se está disparando.
CREATE OR REPLACE FUNCTION app.fn_trazabilidad_verificar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_limite INT DEFAULT 50)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB; v_revisadas INT := 0; v_ot RECORD; v_desviadas JSONB := '[]'::jsonb;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'auditoria:ver');

  FOR v_ot IN
    SELECT id, numero_ot, trazabilidad, trazabilidad_dirty
      FROM core.orden_trabajo
     WHERE tenant_id = p_tenant_id AND deleted_at IS NULL
     ORDER BY updated_at DESC
     LIMIT least(coalesce(p_limite,50), 500)
  LOOP
    v_revisadas := v_revisadas + 1;
    -- Se compara sin _meta: lleva la marca de tiempo de generación y siempre difiere.
    IF NOT v_ot.trazabilidad_dirty
       AND (v_ot.trazabilidad - '_meta') IS DISTINCT FROM
           (internal.fn_ot_trazabilidad(v_ot.id, 10, false) - '_meta') THEN
      v_desviadas := v_desviadas || jsonb_build_array(
        jsonb_build_object('id', v_ot.id, 'numero_ot', v_ot.numero_ot));
    END IF;
  END LOOP;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'revisadas', v_revisadas,
    'desviadas', v_desviadas,
    'sucias_pendientes', (SELECT count(*) FROM core.orden_trabajo
                           WHERE tenant_id = p_tenant_id AND trazabilidad_dirty),
    'integridad_ok', jsonb_array_length(v_desviadas) = 0));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Buscar DENTRO del árbol de trazabilidad. Aprovecha el índice GIN de la columna.
CREATE OR REPLACE FUNCTION app.fn_trazabilidad_buscar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_criterio JSONB, p_limite INT DEFAULT 50)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:listar');

  -- Contención: p_criterio se usa con el operador @> sobre jsonb. No se concatena
  -- en SQL, así que no hay superficie de inyección.
  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id', o.id, 'numero_ot', o.numero_ot, 'estado', o.estado,
           'trazabilidad_version', o.trazabilidad_version,
           'coincidencia', p_criterio)), '[]'::jsonb) INTO v
  FROM core.orden_trabajo o
  WHERE o.tenant_id = p_tenant_id AND o.deleted_at IS NULL
    AND o.trazabilidad @> p_criterio
  LIMIT least(coalesce(p_limite,50), 200);

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
