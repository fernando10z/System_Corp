-- =============================================================================
-- 10_internal_helpers.sql
--
-- Helpers privados. Todos SECURITY DEFINER con search_path fijo, y ninguno
-- alcanzable por el rol de aplicación (90_grants revoca EXECUTE en `internal`).
--
-- Aquí vive el guardián de las transiciones de estado: internal.validar_transicion_ot
-- implementa LITERALMENTE la tabla del Anexo A. Los cambios de estado se ejecutan
-- por comandos funcionales, nunca por edición libre del campo (regla 23.1).
-- =============================================================================
SET search_path = core, internal, public;

-- ── Errores ──────────────────────────────────────────────────────────────────
--
-- MIP usa una CLASE DE SQLSTATE PROPIA ('MIP') para sus errores de negocio, y no
-- la clase P0 de PL/pgSQL. El motivo no es estético:
--
--   P0004 es `assert_failure`, y `EXCEPTION WHEN OTHERS` se niega deliberadamente
--   a capturarlo (junto con `query_canceled`). Un SP que usara P0004 para señalar
--   "regla de negocio incumplida" reventaría la conexión en lugar de devolver el
--   sobre {ok:false,...}, y el backend vería un 500 en vez de un 422.
--
-- Códigos de MIP:
--   MIP01  VALIDATION     falta un dato o no cumple su formato        → 400
--   MIP02  NOT_FOUND      el registro no existe o no es visible       → 404
--   MIP03  CONFLICT       choca con el estado actual de los datos     → 409
--   MIP04  BUSINESS_RULE  una regla del documento lo impide           → 422
--   42501  FORBIDDEN      sin permiso o fuera de alcance (estándar)   → 403

-- Traduce el SQLSTATE crudo al código semántico que viaja al backend.
CREATE OR REPLACE FUNCTION internal.codigo_error(p_sqlstate TEXT)
RETURNS TEXT LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE p_sqlstate
    WHEN 'MIP01' THEN 'VALIDATION'
    WHEN 'MIP02' THEN 'NOT_FOUND'
    WHEN 'MIP03' THEN 'CONFLICT'
    WHEN 'MIP04' THEN 'BUSINESS_RULE'
    WHEN '42501' THEN 'FORBIDDEN'
    WHEN 'P0001' THEN 'VALIDATION'      -- raise_exception sin ERRCODE explícito
    WHEN 'P0002' THEN 'NOT_FOUND'       -- no_data_found
    WHEN '23505' THEN 'CONFLICT'        -- unique_violation
    WHEN '23503' THEN 'CONFLICT'        -- foreign_key_violation
    WHEN '23514' THEN 'VALIDATION'      -- check_violation
    WHEN '23502' THEN 'VALIDATION'      -- not_null_violation
    WHEN '22P02' THEN 'VALIDATION'      -- invalid_text_representation
    ELSE 'INTERNAL_ERROR'
  END;
$$;

