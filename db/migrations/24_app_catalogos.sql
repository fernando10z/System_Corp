-- =============================================================================
-- 24_app_catalogos.sql · Catálogos configurables, tipos de trabajo y proveedores
--
-- Cap. 17: catálogos, motivos y parámetros varían por cliente; el flujo base no.
-- Los ítems con tenant_id NULL son la base heredada por todos; un tenant puede
-- añadir los suyos sin tocar código ni migraciones.
-- =============================================================================
SET search_path = app, core, internal, public;

CREATE OR REPLACE FUNCTION app.fn_catalogo_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_tipo TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT coalesce(jsonb_object_agg(tipo, items), '{}'::jsonb) INTO v FROM (
    SELECT c.tipo::text AS tipo,
           jsonb_agg(jsonb_build_object(
             'id', c.id, 'codigo', c.codigo, 'nombre', c.nombre,
             'descripcion', c.descripcion, 'orden', c.orden,
             'requiere_comentario', c.requiere_comentario,
             'es_base', c.tenant_id IS NULL) ORDER BY c.orden, c.nombre) AS items
      FROM core.catalogo_item c
     WHERE c.deleted_at IS NULL AND c.estado = 'activo'
       AND (c.tenant_id = p_tenant_id OR c.tenant_id IS NULL)
       AND (p_tipo IS NULL OR c.tipo::text = p_tipo)
     GROUP BY c.tipo
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_catalogo_item_crear(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_tipo TEXT, p_codigo TEXT, p_nombre TEXT,
  p_descripcion TEXT DEFAULT NULL, p_orden INT DEFAULT 0,
  p_requiere_comentario BOOLEAN DEFAULT false)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v core.catalogo_item%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'catalogos:crear');

  INSERT INTO core.catalogo_item (tenant_id, tipo, codigo, nombre, descripcion, orden,
                                  requiere_comentario, created_by, updated_by)
  VALUES (p_tenant_id, p_tipo::core.tipo_catalogo, upper(btrim(p_codigo)), btrim(p_nombre),
          p_descripcion, coalesce(p_orden,0), coalesce(p_requiere_comentario,false),
          p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'catalogo_item', v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Tipo de trabajo: agrupación principal del motor de costos (cap. 16.2). Se
-- devuelve con su jerarquía y con cuántos casos históricos comparables tiene,
-- para que el coordinador sepa si el promedio va a significar algo.
CREATE OR REPLACE FUNCTION app.fn_tipo_trabajo_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id', t.id, 'codigo', t.codigo, 'nombre', t.nombre,
           'padre_id', t.padre_id, 'es_base', t.es_base, 'estado', t.estado,
           'casos_historicos', (SELECT count(*) FROM core.costo_unitario cu
                                 WHERE cu.tipo_trabajo_id = t.id AND cu.es_comparable)
         ) ORDER BY t.nombre), '[]'::jsonb) INTO v
  FROM core.tipo_trabajo t
  WHERE t.deleted_at IS NULL AND t.estado = 'activo'
    AND (t.tenant_id = p_tenant_id OR t.tenant_id IS NULL);

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_tipo_trabajo_crear(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_codigo TEXT, p_nombre TEXT, p_padre_id UUID DEFAULT NULL, p_descripcion TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v core.tipo_trabajo%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'catalogos:crear');

  INSERT INTO core.tipo_trabajo (tenant_id, codigo, nombre, padre_id, descripcion, created_by, updated_by)
  VALUES (p_tenant_id, upper(btrim(p_codigo)), btrim(p_nombre), p_padre_id, p_descripcion,
          p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'tipo_trabajo', v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.fn_proveedor_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_filtros JSONB DEFAULT '{}'::jsonb, p_page INT DEFAULT 1, p_page_size INT DEFAULT 20)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v_size INT := least(greatest(coalesce(p_page_size,20),1),100);
  v_off  INT := (greatest(coalesce(p_page,1),1)-1)*v_size;
  v_total INT; v_data JSONB;
  v_buscar TEXT := internal.normalizar_busqueda(p_filtros->>'buscar');
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT count(*) INTO v_total FROM core.proveedor p
   WHERE p.tenant_id = p_tenant_id AND p.deleted_at IS NULL
     AND (nullif(v_buscar,'') IS NULL
          OR internal.normalizar_busqueda(p.razon_social||' '||coalesce(p.ruc,'')) LIKE '%'||v_buscar||'%');

  SELECT coalesce(jsonb_agg(d), '[]'::jsonb) INTO v_data FROM (
    SELECT jsonb_build_object(
      'id', p.id, 'ruc', p.ruc, 'razon_social', p.razon_social,
      'contacto', p.contacto, 'telefono', p.telefono, 'email', p.email, 'estado', p.estado,
      -- Recurrencia y costo histórico, SIN ranking automático (cap. 16.2)
      'cotizaciones', (SELECT count(*) FROM core.cotizacion c WHERE c.proveedor_id = p.id),
      'ultima_cotizacion', (SELECT max(c.fecha_cotizacion) FROM core.cotizacion c WHERE c.proveedor_id = p.id)
    ) AS d
    FROM core.proveedor p
    WHERE p.tenant_id = p_tenant_id AND p.deleted_at IS NULL
      AND (nullif(v_buscar,'') IS NULL
           OR internal.normalizar_busqueda(p.razon_social||' '||coalesce(p.ruc,'')) LIKE '%'||v_buscar||'%')
    ORDER BY p.razon_social LIMIT v_size OFFSET v_off
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v_data,
                            'meta', internal.meta_paginacion(v_total, p_page, v_size));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_proveedor_crear(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_razon_social TEXT, p_ruc TEXT DEFAULT NULL, p_contacto TEXT DEFAULT NULL,
  p_telefono TEXT DEFAULT NULL, p_email TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v core.proveedor%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'proveedores:crear');

  IF p_ruc IS NOT NULL AND NOT internal.validar_ruc(p_ruc) THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El RUC del proveedor no es válido','ruc'));
  END IF;

  INSERT INTO core.proveedor (tenant_id, ruc, razon_social, contacto, telefono, email,
                              created_by, updated_by)
  VALUES (p_tenant_id, nullif(regexp_replace(coalesce(p_ruc,''),'\D','','g'),''),
          btrim(p_razon_social), p_contacto, p_telefono, p_email, p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'proveedor', v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
