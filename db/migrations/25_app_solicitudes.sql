-- =============================================================================
-- 25_app_solicitudes.sql · Solicitudes de trabajo (cap. 7, 24)
--
-- La solicitud es un reporte NO técnico. El principio de "simplicidad de captura"
-- (cap. 3) es explícito: al solicitante NO se le pide activo, código de equipo,
-- CECOS, diagnóstico, causa, proveedor ni costo. Si algún día alguien quiere
-- añadir esos campos aquí, está rompiendo el principio fundacional del producto.
--
-- La conversión a OT vive en 26_app_ot.sql, porque lo que crea es una OT.
-- =============================================================================
SET search_path = app, core, internal, public;

-- ── ST-01 · Crear solicitud ──────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION app.sp_solicitud_crear(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_titulo TEXT, p_descripcion TEXT, p_lugar TEXT, p_area_id UUID,
  p_impacto_operativo_id UUID DEFAULT NULL, p_impacto_comentario TEXT DEFAULT NULL,
  p_prioridad_percibida TEXT DEFAULT NULL, p_enviar BOOLEAN DEFAULT true)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v core.solicitud_trabajo%ROWTYPE;
  v_empresa UUID; v_sucursal UUID; v_numero TEXT;
  v_requiere_comentario BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'solicitudes:crear');

  -- El área determina la empresa/RUC; la sucursal se toma de la primera asociada.
  SELECT a.empresa_ruc_id INTO v_empresa
    FROM core.area a WHERE a.id = p_area_id AND a.deleted_at IS NULL;
  IF v_empresa IS NULL THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('NOT_FOUND','El área indicada no existe','area_id'));
  END IF;

  -- El usuario sólo puede reportar dentro de su alcance (cap. 24.1, "Errores").
  PERFORM internal.assert_alcance(p_user_id, NULL, v_empresa, p_area_id);

  SELECT se.sucursal_id INTO v_sucursal
    FROM core.sucursal_empresa_ruc se WHERE se.empresa_ruc_id = v_empresa LIMIT 1;

  -- El ítem 'Otro' del catálogo de impacto exige comentario (cap. 24.3).
  SELECT requiere_comentario INTO v_requiere_comentario
    FROM core.catalogo_item WHERE id = p_impacto_operativo_id;
  IF coalesce(v_requiere_comentario,false) AND btrim(coalesce(p_impacto_comentario,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Ese impacto operativo exige un comentario','impacto_comentario'));
  END IF;

  -- La descripción no puede ser sólo espacios o un carácter repetido (cap. 24.3).
  IF btrim(p_descripcion) ~ '^(.)\1*$' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La descripción debe explicar la necesidad','descripcion'));
  END IF;

  v_numero := internal.siguiente_numero(p_tenant_id, 'ST');

  INSERT INTO core.solicitud_trabajo (
    tenant_id, numero, estado, titulo, descripcion, lugar,
    impacto_operativo_id, impacto_comentario, prioridad_percibida,
    area_id, empresa_ruc_id, sucursal_id, solicitante_id, fecha_envio,
    created_by, updated_by)
  VALUES (
    p_tenant_id, v_numero,
    CASE WHEN p_enviar THEN 'enviada'::core.solicitud_estado ELSE 'borrador'::core.solicitud_estado END,
    btrim(p_titulo), btrim(p_descripcion), btrim(p_lugar),
    p_impacto_operativo_id, p_impacto_comentario,
    nullif(p_prioridad_percibida,'')::core.prioridad,
    p_area_id, v_empresa, v_sucursal, p_user_id,
    CASE WHEN p_enviar THEN now() END,
    p_user_id, p_user_id)
  RETURNING * INTO v;

  -- Un borrador no notifica ni crea OT (cap. 24.2).
  IF p_enviar THEN
    PERFORM internal.notificar_coordinadores(
      p_tenant_id, p_area_id, 'solicitud_nueva',
      'Nueva solicitud ' || v_numero,
      v.titulo, 'solicitud_trabajo', v.id);
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'solicitud_trabajo',
                                       v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_solicitud_enviar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_solicitud_id UUID)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE s core.solicitud_trabajo%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  SELECT * INTO s FROM core.solicitud_trabajo WHERE id = p_solicitud_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Solicitud no encontrada'));
  END IF;
  IF s.estado NOT IN ('borrador','observada') THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','Sólo se envía una solicitud en borrador u observada'));
  END IF;

  UPDATE core.solicitud_trabajo
     SET estado = 'enviada', fecha_envio = coalesce(fecha_envio, now()), updated_by = p_user_id
   WHERE id = p_solicitud_id;

  INSERT INTO core.solicitud_decision (tenant_id, solicitud_id, tipo, estado_anterior, estado_nuevo, actor_id)
  VALUES (p_tenant_id, p_solicitud_id, 'reenviar', s.estado, 'enviada', p_user_id);

  PERFORM internal.notificar_coordinadores(p_tenant_id, s.area_id, 'solicitud_nueva',
    'Solicitud ' || s.numero || ' enviada', s.titulo, 'solicitud_trabajo', s.id);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('estado','enviada'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Tomar la revisión marca el instante que alimenta el KPI "tiempo de primera
-- revisión" (cap. 35.2) y pasa la solicitud a EN REVISION (cap. 24.2).
CREATE OR REPLACE FUNCTION app.sp_solicitud_tomar_revision(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_solicitud_id UUID)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE s core.solicitud_trabajo%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'solicitudes:decidir');

  SELECT * INTO s FROM core.solicitud_trabajo WHERE id = p_solicitud_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Solicitud no encontrada'));
  END IF;
  IF s.estado <> 'enviada' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','Sólo se toma en revisión una solicitud enviada'));
  END IF;

  UPDATE core.solicitud_trabajo
     SET estado = 'en_revision',
         coordinador_revisor_id = p_user_id,
         fecha_primera_revision = coalesce(fecha_primera_revision, now()),
         updated_by = p_user_id
   WHERE id = p_solicitud_id;

  INSERT INTO core.solicitud_decision (tenant_id, solicitud_id, tipo, estado_anterior, estado_nuevo, actor_id)
  VALUES (p_tenant_id, p_solicitud_id, 'tomar_revision', s.estado, 'en_revision', p_user_id);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('estado','en_revision'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── ST-02 · Decidir (observar, rechazar, derivar, marcar duplicada) ──────────
-- Aceptar NO pasa por aquí: crea una OT, y eso vive en app.sp_ot_crear_desde_solicitud.
CREATE OR REPLACE FUNCTION app.sp_solicitud_decidir(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_solicitud_id UUID, p_tipo TEXT, p_comentario TEXT DEFAULT NULL,
  p_motivo_id UUID DEFAULT NULL, p_destinatario_id UUID DEFAULT NULL,
  p_solicitud_principal_id UUID DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  s core.solicitud_trabajo%ROWTYPE;
  v_nuevo core.solicitud_estado;
  v_tipo  core.tipo_decision_solicitud := p_tipo::core.tipo_decision_solicitud;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'solicitudes:decidir');

  SELECT * INTO s FROM core.solicitud_trabajo WHERE id = p_solicitud_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Solicitud no encontrada'));
  END IF;

  -- Una solicitud convertida en OT es inmutable como origen (cap. 24.2).
  IF s.estado IN ('convertida_en_ot','rechazada','duplicada') THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE',
        format('Una solicitud %s ya no admite decisiones', s.estado)));
  END IF;

  v_nuevo := CASE v_tipo
    WHEN 'observar'         THEN 'observada'::core.solicitud_estado
    WHEN 'rechazar'         THEN 'rechazada'::core.solicitud_estado
    WHEN 'derivar'          THEN 'derivada'::core.solicitud_estado
    WHEN 'marcar_duplicada' THEN 'duplicada'::core.solicitud_estado
    ELSE NULL END;

  IF v_nuevo IS NULL THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION',
        'Decisión no válida aquí. Para aceptar use la conversión a OT.','tipo'));
  END IF;

  -- Rechazar exige motivo (cap. 7.3); observar exige el comentario que verá el
  -- solicitante; derivar exige destinatario; duplicada exige la principal.
  IF v_tipo = 'rechazar' AND p_motivo_id IS NULL AND btrim(coalesce(p_comentario,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El rechazo exige motivo','motivo_id'));
  END IF;
  IF v_tipo = 'observar' AND btrim(coalesce(p_comentario,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La observación exige un comentario para el solicitante','comentario'));
  END IF;
  IF v_tipo = 'derivar' AND p_destinatario_id IS NULL THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Derivar exige indicar el destinatario','destinatario_id'));
  END IF;
  IF v_tipo = 'marcar_duplicada' THEN
    IF p_solicitud_principal_id IS NULL THEN
      RETURN jsonb_build_object('ok', false,
        'error', internal.error_jsonb('VALIDATION','Marcar duplicada exige la solicitud principal','solicitud_principal_id'));
    END IF;
    IF p_solicitud_principal_id = p_solicitud_id THEN
      RETURN jsonb_build_object('ok', false,
        'error', internal.error_jsonb('VALIDATION','Una solicitud no puede ser duplicada de sí misma'));
    END IF;
  END IF;

  UPDATE core.solicitud_trabajo
     SET estado = v_nuevo,
         motivo_rechazo_id = CASE WHEN v_tipo = 'rechazar' THEN p_motivo_id ELSE motivo_rechazo_id END,
         observacion_actual = coalesce(p_comentario, observacion_actual),
         solicitud_principal_id = CASE WHEN v_tipo = 'marcar_duplicada'
                                       THEN p_solicitud_principal_id ELSE solicitud_principal_id END,
         coordinador_revisor_id = CASE WHEN v_tipo = 'derivar' THEN p_destinatario_id
                                       ELSE coalesce(coordinador_revisor_id, p_user_id) END,
         fecha_primera_revision = coalesce(fecha_primera_revision, now()),
         updated_by = p_user_id
   WHERE id = p_solicitud_id;

  INSERT INTO core.solicitud_decision (
    tenant_id, solicitud_id, tipo, estado_anterior, estado_nuevo,
    motivo_id, comentario, destinatario_id, solicitud_relacionada_id, actor_id)
  VALUES (p_tenant_id, p_solicitud_id, v_tipo, s.estado, v_nuevo,
          p_motivo_id, p_comentario, p_destinatario_id, p_solicitud_principal_id, p_user_id);

  -- Se notifica a quien tiene que actuar, no por cada cambio menor (cap. 19).
  IF v_tipo IN ('observar','rechazar') THEN
    PERFORM internal.notificar(p_tenant_id, s.solicitante_id, 'solicitud_' || p_tipo,
      format('Su solicitud %s fue %s', s.numero, v_nuevo), p_comentario,
      NULL, 'solicitud_trabajo', s.id);
  ELSIF v_tipo = 'derivar' THEN
    PERFORM internal.notificar(p_tenant_id, p_destinatario_id, 'solicitud_derivada',
      format('Se le derivó la solicitud %s', s.numero), p_comentario,
      NULL, 'solicitud_trabajo', s.id);
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, p_tipo, 'solicitud_trabajo',
    p_solicitud_id, jsonb_build_object('estado', s.estado),
    jsonb_build_object('estado', v_nuevo), p_comentario);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado', v_nuevo, 'decision', p_tipo));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── Consultas ────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION app.fn_solicitud_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_filtros JSONB DEFAULT '{}'::jsonb, p_page INT DEFAULT 1, p_page_size INT DEFAULT 20)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v_size INT := least(greatest(coalesce(p_page_size,20),1),100);
  v_off  INT := (greatest(coalesce(p_page,1),1)-1)*v_size;
  v_total INT; v_data JSONB; v_global BOOLEAN;
  v_estado TEXT := p_filtros->>'estado';
  v_area   TEXT := p_filtros->>'area_id';
  v_mias   BOOLEAN := coalesce((p_filtros->>'mias')::boolean, false);
  v_buscar TEXT := internal.normalizar_busqueda(p_filtros->>'buscar');
  v_pendientes BOOLEAN := coalesce((p_filtros->>'pendientes_revision')::boolean, false);
  -- Rango sobre la fecha de envío; si aún es borrador, sobre la de creación.
  v_desde  TEXT := nullif(p_filtros->>'desde','');
  v_hasta  TEXT := nullif(p_filtros->>'hasta','');
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  -- CTE en vez de tabla temporal: una función STABLE no puede hacer CREATE TABLE.
  WITH filtrado AS (
    SELECT s.id FROM core.solicitud_trabajo s
     WHERE s.deleted_at IS NULL
       AND (v_global OR s.tenant_id = p_tenant_id)
       AND (v_estado IS NULL OR s.estado::text = v_estado)
       AND (v_area   IS NULL OR s.area_id = v_area::uuid)
       AND (NOT v_mias OR s.solicitante_id = p_user_id)
       AND (NOT v_pendientes OR s.estado IN ('enviada','en_revision'))
       AND (v_desde IS NULL OR coalesce(s.fecha_envio, s.created_at) >= v_desde::timestamptz)
       AND (v_hasta IS NULL OR coalesce(s.fecha_envio, s.created_at) < (v_hasta::date + 1)::timestamptz)
       AND (nullif(v_buscar,'') IS NULL
            OR internal.normalizar_busqueda(s.titulo||' '||s.descripcion||' '||s.numero) LIKE '%'||v_buscar||'%')
       -- El solicitante ve lo suyo; el resto necesita alcance sobre el área (cap. 4.1).
       AND (v_global OR s.solicitante_id = p_user_id
            OR NOT EXISTS (SELECT 1 FROM core.usuario_alcance ua WHERE ua.usuario_id = p_user_id)
            OR EXISTS (SELECT 1 FROM core.usuario_alcance ua
                        WHERE ua.usuario_id = p_user_id
                          AND (ua.area_id IS NULL OR ua.area_id = s.area_id)))
  ),
  pagina AS (
    SELECT jsonb_build_object(
      'id', s.id, 'numero', s.numero, 'estado', s.estado, 'titulo', s.titulo,
      'descripcion', s.descripcion, 'lugar', s.lugar,
      'prioridad_percibida', s.prioridad_percibida,
      'impacto', ci.nombre,
      'area', ar.nombre, 'area_id', s.area_id,
      'empresa_ruc', er.razon_social,
      'solicitante', u.nombres||' '||u.apellidos,
      'fecha_envio', s.fecha_envio,
      'fecha_primera_revision', s.fecha_primera_revision,
      -- Antigüedad: es lo que ordena la bandeja del coordinador (cap. 35.1).
      'horas_espera', CASE WHEN s.fecha_primera_revision IS NULL AND s.fecha_envio IS NOT NULL
                           THEN round(extract(epoch FROM (now() - s.fecha_envio))/3600.0, 1) END,
      'ot', (SELECT jsonb_build_object('id', o.id, 'numero', o.numero_ot, 'estado', o.estado)
               FROM core.orden_trabajo o WHERE o.solicitud_origen_id = s.id),
      'adjuntos', (SELECT count(*) FROM core.adjunto a
                    WHERE a.entidad_tipo='solicitud_trabajo' AND a.entidad_id=s.id),
      'created_at', s.created_at
    ) AS d
    FROM filtrado f
    JOIN core.solicitud_trabajo s ON s.id = f.id
    LEFT JOIN core.area ar          ON ar.id = s.area_id
    LEFT JOIN core.empresa_ruc er   ON er.id = s.empresa_ruc_id
    LEFT JOIN core.usuario u        ON u.id = s.solicitante_id
    LEFT JOIN core.catalogo_item ci ON ci.id = s.impacto_operativo_id
    ORDER BY s.created_at DESC
    LIMIT v_size OFFSET v_off
  )
  SELECT (SELECT count(*)::int FROM filtrado),
         coalesce((SELECT jsonb_agg(d) FROM pagina), '[]'::jsonb)
    INTO v_total, v_data;

  RETURN jsonb_build_object('ok', true, 'data', v_data,
                            'meta', internal.meta_paginacion(v_total, p_page, v_size));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.fn_solicitud_obtener(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_solicitud_id UUID)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT jsonb_build_object(
    'id', s.id, 'numero', s.numero, 'estado', s.estado,
    'titulo', s.titulo, 'descripcion', s.descripcion, 'lugar', s.lugar,
    'impacto', ci.nombre, 'impacto_comentario', s.impacto_comentario,
    'prioridad_percibida', s.prioridad_percibida,
    'area', jsonb_build_object('id', ar.id, 'nombre', ar.nombre),
    'empresa_ruc', jsonb_build_object('id', er.id, 'razon_social', er.razon_social, 'ruc', er.ruc),
    'solicitante', jsonb_build_object('id', u.id, 'nombre', u.nombres||' '||u.apellidos),
    'fecha_envio', s.fecha_envio, 'fecha_primera_revision', s.fecha_primera_revision,
    'observacion_actual', s.observacion_actual,
    'solicitud_principal_id', s.solicitud_principal_id,
    'decisiones', coalesce((SELECT jsonb_agg(jsonb_build_object(
        'tipo', d.tipo, 'estado_anterior', d.estado_anterior, 'estado_nuevo', d.estado_nuevo,
        'motivo', cm.nombre, 'comentario', d.comentario,
        'actor', du.nombres||' '||du.apellidos, 'fecha', d.created_at) ORDER BY d.created_at)
      FROM core.solicitud_decision d
      LEFT JOIN core.usuario du ON du.id = d.actor_id
      LEFT JOIN core.catalogo_item cm ON cm.id = d.motivo_id
     WHERE d.solicitud_id = s.id), '[]'::jsonb),
    'adjuntos', internal.fn_adjuntos_de('solicitud_trabajo', s.id),
    'ot', (SELECT jsonb_build_object('id', o.id, 'numero', o.numero_ot, 'estado', o.estado)
             FROM core.orden_trabajo o WHERE o.solicitud_origen_id = s.id)
  ) INTO v
  FROM core.solicitud_trabajo s
  LEFT JOIN core.area ar        ON ar.id = s.area_id
  LEFT JOIN core.empresa_ruc er ON er.id = s.empresa_ruc_id
  LEFT JOIN core.usuario u      ON u.id = s.solicitante_id
  LEFT JOIN core.catalogo_item ci ON ci.id = s.impacto_operativo_id
  WHERE s.id = p_solicitud_id AND s.deleted_at IS NULL;

  IF v IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Solicitud no encontrada'));
  END IF;
  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