CREATE OR REPLACE FUNCTION internal.error_jsonb(p_code TEXT, p_message TEXT, p_field TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE sql IMMUTABLE AS $$
  SELECT jsonb_strip_nulls(jsonb_build_object(
    -- Si llega un SQLSTATE crudo (5 caracteres) se traduce; si llega ya un código
    -- semántico ('NOT_FOUND', 'FORBIDDEN'...) se respeta tal cual.
    'code',    CASE WHEN p_code ~ '^[0-9A-Z]{5}$' THEN internal.codigo_error(p_code) ELSE p_code END,
    'message', p_message,
    'field',   p_field,
    'sqlstate', CASE WHEN p_code ~ '^[0-9A-Z]{5}$' THEN p_code END));
$$;

-- ── Acceso y permisos ────────────────────────────────────────────────────────

-- Un rol con scope global ve más allá de su tenant. Se usa SIEMPRE en los filtros
-- de lectura, nunca `p_is_super_admin` a secas.
CREATE OR REPLACE FUNCTION internal.es_acceso_global(p_user_id UUID, p_is_super_admin BOOLEAN)
RETURNS BOOLEAN LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
BEGIN
  IF p_is_super_admin THEN RETURN true; END IF;
  IF p_user_id IS NULL THEN RETURN false; END IF;
  RETURN EXISTS (
    SELECT 1 FROM core.usuario u
      JOIN core.usuario_rol ur ON ur.usuario_id = u.id
      JOIN core.rol r          ON r.id = ur.rol_id
     WHERE u.id = p_user_id AND u.deleted_at IS NULL AND u.estado = 'activo'
       AND r.scope IN ('global','global_restricted'));
END; $$;

-- Aislamiento duro entre clientes (cap. 21.3, QA-25).
CREATE OR REPLACE FUNCTION internal.assert_acceso_tenant(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN)
RETURNS VOID LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, internal, public AS $$
DECLARE v_tenant_user UUID; v_super BOOLEAN; v_estado core.estado_usuario;
BEGIN
  IF p_is_super_admin THEN RETURN; END IF;
  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuario no autenticado' USING ERRCODE = '42501';
  END IF;

  SELECT tenant_id, is_super_admin, estado INTO v_tenant_user, v_super, v_estado
    FROM core.usuario WHERE id = p_user_id AND deleted_at IS NULL;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Usuario no existe' USING ERRCODE = '42501';
  END IF;
  IF v_estado <> 'activo' THEN
    RAISE EXCEPTION 'Usuario inactivo o bloqueado' USING ERRCODE = '42501';
  END IF;
  IF v_super THEN RETURN; END IF;
  IF internal.es_acceso_global(p_user_id, false) THEN RETURN; END IF;

  IF v_tenant_user IS NULL OR v_tenant_user <> p_tenant_id THEN
    RAISE EXCEPTION 'Sin acceso al tenant indicado' USING ERRCODE = '42501';
  END IF;
END; $$;

CREATE OR REPLACE FUNCTION internal.assert_permiso(p_user_id UUID, p_permiso TEXT)
RETURNS VOID LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, internal, public AS $$
DECLARE v_super BOOLEAN;
BEGIN
  SELECT is_super_admin INTO v_super FROM core.usuario WHERE id = p_user_id AND deleted_at IS NULL;
  IF coalesce(v_super, false) THEN RETURN; END IF;

  IF NOT EXISTS (
    SELECT 1
      FROM core.usuario_rol ur
      JOIN core.rol_permiso rp ON rp.rol_id = ur.rol_id
      JOIN core.permiso p      ON p.id = rp.permiso_id
     WHERE ur.usuario_id = p_user_id AND p.codigo = p_permiso)
  THEN
    RAISE EXCEPTION 'Permiso denegado: %', p_permiso USING ERRCODE = '42501';
  END IF;
END; $$;

-- Cap. 4.1: los permisos se aplican JUNTO CON el alcance organizacional. Una fila
-- de usuario_alcance con NULL en un nivel significa "todo ese nivel".
CREATE OR REPLACE FUNCTION internal.assert_alcance(
  p_user_id UUID, p_sucursal_id UUID, p_empresa_ruc_id UUID, p_area_id UUID)
RETURNS VOID LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, internal, public AS $$
DECLARE v_super BOOLEAN;
BEGIN
  SELECT is_super_admin INTO v_super FROM core.usuario WHERE id = p_user_id AND deleted_at IS NULL;
  IF coalesce(v_super, false) THEN RETURN; END IF;
  IF internal.es_acceso_global(p_user_id, false) THEN RETURN; END IF;

  -- Sin filas de alcance el usuario no está restringido a nivel organizacional:
  -- su límite es el tenant, que ya validó assert_acceso_tenant.
  IF NOT EXISTS (SELECT 1 FROM core.usuario_alcance WHERE usuario_id = p_user_id) THEN
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM core.usuario_alcance a
     WHERE a.usuario_id = p_user_id
       AND (a.sucursal_id    IS NULL OR p_sucursal_id    IS NULL OR a.sucursal_id    = p_sucursal_id)
       AND (a.empresa_ruc_id IS NULL OR p_empresa_ruc_id IS NULL OR a.empresa_ruc_id = p_empresa_ruc_id)
       AND (a.area_id        IS NULL OR p_area_id        IS NULL OR a.area_id        = p_area_id))
  THEN
    RAISE EXCEPTION 'Fuera del alcance organizacional autorizado' USING ERRCODE = '42501';
  END IF;
