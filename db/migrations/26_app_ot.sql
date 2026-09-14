-- =============================================================================
-- 26_app_ot.sql · Órdenes de trabajo (cap. 8, 10, 25, 27)
--
-- El módulo central. Cada SP que toca una OT termina llamando a
-- app.sp_ot_trazabilidad_refrescar, de modo que la columna del árbol queda al día
-- sin que el backend tenga que acordarse de nada.
--
-- Los cambios de estado pasan SIEMPRE por app.sp_ot_cambiar_estado, que delega la
-- legalidad de la transición en internal.validar_transicion_ot (el Anexo A hecho
-- código). No existe ningún camino para editar el campo estado a mano.
-- =============================================================================
SET search_path = app, core, internal, public;

-- ── Crear la OT desde una solicitud aceptada (ST-02 → cap. 24.4) ─────────────
-- Es el punto de conversión: una solicitud aceptada genera UNA OT y sólo una.
-- La solicitud original se conserva intacta, incluso si la OT se cancela después
-- (cap. 7.3), para poder comparar reporte, diagnóstico y resultado.
CREATE OR REPLACE FUNCTION app.sp_ot_crear_desde_solicitud(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_solicitud_id UUID, p_sucursal_id UUID, p_empresa_ruc_id UUID, p_area_id UUID,
  p_tipo_mantenimiento_id UUID, p_prioridad_tecnica TEXT,
  p_coordinador_id UUID, p_es_emergencia BOOLEAN DEFAULT false,
  p_emergencia_justificacion TEXT DEFAULT NULL,
  p_tipo_trabajo_id UUID DEFAULT NULL, p_cecos_id UUID DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  s core.solicitud_trabajo%ROWTYPE;
  v core.orden_trabajo%ROWTYPE;
  v_numero TEXT;
  v_ruc_estado core.estado_registro;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:crear');
  PERFORM internal.assert_alcance(p_user_id, p_sucursal_id, p_empresa_ruc_id, p_area_id);

  SELECT * INTO s FROM core.solicitud_trabajo WHERE id = p_solicitud_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Solicitud no encontrada'));
  END IF;
  IF s.estado = 'convertida_en_ot' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('CONFLICT','Esa solicitud ya fue convertida en OT'));
  END IF;
  IF s.estado IN ('rechazada','duplicada') THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE',
        format('Una solicitud %s no se convierte en OT', s.estado)));
  END IF;

  -- No se permite abrir una OT bajo una RUC inactiva (Anexo C, QA-24).
  SELECT estado INTO v_ruc_estado FROM core.empresa_ruc WHERE id = p_empresa_ruc_id;
  IF v_ruc_estado <> 'activo' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','La empresa/RUC está inactiva y no admite OT nuevas','empresa_ruc_id'));
  END IF;

  IF p_es_emergencia AND btrim(coalesce(p_emergencia_justificacion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La emergencia exige justificación','emergencia_justificacion'));
  END IF;

  v_numero := internal.siguiente_numero(p_tenant_id, 'OT');

  INSERT INTO core.orden_trabajo (
    tenant_id, numero_ot, solicitud_origen_id,
    sucursal_id, empresa_ruc_id, area_id, cecos_id,
    tipo_mantenimiento_id, tipo_trabajo_id, prioridad_tecnica,
    es_emergencia, emergencia_justificacion, emergencia_declarada_por, emergencia_declarada_at,
    regularizacion_pendiente, coordinador_id, estado, created_by, updated_by)
  VALUES (
    p_tenant_id, v_numero, p_solicitud_id,
    p_sucursal_id, p_empresa_ruc_id, p_area_id, p_cecos_id,
    p_tipo_mantenimiento_id, p_tipo_trabajo_id, p_prioridad_tecnica::core.prioridad,
    coalesce(p_es_emergencia,false), p_emergencia_justificacion,
    CASE WHEN p_es_emergencia THEN p_user_id END,
    CASE WHEN p_es_emergencia THEN now() END,
    -- La emergencia cambia el orden administrativo, no elimina la regularización (cap. 3).
    coalesce(p_es_emergencia,false),
    p_coordinador_id, 'creada', p_user_id, p_user_id)
  RETURNING * INTO v;

  UPDATE core.solicitud_trabajo
     SET estado = 'convertida_en_ot', updated_by = p_user_id,
         fecha_primera_revision = coalesce(fecha_primera_revision, now())
   WHERE id = p_solicitud_id;

  INSERT INTO core.solicitud_decision (tenant_id, solicitud_id, tipo, estado_anterior, estado_nuevo, actor_id, comentario)
  VALUES (p_tenant_id, p_solicitud_id, 'aceptar', s.estado, 'convertida_en_ot', p_user_id,
          'Convertida en ' || v_numero);

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id, motivo_texto)
  VALUES (p_tenant_id, v.id, NULL, 'creada', p_user_id, 'Creada desde ' || s.numero);

  -- Cada OT tiene un canal de conversación (cap. 21.1). Se crea con la OT para que
  -- solicitante y coordinador puedan hablar desde el minuto cero.
  INSERT INTO core.conversacion (tenant_id, ot_id) VALUES (p_tenant_id, v.id);
  INSERT INTO core.conversacion_participante (tenant_id, conversacion_id, usuario_id, ve_notas_internas)
  SELECT p_tenant_id, c.id, s.solicitante_id, false FROM core.conversacion c WHERE c.ot_id = v.id;
  INSERT INTO core.conversacion_participante (tenant_id, conversacion_id, usuario_id, ve_notas_internas)
  SELECT p_tenant_id, c.id, p_coordinador_id, true FROM core.conversacion c WHERE c.ot_id = v.id
  ON CONFLICT DO NOTHING;

  INSERT INTO core.seguimiento_administrativo (tenant_id, ot_id) VALUES (p_tenant_id, v.id)
  ON CONFLICT (ot_id) DO NOTHING;

  PERFORM internal.registrar_evento_ot(p_tenant_id, v.id, 'ot', 'ot_creada', p_user_id,
    'orden_trabajo', v.id, NULL,
    jsonb_build_object('numero', v_numero, 'desde_solicitud', s.numero,
                       'emergencia', coalesce(p_es_emergencia,false)));

  -- Se avisa al solicitante de que su necesidad fue aceptada (cap. 24.4).
  PERFORM internal.notificar(p_tenant_id, s.solicitante_id, 'solicitud_aceptada',
    format('Su solicitud %s fue aceptada', s.numero),
    format('Se generó la orden de trabajo %s.', v_numero), v.id, 'orden_trabajo', v.id);

  IF p_coordinador_id <> p_user_id THEN
    PERFORM internal.notificar(p_tenant_id, p_coordinador_id, 'ot_asignada',
      format('Se le asignó la OT %s', v_numero), s.titulo, v.id, 'orden_trabajo', v.id);
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'orden_trabajo', v.id,
                                       NULL, to_jsonb(v) - 'trazabilidad');
  PERFORM app.sp_ot_trazabilidad_refrescar(v.id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'numero_ot', v_numero, 'estado', v.estado));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── Crear una OT derivada (cap. 10, 27) ──────────────────────────────────────
