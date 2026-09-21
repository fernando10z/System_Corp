-- =============================================================================
-- 33_app_adjuntos.sql · Archivos y evidencias (cap. 28.3)
--
-- Los límites del cap. 28.3 son "límites funcionales de partida, sujetos a
-- capacidad contratada", y la arquitectura debe permitir configurarlos sin tocar
-- la lógica de OT. Por eso viven en core.tenant_configuracion y se leen aquí, en
-- lugar de estar escritos a fuego en un CHECK.
--
-- Valores por defecto (cap. 28.3):
--   PDF de cotización  25 MB   ·  Fotografía  10 MB
--   Video             100 MB   ·  Documento   25 MB
--   Total por OT      500 MB
-- =============================================================================
SET search_path = app, core, internal, public;

CREATE OR REPLACE FUNCTION internal.limite_adjunto(p_tenant_id UUID, p_tipo core.tipo_adjunto)
RETURNS BIGINT LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  SELECT coalesce(
    (internal.config(p_tenant_id, 'limites_adjunto')->>(p_tipo::text))::bigint,
    CASE p_tipo
      WHEN 'pdf'        THEN 25  * 1024 * 1024
      WHEN 'imagen'     THEN 10  * 1024 * 1024
      WHEN 'video'      THEN 100 * 1024 * 1024
      WHEN 'documento'  THEN 25  * 1024 * 1024
      ELSE 25 * 1024 * 1024
    END);
$$;

CREATE OR REPLACE FUNCTION app.sp_adjunto_registrar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_entidad_tipo TEXT, p_entidad_id UUID, p_etapa TEXT, p_tipo TEXT,
  p_nombre TEXT, p_storage_key TEXT, p_mime_type TEXT DEFAULT NULL,
  p_tamano_bytes BIGINT DEFAULT NULL, p_ot_id UUID DEFAULT NULL,
  p_visibilidad TEXT DEFAULT 'canal', p_checksum TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v core.adjunto%ROWTYPE;
  v_tipo core.tipo_adjunto := p_tipo::core.tipo_adjunto;
  v_limite BIGINT;
  v_total_ot BIGINT;
  v_limite_ot BIGINT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'adjuntos:cargar');

  v_limite := internal.limite_adjunto(p_tenant_id, v_tipo);
  IF p_tamano_bytes IS NOT NULL AND p_tamano_bytes > v_limite THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION',
      format('El archivo supera el límite de %s MB para %s', round(v_limite/1048576.0), p_tipo),
      'tamano_bytes'));
  END IF;

  -- Tope acumulado por OT. El cap. 28.3 pide ADVERTIR antes de superarlo, así que
  -- se devuelve la advertencia junto con el resultado en vez de fallar en seco.
  v_limite_ot := coalesce((internal.config(p_tenant_id,'limites_adjunto')->>'total_ot')::bigint,
                          500 * 1024 * 1024);
  IF p_ot_id IS NOT NULL THEN
    SELECT coalesce(sum(tamano_bytes),0) INTO v_total_ot
      FROM core.adjunto WHERE ot_id = p_ot_id AND estado = 'vigente';
    IF v_total_ot + coalesce(p_tamano_bytes,0) > v_limite_ot THEN
      RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
        'BUSINESS_RULE',
        format('La OT superaría el límite de %s MB de archivos', round(v_limite_ot/1048576.0))));
    END IF;
  END IF;

  INSERT INTO core.adjunto (
    tenant_id, ot_id, entidad_tipo, entidad_id, etapa, tipo, nombre, nombre_original,
    mime_type, tamano_bytes, storage_key, checksum, visibilidad, autor_id)
  VALUES (p_tenant_id, p_ot_id, p_entidad_tipo, p_entidad_id,
          p_etapa::core.etapa_adjunto, v_tipo, p_nombre, p_nombre,
          p_mime_type, p_tamano_bytes, p_storage_key, p_checksum,
          coalesce(p_visibilidad,'canal')::core.visibilidad_mensaje, p_user_id)
  RETURNING * INTO v;

  IF p_ot_id IS NOT NULL THEN
    PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'adjunto_cargado',
      p_user_id, p_entidad_tipo, p_entidad_id, NULL,
      jsonb_build_object('nombre', p_nombre, 'tipo', p_tipo, 'etapa', p_etapa));
    PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  END IF;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'nombre', v.nombre, 'storage_key', v.storage_key,
    'advertencia', CASE WHEN p_ot_id IS NOT NULL
                          AND (v_total_ot + coalesce(p_tamano_bytes,0)) > v_limite_ot * 0.8
                        THEN 'La OT está cerca del límite de almacenamiento configurado.' END));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Retiro LÓGICO: el archivo deja de mostrarse pero conserva evidencia de la