END; $$;

-- ── internal.ot_visible — el aislamiento entre clientes, en la lectura ───────
-- assert_acceso_tenant comprueba que el USUARIO pertenece al tenant de su token.
-- No dice nada sobre la OT: hasta que existió esta función, cualquier usuario
-- autenticado con permiso podía leer —y operar— una OT de OTRO cliente sin más
-- que conocer su id, porque la búsqueda era `WHERE id = p_ot_id` a secas. Es
-- justo lo que prohíbe el cap. 21.3 y comprueba QA-25.
--
-- Devuelve la fila sólo si pertenece al tenant, o si quien pregunta tiene scope
-- global (es_acceso_global, no `p_is_super_admin` a secas, como pide la nota de
-- esa función). Si no, devuelve una fila vacía: quien llama responde "no existe"
-- y no se confirma que el identificador sea real.
CREATE OR REPLACE FUNCTION internal.ot_visible(
  p_ot_id UUID, p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN)
RETURNS core.orden_trabajo LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
DECLARE o core.orden_trabajo%ROWTYPE;
BEGIN
  SELECT * INTO o FROM core.orden_trabajo
   WHERE id = p_ot_id
     AND deleted_at IS NULL
     AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  RETURN o;
END; $$;

-- ── Correlativos ─────────────────────────────────────────────────────────────
-- El número de OT es único dentro del tenant y NO se reutiliza (cap. 25.1).
-- El FOR UPDATE serializa los concurrentes sobre la fila del correlativo.
CREATE OR REPLACE FUNCTION internal.siguiente_numero(
  p_tenant_id UUID, p_tipo_documento TEXT, p_prefijo TEXT DEFAULT NULL)
RETURNS VARCHAR LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, internal, public AS $$
DECLARE v_prefijo TEXT := coalesce(p_prefijo, p_tipo_documento); v_numero INT;
BEGIN
  INSERT INTO core.correlativo (tenant_id, tipo_documento, prefijo, ultimo_numero)
  VALUES (p_tenant_id, p_tipo_documento, v_prefijo, 0)
  ON CONFLICT (tenant_id, tipo_documento) DO NOTHING;

  UPDATE core.correlativo
     SET ultimo_numero = ultimo_numero + 1, updated_at = now()
   WHERE tenant_id = p_tenant_id AND tipo_documento = p_tipo_documento
  RETURNING ultimo_numero, prefijo INTO v_numero, v_prefijo;

  RETURN v_prefijo || '-' || lpad(v_numero::text, 6, '0');   -- OT-000042
END; $$;

-- ── Auditoría y bitácora ─────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION internal.registrar_auditoria(
  p_actor_id UUID, p_tenant_id UUID, p_accion TEXT, p_entidad TEXT, p_entidad_id UUID,
  p_antes JSONB DEFAULT NULL, p_despues JSONB DEFAULT NULL, p_motivo TEXT DEFAULT NULL)
RETURNS VOID LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, audit, internal, public AS $$
DECLARE v_diff JSONB := '{}'::jsonb; k TEXT;
BEGIN
  -- El diff campo a campo es lo que pide el cap. 33: "valores anteriores/nuevos".
  IF p_antes IS NOT NULL AND p_despues IS NOT NULL THEN
    FOR k IN SELECT jsonb_object_keys(p_antes) UNION SELECT jsonb_object_keys(p_despues) LOOP
      IF (p_antes->k) IS DISTINCT FROM (p_despues->k) THEN
        v_diff := v_diff || jsonb_build_object(k, jsonb_build_object(
          'antes', p_antes->k, 'despues', p_despues->k));
      END IF;
    END LOOP;
  END IF;

  INSERT INTO audit.audit_log (tenant_id, actor_id, accion, entidad, entidad_id,
                               valor_anterior, valor_nuevo, diff, motivo, request_id)
  VALUES (p_tenant_id, p_actor_id, p_accion, p_entidad, p_entidad_id,
          p_antes, p_despues, nullif(v_diff, '{}'::jsonb), p_motivo,
          nullif(current_setting('mip.request_id', true), ''));