-- Se crea cuando el trabajo deja de ser UNA intervención y necesita control
-- independiente por especialidad, proveedor, alcance, responsable, cotización o
-- costo. No se crea una derivada sólo para guardar una nota (cap. 27.1).
--
-- El contexto organizacional se PROPONE desde el padre y puede cambiarse: es una
-- herencia sugerida, no impuesta (cap. 10, 27.2).
CREATE OR REPLACE FUNCTION app.sp_ot_crear_derivada(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_padre_id UUID, p_motivo_derivacion TEXT,
  p_tipo_mantenimiento_id UUID DEFAULT NULL, p_tipo_trabajo_id UUID DEFAULT NULL,
  p_prioridad_tecnica TEXT DEFAULT NULL, p_coordinador_id UUID DEFAULT NULL,
  p_sucursal_id UUID DEFAULT NULL, p_empresa_ruc_id UUID DEFAULT NULL, p_area_id UUID DEFAULT NULL,
  p_es_bloqueante BOOLEAN DEFAULT true, p_motivo_derivacion_id UUID DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  p core.orden_trabajo%ROWTYPE;
  v core.orden_trabajo%ROWTYPE;
  v_numero TEXT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:derivar');

  SELECT * INTO p FROM core.orden_trabajo WHERE id = p_ot_padre_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT padre no existe'));
  END IF;
  IF btrim(coalesce(p_motivo_derivacion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La derivación exige motivo','motivo_derivacion'));
  END IF;

  v_numero := internal.siguiente_numero(p_tenant_id, 'OT');

  INSERT INTO core.orden_trabajo (
    tenant_id, numero_ot, ot_padre_id, motivo_derivacion_id, motivo_derivacion_texto,
    es_bloqueante_para_padre,
    sucursal_id, empresa_ruc_id, area_id, cecos_id,
    tipo_mantenimiento_id, tipo_trabajo_id, prioridad_tecnica, coordinador_id,
    estado, created_by, updated_by)
  VALUES (
    p_tenant_id, v_numero, p_ot_padre_id, p_motivo_derivacion_id, btrim(p_motivo_derivacion),
    coalesce(p_es_bloqueante, true),
    -- Herencia propuesta desde el padre, sobreescribible por el coordinador.
    coalesce(p_sucursal_id,    p.sucursal_id),
    coalesce(p_empresa_ruc_id, p.empresa_ruc_id),
    coalesce(p_area_id,        p.area_id),
    p.cecos_id,
    coalesce(p_tipo_mantenimiento_id, p.tipo_mantenimiento_id),
    coalesce(p_tipo_trabajo_id,       p.tipo_trabajo_id),
    coalesce(nullif(p_prioridad_tecnica,'')::core.prioridad, p.prioridad_tecnica),
    coalesce(p_coordinador_id, p.coordinador_id),
    'creada', p_user_id, p_user_id)
  RETURNING * INTO v;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id, motivo_texto)
  VALUES (p_tenant_id, v.id, NULL, 'creada', p_user_id, 'Derivada de ' || p.numero_ot);

  INSERT INTO core.conversacion (tenant_id, ot_id) VALUES (p_tenant_id, v.id);
  INSERT INTO core.conversacion_participante (tenant_id, conversacion_id, usuario_id, ve_notas_internas)
  SELECT p_tenant_id, c.id, coalesce(p_coordinador_id, p.coordinador_id), true
    FROM core.conversacion c WHERE c.ot_id = v.id;
  INSERT INTO core.seguimiento_administrativo (tenant_id, ot_id) VALUES (p_tenant_id, v.id)
  ON CONFLICT (ot_id) DO NOTHING;

  -- El hecho queda en la bitácora de AMBAS: en la hija su origen, en el padre la
  -- derivación. Así ninguna de las dos historias tiene un hueco.
  PERFORM internal.registrar_evento_ot(p_tenant_id, v.id, 'ot', 'derivada_creada', p_user_id,
    'orden_trabajo', v.id, NULL,
    jsonb_build_object('numero', v_numero, 'padre', p.numero_ot, 'bloqueante', coalesce(p_es_bloqueante,true)),
    p_motivo_derivacion);
  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_padre_id, 'ot', 'derivada_generada', p_user_id,
    'orden_trabajo', v.id, NULL,
    jsonb_build_object('numero', v_numero, 'bloqueante', coalesce(p_es_bloqueante,true)),
    p_motivo_derivacion);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear_derivada', 'orden_trabajo',
                                       v.id, NULL, to_jsonb(v) - 'trazabilidad', p_motivo_derivacion);

  PERFORM app.sp_ot_trazabilidad_refrescar(v.id, true);
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_padre_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'numero_ot', v_numero, 'ot_padre', p.numero_ot, 'nivel', v.nivel));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── El único camino para cambiar de estado ───────────────────────────────────
CREATE OR REPLACE FUNCTION app.sp_ot_cambiar_estado(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_nuevo_estado TEXT, p_motivo TEXT DEFAULT NULL,
  p_motivo_id UUID DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_nuevo core.ot_estado := p_nuevo_estado::core.ot_estado;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:cambiar_estado');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);

  IF o.estado = v_nuevo THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('CONFLICT','La OT ya está en ese estado'));
  END IF;

  -- El Anexo A decide. Si el par no es legal o faltan condiciones, esto lanza.
  PERFORM internal.validar_transicion_ot(p_ot_id, o.estado, v_nuevo, p_motivo);

  -- Salir de CERRADA es reapertura y tiene su propio SP; aquí se bloquea para que
  -- nadie se la salte por descuido.
  IF o.estado = 'cerrada' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE',
        'Una OT cerrada se reabre con app.sp_ot_reabrir, que exige permiso y motivo'));
  END IF;

  UPDATE core.orden_trabajo
     SET estado = v_nuevo,
         motivo_cancelacion_id   = CASE WHEN v_nuevo = 'cancelada' THEN p_motivo_id ELSE motivo_cancelacion_id END,
         cancelacion_observacion = CASE WHEN v_nuevo = 'cancelada' THEN p_motivo ELSE cancelacion_observacion END,
         fecha_cancelacion       = CASE WHEN v_nuevo = 'cancelada' THEN now() ELSE fecha_cancelacion END,
         updated_by = p_user_id
   WHERE id = p_ot_id;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo,
                                        motivo_id, motivo_texto, actor_id)
  VALUES (p_tenant_id, p_ot_id, o.estado, v_nuevo, p_motivo_id, p_motivo, p_user_id);

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ot', 'estado_cambiado', p_user_id,
    'orden_trabajo', p_ot_id,
    jsonb_build_object('estado', o.estado), jsonb_build_object('estado', v_nuevo), p_motivo);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'cambiar_estado', 'orden_trabajo',
    p_ot_id, jsonb_build_object('estado', o.estado), jsonb_build_object('estado', v_nuevo), p_motivo);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado_anterior', o.estado, 'estado', v_nuevo));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── OT-02 · Cancelar, resolviendo las derivadas activas (cap. 25.3) ─────────