-- acción, conforme a la política de retención del cliente (cap. 18.1).
CREATE OR REPLACE FUNCTION app.sp_adjunto_retirar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_adjunto_id UUID, p_motivo TEXT)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v core.adjunto%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'adjuntos:retirar');

  SELECT * INTO v FROM core.adjunto WHERE id = p_adjunto_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Adjunto no encontrado'));
  END IF;

  UPDATE core.adjunto
     SET estado = 'retirado', retirado_at = now(), retirado_por = p_user_id
   WHERE id = p_adjunto_id;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'retirar', 'adjunto',
                                       v.id, to_jsonb(v), NULL, p_motivo);
  IF v.ot_id IS NOT NULL THEN
    PERFORM app.sp_ot_trazabilidad_refrescar(v.ot_id, true);
  END IF;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('retirado', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.fn_adjunto_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_entidad_tipo TEXT DEFAULT NULL, p_entidad_id UUID DEFAULT NULL, p_ot_id UUID DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id', a.id, 'nombre', a.nombre, 'tipo', a.tipo, 'etapa', a.etapa,
           'mime', a.mime_type, 'tamano', a.tamano_bytes, 'storage_key', a.storage_key,
           'estado', a.estado, 'entidad_tipo', a.entidad_tipo, 'entidad_id', a.entidad_id,
           'autor', u.nombres||' '||u.apellidos, 'fecha', a.created_at
         ) ORDER BY a.created_at DESC), '[]'::jsonb) INTO v
  FROM core.adjunto a LEFT JOIN core.usuario u ON u.id = a.autor_id
  WHERE a.tenant_id = p_tenant_id AND a.estado = 'vigente'
    AND (p_ot_id IS NULL OR a.ot_id = p_ot_id)
    AND (p_entidad_tipo IS NULL OR a.entidad_tipo = p_entidad_tipo)
    AND (p_entidad_id IS NULL OR a.entidad_id = p_entidad_id);

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── Resolver un adjunto para descargarlo ─────────────────────────────────────
-- Antes el backend firmaba una URL a partir de la `storage_key` que le llegaba
-- por querystring: cualquiera con una clave podía pedir el archivo, sin que la
-- base comprobara de qué cliente era. Ahora se pide por id y es la base la que
-- decide si ese adjunto pertenece al tenant de quien pregunta; la clave del
-- almacén nunca sale de aquí hacia el navegador.
CREATE OR REPLACE FUNCTION app.fn_adjunto_obtener(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_adjunto_id UUID)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v core.adjunto%ROWTYPE;
  o core.orden_trabajo%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT * INTO v FROM core.adjunto
   WHERE id = p_adjunto_id
     AND estado = 'vigente'
     AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Adjunto no encontrado'));
  END IF;

  -- Si cuelga de una OT, el alcance organizacional manda igual que en el resto
  -- del expediente: ver el archivo es ver la OT.
  IF v.ot_id IS NOT NULL THEN
    o := internal.ot_visible(v.ot_id, p_user_id, p_tenant_id, p_is_super_admin);
    IF o.id IS NULL THEN
      RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Adjunto no encontrado'));
    END IF;
    PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);
  END IF;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'nombre', v.nombre, 'mime', v.mime_type,
    'tamano', v.tamano_bytes, 'storage_key', v.storage_key));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