END; $$;

-- Bitácora append-only de la OT: el hilo legible que se embebe en el árbol.
CREATE OR REPLACE FUNCTION internal.registrar_evento_ot(
  p_tenant_id UUID, p_ot_id UUID, p_dominio core.dominio_evento, p_evento TEXT,
  p_actor_id UUID, p_entidad_tipo TEXT DEFAULT NULL, p_entidad_id UUID DEFAULT NULL,
  p_anterior JSONB DEFAULT NULL, p_nuevo JSONB DEFAULT NULL, p_motivo TEXT DEFAULT NULL)
RETURNS VOID LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, internal, public AS $$
BEGIN
  INSERT INTO core.ot_evento (tenant_id, ot_id, dominio, evento, entidad_tipo, entidad_id,
                              valor_anterior, valor_nuevo, motivo, actor_id)
  VALUES (p_tenant_id, p_ot_id, p_dominio, p_evento, p_entidad_tipo, p_entidad_id,
          p_anterior, p_nuevo, p_motivo, p_actor_id);
END; $$;

-- ── internal.avanzar_estado_ot — el ÚNICO camino para mover el estado ────────
-- El estado de la OT lo mueve el ACTO, no un botón aparte: registrar el primer
-- diagnóstico la saca de 'creada', cargar la cotización la lleva a
-- 'en_cotizacion', iniciar la pone 'en_trabajo'. Ese avance implícito es lo que
-- describe el Anexo A, y estaba sólo a medias: sp_ot_iniciar lo hacía y los SP
-- de diagnóstico y cotización no, así que toda OT se quedaba en 'creada' para
-- siempre y ni cotizar, ni ejecutar, ni cerrar eran alcanzables.
--
-- Se concentra aquí para que ningún SP vuelva a mover el estado a mano: valida
-- la transición contra el Anexo A, actualiza, deja historial y sella el evento
-- en la bitácora. Las cuatro cosas, o ninguna.
CREATE OR REPLACE FUNCTION internal.avanzar_estado_ot(
  p_tenant_id UUID, p_ot_id UUID, p_desde core.ot_estado, p_hacia core.ot_estado,
  p_user_id UUID, p_motivo TEXT DEFAULT NULL)
RETURNS VOID LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, internal, public AS $$
BEGIN
  IF p_desde = p_hacia THEN RETURN; END IF;

  PERFORM internal.validar_transicion_ot(p_ot_id, p_desde, p_hacia, p_motivo);

  UPDATE core.orden_trabajo
     SET estado = p_hacia, updated_by = p_user_id
   WHERE id = p_ot_id;

  INSERT INTO core.ot_estado_historial (
    tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id, motivo_texto)
  VALUES (p_tenant_id, p_ot_id, p_desde, p_hacia, p_user_id, p_motivo);

  PERFORM internal.registrar_evento_ot(
    p_tenant_id, p_ot_id, 'ot', 'estado_cambiado', p_user_id, 'orden_trabajo', p_ot_id,
    jsonb_build_object('estado', p_desde), jsonb_build_object('estado', p_hacia), p_motivo);
END; $$;

-- ── Configuración por tenant ─────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION internal.config(
  p_tenant_id UUID, p_clave TEXT, p_default JSONB DEFAULT NULL)
RETURNS JSONB LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  SELECT coalesce((SELECT valor FROM core.tenant_configuracion
                    WHERE tenant_id = p_tenant_id AND clave = p_clave), p_default);
$$;

-- ── Notificaciones ───────────────────────────────────────────────────────────
-- Se notifica cuando el receptor NECESITA ACTUAR, no por cada cambio menor
-- (cap. 19). El correo es una copia de la interna; su fallo no revierte nada.
CREATE OR REPLACE FUNCTION internal.notificar(
  p_tenant_id UUID, p_destinatario_id UUID, p_evento TEXT, p_titulo TEXT,
  p_cuerpo TEXT DEFAULT NULL, p_ot_id UUID DEFAULT NULL,
  p_entidad_tipo TEXT DEFAULT NULL, p_entidad_id UUID DEFAULT NULL)