-- Al cancelar una principal con hijas activas el usuario DECIDE qué pasa con
-- ellas: cancelarlas, independizarlas o resolverlas antes. La relación se
-- conserva en todos los casos (Anexo C, QA-17).
CREATE OR REPLACE FUNCTION app.sp_ot_cancelar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_motivo_id UUID, p_observacion TEXT,
  p_tratamiento_derivadas TEXT DEFAULT 'bloquear')   -- 'cancelar' | 'independizar' | 'bloquear'
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_hijas INT;
  h RECORD;
  v_afectadas JSONB := '[]'::jsonb;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:cancelar');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF btrim(coalesce(p_observacion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La cancelación exige observación libre obligatoria','observacion'));
  END IF;

  SELECT count(*) INTO v_hijas
    FROM core.orden_trabajo
   WHERE ot_padre_id = p_ot_id AND deleted_at IS NULL AND estado NOT IN ('cerrada','cancelada');

  IF v_hijas > 0 AND p_tratamiento_derivadas = 'bloquear' THEN
    -- Se devuelve la lista para que la interfaz pueda mostrarlas y pedir la decisión.
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE',
      format('La OT tiene %s derivada(s) activa(s). Indique si cancelarlas, independizarlas o resolverlas antes.', v_hijas)),
      'data', jsonb_build_object('derivadas_activas', (
        SELECT jsonb_agg(jsonb_build_object('id', h2.id, 'numero', h2.numero_ot, 'estado', h2.estado))
          FROM core.orden_trabajo h2
         WHERE h2.ot_padre_id = p_ot_id AND h2.deleted_at IS NULL
           AND h2.estado NOT IN ('cerrada','cancelada'))));
  END IF;

  FOR h IN SELECT * FROM core.orden_trabajo
            WHERE ot_padre_id = p_ot_id AND deleted_at IS NULL AND estado NOT IN ('cerrada','cancelada')
  LOOP
    IF p_tratamiento_derivadas = 'cancelar' THEN
      -- Cada cancelación exige su propio motivo; se hereda el del padre con nota.
      PERFORM app.sp_ot_cancelar(p_user_id, p_tenant_id, p_is_super_admin, h.id, p_motivo_id,
        format('Cancelada junto con la OT superior %s. %s', o.numero_ot, p_observacion), 'cancelar');
      v_afectadas := v_afectadas || jsonb_build_array(
        jsonb_build_object('numero', h.numero_ot, 'accion', 'cancelada'));
    ELSIF p_tratamiento_derivadas = 'independizar' THEN
      -- Sobrevive a la cancelación del padre sólo porque el usuario lo decidió
      -- expresamente, y la auditoría lo registra (cap. 27.2).
      UPDATE core.orden_trabajo
         SET independizada_de_padre = true, es_bloqueante_para_padre = false, updated_by = p_user_id
       WHERE id = h.id;
      PERFORM internal.registrar_evento_ot(p_tenant_id, h.id, 'ot', 'independizada_de_padre', p_user_id,
        'orden_trabajo', h.id, NULL, jsonb_build_object('padre', o.numero_ot),
        'El padre fue cancelado y se decidió mantenerla activa');
      v_afectadas := v_afectadas || jsonb_build_array(
        jsonb_build_object('numero', h.numero_ot, 'accion', 'independizada'));
    END IF;
  END LOOP;

  PERFORM internal.validar_transicion_ot(p_ot_id, o.estado, 'cancelada', p_observacion);

  UPDATE core.orden_trabajo
     SET estado = 'cancelada', motivo_cancelacion_id = p_motivo_id,
         cancelacion_observacion = p_observacion, fecha_cancelacion = now(), updated_by = p_user_id
   WHERE id = p_ot_id;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo,
                                        motivo_id, motivo_texto, actor_id)
  VALUES (p_tenant_id, p_ot_id, o.estado, 'cancelada', p_motivo_id, p_observacion, p_user_id);

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ot', 'ot_cancelada', p_user_id,
    'orden_trabajo', p_ot_id, jsonb_build_object('estado', o.estado),
    jsonb_build_object('estado','cancelada','derivadas', v_afectadas), p_observacion);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'cancelar', 'orden_trabajo',
    p_ot_id, jsonb_build_object('estado', o.estado), jsonb_build_object('estado','cancelada'), p_observacion);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado','cancelada', 'derivadas_afectadas', v_afectadas));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── OT-03 · Cambiar prioridad técnica (cap. 25.4) ───────────────────────────
-- La prioridad percibida por el solicitante NUNCA se toca: son dos cosas
-- distintas y el histórico debe poder compararlas.
CREATE OR REPLACE FUNCTION app.sp_ot_cambiar_prioridad(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_prioridad TEXT, p_motivo TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_nueva core.prioridad := p_prioridad::core.prioridad;
  v_exige_motivo BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:cambiar_prioridad');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  -- Exige motivo si se BAJA una prioridad crítica/alta, o si se cambia estando ya
  -- en trabajo: son los dos casos que hay que poder justificar después (cap. 25.4).
  -- Comparación por ENUM, no por texto: el orden de declaración es
  -- critica < alta < media < baja, así que "mayor" = menos urgente. Comparar
  -- como texto daría 'alta' < 'baja' alfabéticamente y leería al revés.
  v_exige_motivo :=
    (o.prioridad_tecnica IN ('critica','alta') AND v_nueva > o.prioridad_tecnica)
    OR o.estado = 'en_trabajo';

  IF v_exige_motivo AND btrim(coalesce(p_motivo,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','Bajar una prioridad crítica/alta o cambiarla en ejecución exige motivo','motivo'));
  END IF;

  UPDATE core.orden_trabajo SET prioridad_tecnica = v_nueva, updated_by = p_user_id WHERE id = p_ot_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ot', 'prioridad_cambiada', p_user_id,
    'orden_trabajo', p_ot_id,
    jsonb_build_object('prioridad_tecnica', o.prioridad_tecnica),
    jsonb_build_object('prioridad_tecnica', v_nueva), p_motivo);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'cambiar_prioridad', 'orden_trabajo',
    p_ot_id, jsonb_build_object('prioridad_tecnica', o.prioridad_tecnica),
    jsonb_build_object('prioridad_tecnica', v_nueva), p_motivo);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'prioridad_anterior', o.prioridad_tecnica, 'prioridad_tecnica', v_nueva));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Actualiza el contexto técnico de la OT (parche JSONB, como en el proyecto hermano).