RETURNS VOID LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, internal, public AS $$
BEGIN
  IF p_destinatario_id IS NULL THEN RETURN; END IF;
  INSERT INTO core.notificacion (tenant_id, destinatario_id, evento, titulo, cuerpo,
                                 ot_id, entidad_tipo, entidad_id, canal, estado)
  VALUES (p_tenant_id, p_destinatario_id, p_evento, p_titulo, p_cuerpo,
          p_ot_id, p_entidad_tipo, p_entidad_id, 'interno', 'pendiente');
END; $$;

-- Notifica a todos los coordinadores dentro del alcance de un área (cap. 19).
CREATE OR REPLACE FUNCTION internal.notificar_coordinadores(
  p_tenant_id UUID, p_area_id UUID, p_evento TEXT, p_titulo TEXT,
  p_cuerpo TEXT DEFAULT NULL, p_entidad_tipo TEXT DEFAULT NULL, p_entidad_id UUID DEFAULT NULL)
RETURNS VOID LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, internal, public AS $$
DECLARE r RECORD;
BEGIN
  FOR r IN
    SELECT DISTINCT u.id
      FROM core.usuario u
      JOIN core.usuario_rol ur ON ur.usuario_id = u.id
      JOIN core.rol rr         ON rr.id = ur.rol_id
     WHERE u.tenant_id = p_tenant_id AND u.estado = 'activo' AND u.deleted_at IS NULL
       AND rr.codigo = 'coordinador'
       AND (NOT EXISTS (SELECT 1 FROM core.usuario_alcance a WHERE a.usuario_id = u.id)
            OR EXISTS (SELECT 1 FROM core.usuario_alcance a
                        WHERE a.usuario_id = u.id
                          AND (a.area_id IS NULL OR a.area_id = p_area_id)))
  LOOP
    PERFORM internal.notificar(p_tenant_id, r.id, p_evento, p_titulo, p_cuerpo,
                               NULL, p_entidad_tipo, p_entidad_id);
  END LOOP;
END; $$;

-- ── Validaciones de dato ─────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION internal.validar_ruc(p_ruc TEXT)
RETURNS BOOLEAN LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE v TEXT := regexp_replace(coalesce(p_ruc,''), '\D', '', 'g');
        pesos INT[] := ARRAY[5,4,3,2,7,6,5,4,3,2]; s INT := 0; i INT; d INT;
BEGIN
  IF length(v) <> 11 THEN RETURN false; END IF;
  IF substr(v,1,2) NOT IN ('10','15','16','17','20') THEN RETURN false; END IF;
  FOR i IN 1..10 LOOP s := s + substr(v,i,1)::int * pesos[i]; END LOOP;
  d := 11 - (s % 11);
  IF d = 10 THEN d := 0; ELSIF d = 11 THEN d := 1; END IF;
  RETURN d = substr(v,11,1)::int;
END; $$;

-- ═════════════════════════════════════════════════════════════════════════════
-- internal.validar_transicion_ot — EL ANEXO A HECHO CÓDIGO
--
-- Dos capas: primero si el par (desde, hacia) es legal; después las condiciones
-- de datos que la propia base puede comprobar. Lo que depende del payload de la
-- llamada lo valida el SP que ejecuta el comando.
-- ═════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION internal.validar_transicion_ot(
  p_ot_id UUID, p_desde core.ot_estado, p_hacia core.ot_estado, p_motivo TEXT DEFAULT NULL)
RETURNS VOID LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, internal, public AS $$
DECLARE
  o            core.orden_trabajo%ROWTYPE;
  v_legal      BOOLEAN := false;
  v_hay_diag   BOOLEAN;
  v_hay_cotiz  BOOLEAN;
  v_hay_pausa  BOOLEAN;
  v_hijas      INT;
BEGIN
  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'La OT no existe' USING ERRCODE = 'MIP02';
  END IF;

  -- Cancelar es legal desde cualquier estado no terminal (Anexo A, fila "Varios").
  IF p_hacia = 'cancelada' THEN
    IF p_desde IN ('cerrada','cancelada') THEN
      RAISE EXCEPTION 'No se puede cancelar una OT % ', p_desde USING ERRCODE = 'MIP04';
    END IF;
    IF btrim(coalesce(p_motivo,'')) = '' THEN
      RAISE EXCEPTION 'La cancelación exige motivo' USING ERRCODE = 'MIP01';
    END IF;
    RETURN;
  END IF;

  v_legal := CASE
    WHEN p_desde = 'creada'            AND p_hacia = 'en_diagnostico'    THEN true
    WHEN p_desde = 'en_diagnostico'    AND p_hacia = 'en_cotizacion'     THEN true
    WHEN p_desde = 'en_cotizacion'     AND p_hacia = 'en_trabajo'        THEN true
    WHEN p_desde = 'en_diagnostico'    AND p_hacia = 'en_trabajo'        THEN true  -- sólo emergencia
    WHEN p_desde = 'en_trabajo'        AND p_hacia = 'trabajo_realizado' THEN true
    WHEN p_desde = 'trabajo_realizado' AND p_hacia = 'en_trabajo'        THEN true  -- corrección
    WHEN p_desde = 'trabajo_realizado' AND p_hacia = 'cerrada'           THEN true
    WHEN p_desde = 'en_cotizacion'     AND p_hacia = 'en_diagnostico'    THEN true  -- cambio de alcance
    WHEN p_desde = 'en_trabajo'        AND p_hacia = 'en_diagnostico'    THEN true  -- replanteamiento
    WHEN p_desde = 'cerrada'           AND p_hacia IN ('en_trabajo','en_diagnostico') THEN true  -- reapertura
    ELSE false END;

  IF NOT v_legal THEN
    RAISE EXCEPTION 'Transición no permitida: % -> % (Anexo A)', p_desde, p_hacia
      USING ERRCODE = 'MIP04';
  END IF;

  -- CREADA -> EN DIAGNOSTICO: contexto técnico completo. El activo NO es requisito
  -- del MVP (cap. 25.2), y eso es deliberado.
  IF p_desde = 'creada' AND p_hacia = 'en_diagnostico' THEN
    IF o.coordinador_id IS NULL OR o.sucursal_id IS NULL OR o.empresa_ruc_id IS NULL
       OR o.area_id IS NULL OR o.prioridad_tecnica IS NULL OR o.tipo_mantenimiento_id IS NULL THEN
      RAISE EXCEPTION 'Para pasar a diagnóstico faltan: coordinador, sucursal, empresa/RUC, área, prioridad técnica o tipo de mantenimiento'
        USING ERRCODE = 'MIP01';
    END IF;
  END IF;

  -- EN DIAGNOSTICO -> EN COTIZACION: los cuatro campos técnicos obligatorios (QA-07).
  IF p_hacia = 'en_cotizacion' THEN
    SELECT EXISTS (SELECT 1 FROM core.diagnostico d WHERE d.ot_id = p_ot_id AND d.vigente)
      INTO v_hay_diag;
    IF NOT v_hay_diag THEN
      RAISE EXCEPTION 'No se puede pasar a cotización sin un diagnóstico vigente completo'
        USING ERRCODE = 'MIP04';
    END IF;
  END IF;

  -- Entrar a EN TRABAJO.
  IF p_hacia = 'en_trabajo' AND p_desde IN ('en_cotizacion','en_diagnostico') THEN
    IF o.ejecutor_id IS NULL THEN
      RAISE EXCEPTION 'El inicio exige un responsable de ejecución' USING ERRCODE = 'MIP01';
    END IF;
    IF p_desde = 'en_diagnostico' AND NOT o.es_emergencia THEN
      -- Saltarse la cotización sólo es legal en emergencia (Anexo A, QA-11).
      RAISE EXCEPTION 'Sólo una OT de emergencia puede iniciar trabajo sin pasar por cotización'
        USING ERRCODE = 'MIP04';
    END IF;
    IF p_desde = 'en_cotizacion' THEN
      SELECT EXISTS (SELECT 1 FROM core.cotizacion c
                      WHERE c.ot_id = p_ot_id AND c.vigente AND NOT c.invalidada)
        INTO v_hay_cotiz;
      IF NOT v_hay_cotiz THEN
        RAISE EXCEPTION 'El inicio normal exige una cotización vigente' USING ERRCODE = 'MIP04';
      END IF;
    END IF;
  END IF;

  -- EN TRABAJO -> TRABAJO REALIZADO: no con una pausa vigente sin resolver (cap. 29.3, QA-13).
  IF p_hacia = 'trabajo_realizado' THEN
    SELECT EXISTS (SELECT 1 FROM core.ot_pausa WHERE ot_id = p_ot_id AND fecha_reanudacion IS NULL)
      INTO v_hay_pausa;
    IF v_hay_pausa THEN
      RAISE EXCEPTION 'No se puede declarar trabajo realizado con una pausa vigente; reanude primero'
        USING ERRCODE = 'MIP04';
    END IF;
  END IF;

  -- TRABAJO REALIZADO -> CERRADA: revisión aprobada y derivadas bloqueantes resueltas.
  -- El seguimiento administrativo NO bloquea (cap. 14.3): eso lo maneja el SP de
  -- cierre exigiendo confirmación y observación.
  IF p_hacia = 'cerrada' THEN
    IF NOT EXISTS (SELECT 1 FROM core.trabajo_realizado t
                    WHERE t.ot_id = p_ot_id AND t.vigente
                      AND t.resultado_revision = 'aprobado') THEN
      RAISE EXCEPTION 'El cierre exige un trabajo realizado revisado y aprobado' USING ERRCODE = 'MIP04';
    END IF;

    SELECT count(*) INTO v_hijas
      FROM core.orden_trabajo h
     WHERE h.ot_padre_id = p_ot_id
       AND h.deleted_at IS NULL
       AND h.es_bloqueante_para_padre = true
       AND h.estado NOT IN ('cerrada','cancelada');
    IF v_hijas > 0 THEN
      -- Cap. 10: la OT superior no cierra si tiene derivadas activas, salvo que se
      -- marquen no bloqueantes conforme a regla y permiso configurados (QA-16).
      RAISE EXCEPTION 'La OT tiene % derivada(s) bloqueante(s) sin resolver', v_hijas
        USING ERRCODE = 'MIP04';
    END IF;
  END IF;

  -- Salir de CERRADA es reapertura: siempre con motivo (cap. 14.4, QA-22).
  IF p_desde = 'cerrada' THEN
    IF btrim(coalesce(p_motivo,'')) = '' THEN
      RAISE EXCEPTION 'La reapertura exige motivo obligatorio' USING ERRCODE = 'MIP01';
    END IF;
  END IF;

  -- Volver atrás por cambio de alcance o replanteamiento exige motivo (Anexo A).
  IF p_hacia = 'en_diagnostico' AND p_desde IN ('en_cotizacion','en_trabajo') THEN
    IF btrim(coalesce(p_motivo,'')) = '' THEN
      RAISE EXCEPTION 'Regresar a diagnóstico exige registrar el motivo' USING ERRCODE = 'MIP01';
    END IF;
  END IF;
END; $$;

-- ── Paginación ───────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION internal.meta_paginacion(p_total INT, p_page INT, p_size INT)
RETURNS JSONB LANGUAGE sql IMMUTABLE AS $$
  SELECT jsonb_build_object(
    'total', p_total, 'page', greatest(p_page,1), 'page_size', p_size,
    'pages', CASE WHEN p_total = 0 THEN 0 ELSE ceil(p_total::numeric / p_size)::int END);
$$;

-- Búsqueda insensible a tildes y mayúsculas, como en el proyecto hermano.
CREATE OR REPLACE FUNCTION internal.normalizar_busqueda(p_texto TEXT)
RETURNS TEXT LANGUAGE sql IMMUTABLE AS $$
  SELECT lower(unaccent(coalesce(p_texto,'')));
$$;