CREATE OR REPLACE FUNCTION app.sp_ot_actualizar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_ot_id UUID, p_payload JSONB)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v_antes JSONB; v_despues JSONB; o core.orden_trabajo%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:editar');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF o.estado IN ('cerrada','cancelada') THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE', format('Una OT %s no se edita; use reapertura si corresponde', o.estado)));
  END IF;

  SELECT to_jsonb(x) - 'trazabilidad' INTO v_antes FROM core.orden_trabajo x WHERE x.id = p_ot_id;

  UPDATE core.orden_trabajo SET
    sucursal_id           = coalesce((p_payload->>'sucursal_id')::uuid, sucursal_id),
    empresa_ruc_id        = coalesce((p_payload->>'empresa_ruc_id')::uuid, empresa_ruc_id),
    area_id               = coalesce((p_payload->>'area_id')::uuid, area_id),
    cecos_id              = coalesce((p_payload->>'cecos_id')::uuid, cecos_id),
    tipo_mantenimiento_id = coalesce((p_payload->>'tipo_mantenimiento_id')::uuid, tipo_mantenimiento_id),
    tipo_trabajo_id       = coalesce((p_payload->>'tipo_trabajo_id')::uuid, tipo_trabajo_id),
    coordinador_id        = coalesce((p_payload->>'coordinador_id')::uuid, coordinador_id),
    ejecutor_id           = coalesce((p_payload->>'ejecutor_id')::uuid, ejecutor_id),
    updated_by            = p_user_id
  WHERE id = p_ot_id;

  SELECT to_jsonb(x) - 'trazabilidad' INTO v_despues FROM core.orden_trabajo x WHERE x.id = p_ot_id;

  IF (p_payload ? 'ejecutor_id') AND (v_antes->>'ejecutor_id') IS DISTINCT FROM (v_despues->>'ejecutor_id') THEN
    PERFORM internal.notificar(p_tenant_id, (v_despues->>'ejecutor_id')::uuid, 'ot_asignada',
      format('Se le asignó la OT %s', o.numero_ot), NULL, p_ot_id, 'orden_trabajo', p_ot_id);
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'actualizar', 'orden_trabajo',
                                       p_ot_id, v_antes, v_despues);
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', v_despues);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- ── Consultas ────────────────────────────────────────────────────────────────
-- El listado es la bandeja del coordinador (cap. 35.1): trae lo justo para
-- decidir y ordenar, sin arrastrar el árbol de trazabilidad entero.
CREATE OR REPLACE FUNCTION app.fn_ot_listar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_filtros JSONB DEFAULT '{}'::jsonb, p_page INT DEFAULT 1, p_page_size INT DEFAULT 20)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v_size INT := least(greatest(coalesce(p_page_size,20),1),100);
  v_off  INT := (greatest(coalesce(p_page,1),1)-1)*v_size;
  v_total INT; v_data JSONB; v_global BOOLEAN; v_ve_costos BOOLEAN;
  v_estado    TEXT := p_filtros->>'estado';
  v_admin     TEXT := p_filtros->>'estado_administrativo';
  v_sucursal  TEXT := p_filtros->>'sucursal_id';
  v_empresa   TEXT := p_filtros->>'empresa_ruc_id';
  v_area      TEXT := p_filtros->>'area_id';
  v_prioridad TEXT := p_filtros->>'prioridad_tecnica';
  v_tipo_trab TEXT := p_filtros->>'tipo_trabajo_id';
  v_resp      TEXT := p_filtros->>'responsable_id';
  v_desde     TEXT := p_filtros->>'desde';
  v_hasta     TEXT := p_filtros->>'hasta';
  v_emerg     BOOLEAN := (p_filtros->>'solo_emergencias')::boolean;
  v_solo_raiz BOOLEAN := coalesce((p_filtros->>'solo_principales')::boolean, false);
  v_padre     TEXT := p_filtros->>'ot_padre_id';
  v_buscar    TEXT := internal.normalizar_busqueda(p_filtros->>'buscar');
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:listar');
  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  -- El solicitante no ve costos (cap. 13, QA-18): se decide una vez y se aplica
  -- al armar cada fila.
  v_ve_costos := p_is_super_admin OR EXISTS (
    SELECT 1 FROM core.usuario_rol ur
      JOIN core.rol_permiso rp ON rp.rol_id = ur.rol_id
      JOIN core.permiso p      ON p.id = rp.permiso_id
     WHERE ur.usuario_id = p_user_id AND p.codigo = 'costos:ver');

  -- Una sola sentencia con CTE, no una tabla temporal: una función STABLE no
  -- puede ejecutar CREATE TABLE, y además así el filtro se evalúa una vez y lo
  -- comparten el conteo y la página.
  WITH filtrado AS (
    SELECT o.id
      FROM core.orden_trabajo o
     WHERE o.deleted_at IS NULL
       AND (v_global OR o.tenant_id = p_tenant_id)
       AND (v_estado    IS NULL OR o.estado::text = v_estado)
       AND (v_admin     IS NULL OR o.estado_administrativo::text = v_admin)
       AND (v_sucursal  IS NULL OR o.sucursal_id = v_sucursal::uuid)
       AND (v_empresa   IS NULL OR o.empresa_ruc_id = v_empresa::uuid)
       AND (v_area      IS NULL OR o.area_id = v_area::uuid)
       AND (v_prioridad IS NULL OR o.prioridad_tecnica::text = v_prioridad)
       AND (v_tipo_trab IS NULL OR o.tipo_trabajo_id = v_tipo_trab::uuid)
       AND (v_resp      IS NULL OR o.coordinador_id = v_resp::uuid OR o.ejecutor_id = v_resp::uuid)
       AND (v_desde     IS NULL OR o.fecha_creacion >= v_desde::timestamptz)
       AND (v_hasta     IS NULL OR o.fecha_creacion <  (v_hasta::date + 1)::timestamptz)
       AND (v_emerg     IS NULL OR o.es_emergencia = v_emerg)
       AND (NOT v_solo_raiz OR o.ot_padre_id IS NULL)
       AND (v_padre     IS NULL OR o.ot_padre_id = v_padre::uuid)
       AND (nullif(v_buscar,'') IS NULL
            OR internal.normalizar_busqueda(o.numero_ot) LIKE '%'||v_buscar||'%'
            OR EXISTS (SELECT 1 FROM core.solicitud_trabajo s
                        WHERE s.id = o.solicitud_origen_id
                          AND internal.normalizar_busqueda(s.titulo||' '||s.descripcion) LIKE '%'||v_buscar||'%'))
       AND (v_global
            OR NOT EXISTS (SELECT 1 FROM core.usuario_alcance ua WHERE ua.usuario_id = p_user_id)
            OR EXISTS (SELECT 1 FROM core.usuario_alcance ua
                        WHERE ua.usuario_id = p_user_id
                          AND (ua.sucursal_id    IS NULL OR ua.sucursal_id    = o.sucursal_id)
                          AND (ua.empresa_ruc_id IS NULL OR ua.empresa_ruc_id = o.empresa_ruc_id)
                          AND (ua.area_id        IS NULL OR ua.area_id        = o.area_id)))
  ),
  pagina AS (
    SELECT jsonb_build_object(
      'id', o.id, 'numero_ot', o.numero_ot, 'estado', o.estado, 'condicion', o.condicion,
      'estado_administrativo', o.estado_administrativo,
      -- Indicador combinado que exige el cap. 14.3 para listas y tablero.
      'indicador', CASE WHEN o.estado = 'cerrada' AND o.estado_administrativo <> 'administracion_completa'
                        THEN 'CERRADA - ' || upper(replace(o.estado_administrativo::text,'_',' '))
                        ELSE upper(replace(o.estado::text,'_',' ')) END,
      'titulo', coalesce(s.titulo, o.motivo_derivacion_texto, o.numero_ot),
      'prioridad_tecnica', o.prioridad_tecnica,
      'es_emergencia', o.es_emergencia,
      'regularizacion_pendiente', o.regularizacion_pendiente,
      'nivel', o.nivel, 'es_derivada', o.ot_padre_id IS NOT NULL,
      'ot_padre', pa.numero_ot,
      'derivadas_activas', (SELECT count(*) FROM core.orden_trabajo h
                             WHERE h.ot_padre_id = o.id AND h.deleted_at IS NULL
                               AND h.estado NOT IN ('cerrada','cancelada')),
      'sucursal', su.nombre, 'empresa_ruc', er.razon_social, 'area', ar.nombre,
      'tipo_trabajo', tt.nombre,
      'coordinador', co.nombres||' '||co.apellidos,
      'ejecutor', ej.nombres||' '||ej.apellidos,
      'fecha_creacion', o.fecha_creacion,
      'fecha_inicio_real', o.fecha_inicio_real,
      'fecha_termino_real', o.fecha_termino_real,
      'fecha_cierre', o.fecha_cierre,
      'duracion_dias', CASE WHEN o.fecha_inicio_real IS NOT NULL AND o.fecha_termino_real IS NOT NULL
                            THEN round(extract(epoch FROM (o.fecha_termino_real - o.fecha_inicio_real))/86400.0, 2) END,
      'tiene_diagnostico', EXISTS (SELECT 1 FROM core.diagnostico d WHERE d.ot_id=o.id AND d.vigente),
      'tiene_cotizacion',  EXISTS (SELECT 1 FROM core.cotizacion c WHERE c.ot_id=o.id AND c.vigente AND NOT c.invalidada),
      -- El solicitante no ve costos (cap. 13, QA-18): se decide una vez arriba.
      'monto_cotizado', CASE WHEN v_ve_costos THEN
        (SELECT c.monto FROM core.cotizacion c WHERE c.ot_id=o.id AND c.vigente AND NOT c.invalidada LIMIT 1) END,
      'moneda', CASE WHEN v_ve_costos THEN
        (SELECT c.moneda FROM core.cotizacion c WHERE c.ot_id=o.id AND c.vigente AND NOT c.invalidada LIMIT 1) END,
      'veces_reabierta', o.veces_reabierta,
      'trazabilidad_version', o.trazabilidad_version
    ) AS d
    FROM filtrado f
    JOIN core.orden_trabajo o ON o.id = f.id
    LEFT JOIN core.solicitud_trabajo s ON s.id = o.solicitud_origen_id
    LEFT JOIN core.orden_trabajo pa    ON pa.id = o.ot_padre_id
    LEFT JOIN core.sucursal su         ON su.id = o.sucursal_id
    LEFT JOIN core.empresa_ruc er      ON er.id = o.empresa_ruc_id
    LEFT JOIN core.area ar             ON ar.id = o.area_id
    LEFT JOIN core.tipo_trabajo tt     ON tt.id = o.tipo_trabajo_id
    LEFT JOIN core.usuario co          ON co.id = o.coordinador_id
    LEFT JOIN core.usuario ej          ON ej.id = o.ejecutor_id
    ORDER BY o.prioridad_tecnica NULLS LAST, o.fecha_creacion DESC
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

-- Ficha completa de la OT: DEVUELVE EL ÁRBOL DE TRAZABILIDAD, garantizando que
-- esté fresco. Éste es el camino de lectura perezoso del motor de 11.
CREATE OR REPLACE FUNCTION app.fn_ot_obtener(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN, p_ot_id UUID)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_arbol JSONB;
  v_ve_costos BOOLEAN;
  v_ve_interno BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:ver');

  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id AND deleted_at IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);

  v_arbol := internal.fn_ot_trazabilidad_fresca(p_ot_id);

  v_ve_costos := p_is_super_admin OR EXISTS (
    SELECT 1 FROM core.usuario_rol ur JOIN core.rol_permiso rp ON rp.rol_id=ur.rol_id
      JOIN core.permiso p ON p.id=rp.permiso_id
     WHERE ur.usuario_id=p_user_id AND p.codigo='costos:ver');
  v_ve_interno := p_is_super_admin OR EXISTS (
    SELECT 1 FROM core.usuario_rol ur JOIN core.rol_permiso rp ON rp.rol_id=ur.rol_id
      JOIN core.permiso p ON p.id=rp.permiso_id
     WHERE ur.usuario_id=p_user_id AND p.codigo='administrativo:ver');

  -- QA-18: el solicitante no ve costos, RUC, CECOS, cotizaciones ni notas
  -- internas. Se poda el árbol ANTES de devolverlo, no en el frontend.
  IF NOT v_ve_costos THEN
    v_arbol := v_arbol - 'costos' - 'cotizaciones';
  END IF;
  IF NOT v_ve_interno THEN
    v_arbol := v_arbol - 'administrativo';
    v_arbol := jsonb_set(v_arbol, '{organizacion,empresa_ruc}', 'null'::jsonb, false);
    v_arbol := jsonb_set(v_arbol, '{organizacion,cecos}', 'null'::jsonb, false);
    IF v_arbol ? 'conversacion' THEN
      v_arbol := jsonb_set(v_arbol, '{conversacion,mensajes}', coalesce((
        SELECT jsonb_agg(m) FROM jsonb_array_elements(v_arbol->'conversacion'->'mensajes') m
         WHERE m->>'visibilidad' IS DISTINCT FROM 'interna'), '[]'::jsonb));
    END IF;
  END IF;

  RETURN jsonb_build_object('ok', true, 'data', v_arbol);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
