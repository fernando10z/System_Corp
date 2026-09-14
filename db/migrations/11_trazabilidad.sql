-- =============================================================================
-- 07_trazabilidad.sql
--
--          EL MOTOR DE TRAZABILIDAD DE LA ORDEN DE TRABAJO
--
-- Requisito estructural del proyecto: la OT es la tabla principal y su última
-- columna guarda el árbol completo de TODO lo que esa OT generó.
--
-- Cómo se sostiene, y por qué así:
--
--  1. internal.fn_ot_trazabilidad() es LA AUTORIDAD. Arma el árbol on-demand
--     leyendo las tablas reales, que siguen siendo la fuente de verdad. El JSON
--     es una proyección, nunca el original — así no puede divergir de forma
--     irrecuperable, y siempre se puede reconstruir desde cero.
--
--  2. Los triggers de las tablas hijas hacen UNA sola cosa barata: marcar
--     `trazabilidad_dirty = true` en la OT afectada y en sus ancestros. NO
--     reconstruyen el árbol. Reconstruirlo entero al insertar un mensaje de chat
--     sería amplificación de escritura pura y una fuente de deadlocks.
--     Marcar la bandera garantiza que ningún cambio se pierda jamás, ni siquiera
--     un UPDATE manual hecho por psql fuera de los stored procedures.
--
--  3. app.sp_ot_trazabilidad_refrescar() recalcula y guarda. Lo llaman los SP de
--     negocio al terminar, y el camino de lectura de forma perezosa si encuentra
--     la bandera levantada. En la práctica la columna está siempre fresca.
--
-- El resultado: lecturas instantáneas, escrituras baratas y un árbol que no puede
-- mentir.
-- =============================================================================
SET search_path = core, internal, app, public;

-- ═════════════════════════════════════════════════════════════════════════════
-- PARTE 1 · Marcado perezoso (dirty flag)
-- ═════════════════════════════════════════════════════════════════════════════

-- Marca la OT y TODOS sus ancestros. Una derivada que cambia ensucia también el
-- árbol de su padre, porque el padre la lleva anidada.
CREATE OR REPLACE FUNCTION internal.marcar_ot_dirty(p_ot_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, internal, public AS $$
BEGIN
  IF p_ot_id IS NULL THEN RETURN; END IF;

  -- La guarda de OT cerrada no debe impedir marcar la bandera: mantener el árbol
  -- al día no es "modificar" la OT en el sentido del cap. 21.3.
  PERFORM set_config('mip.permitir_update_cerrada', 'on', true);

  WITH RECURSIVE ancestros AS (
    SELECT id, ot_padre_id, 0 AS salto
      FROM core.orden_trabajo
     WHERE id = p_ot_id
    UNION ALL
    SELECT ot.id, ot.ot_padre_id, a.salto + 1
      FROM core.orden_trabajo ot
      JOIN ancestros a ON ot.id = a.ot_padre_id
     WHERE a.salto < 100          -- cinturón de seguridad ante datos corruptos
  )
  UPDATE core.orden_trabajo o
     SET trazabilidad_dirty = true
    FROM ancestros a
   WHERE o.id = a.id
     AND o.trazabilidad_dirty = false;

  PERFORM set_config('mip.permitir_update_cerrada', 'off', true);
END; $$;

-- Marca las HIJAS DIRECTAS. Hace falta porque el árbol de una derivada embebe un
-- resumen de su padre (origen.ot_padre: estado, número, motivo de derivación).
-- Cuando el padre cambia de estado, el snapshot de cada hija queda obsoleto, y la
-- propagación hacia arriba no lo cubre: hay que bajar un nivel.
--
-- Sólo un nivel: la nieta embebe a SU padre, no al abuelo. Y el marcado es
-- idempotente (sólo escribe si dirty era false), así que la cascada se detiene
-- sola en lugar de rebotar entre padre e hija.
CREATE OR REPLACE FUNCTION internal.marcar_ot_dirty_hijas(p_ot_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, internal, public AS $$
BEGIN
  IF p_ot_id IS NULL THEN RETURN; END IF;
  PERFORM set_config('mip.permitir_update_cerrada', 'on', true);
  UPDATE core.orden_trabajo
     SET trazabilidad_dirty = true
   WHERE ot_padre_id = p_ot_id AND trazabilidad_dirty = false;
  PERFORM set_config('mip.permitir_update_cerrada', 'off', true);
END; $$;

-- Trigger genérico para las hijas que llevan ot_id directo.
CREATE OR REPLACE FUNCTION core.trg_dirty_por_ot_id() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
  PERFORM internal.marcar_ot_dirty(coalesce(NEW.ot_id, OLD.ot_id));
  RETURN coalesce(NEW, OLD);
END; $$;

-- La conversación y sus mensajes llegan a la OT por conversacion_id.
CREATE OR REPLACE FUNCTION core.trg_dirty_por_conversacion() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE v_ot UUID;
BEGIN
  SELECT ot_id INTO v_ot FROM core.conversacion
   WHERE id = coalesce(NEW.conversacion_id, OLD.conversacion_id);
  PERFORM internal.marcar_ot_dirty(v_ot);
  RETURN coalesce(NEW, OLD);
END; $$;

-- La solicitud es el origen del árbol: si se edita, la OT que nació de ella queda sucia.
CREATE OR REPLACE FUNCTION core.trg_dirty_por_solicitud() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE v_ot UUID;
BEGIN
  SELECT id INTO v_ot FROM core.orden_trabajo
   WHERE solicitud_origen_id = coalesce(NEW.id, OLD.id);
  PERFORM internal.marcar_ot_dirty(v_ot);
  RETURN coalesce(NEW, OLD);
END; $$;

CREATE OR REPLACE FUNCTION core.trg_dirty_por_solicitud_hija() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE v_ot UUID;
BEGIN
  SELECT id INTO v_ot FROM core.orden_trabajo
   WHERE solicitud_origen_id = coalesce(NEW.solicitud_id, OLD.solicitud_id);
  PERFORM internal.marcar_ot_dirty(v_ot);
  RETURN coalesce(NEW, OLD);
END; $$;

-- La propia OT: cualquier cambio de negocio ensucia su árbol y el de sus ancestros.
-- Se excluyen las columnas del propio snapshot para no entrar en bucle.
CREATE OR REPLACE FUNCTION core.trg_dirty_ot_self() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
  -- Si lo único que cambió fueron las columnas del propio snapshot, no hay nada
  -- de negocio que reflejar: se sale sin marcar nada. Sin esto, cada refresco
  -- volvería a ensuciar la fila que acaba de limpiar.
  IF TG_OP = 'UPDATE' THEN
    IF (to_jsonb(NEW) - 'trazabilidad' - 'trazabilidad_dirty'
                      - 'trazabilidad_version' - 'trazabilidad_at' - 'updated_at')
       IS NOT DISTINCT FROM
       (to_jsonb(OLD) - 'trazabilidad' - 'trazabilidad_dirty'
                      - 'trazabilidad_version' - 'trazabilidad_at' - 'updated_at')
    THEN
      RETURN NEW;
    END IF;
  END IF;

  PERFORM internal.marcar_ot_dirty(NEW.id);        -- esta OT y toda su cadena de ancestros
  PERFORM internal.marcar_ot_dirty_hijas(NEW.id);  -- las hijas, que embeben el resumen del padre

  -- Al reasignar el padre, el árbol del padre ANTERIOR también deja de ser válido.
  IF TG_OP = 'UPDATE' AND OLD.ot_padre_id IS DISTINCT FROM NEW.ot_padre_id THEN
    PERFORM internal.marcar_ot_dirty(OLD.ot_padre_id);
  END IF;

  RETURN NEW;
END; $$;

-- Enganchar los triggers. Se hace en bucle para que agregar una tabla hija en el
-- futuro sea añadir una línea al array, no copiar diez líneas de DDL.
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'ot_estado_historial','diagnostico','cotizacion','ejecucion','ot_avance',
    'ot_incidencia','ot_pausa','trabajo_realizado','ot_cierre','ot_reapertura',
    'seguimiento_administrativo','solped','orden_compra','liberacion_historial',
    'conversacion','adjunto','costo_unitario','ot_evento','notificacion'
  ] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_dirty ON core.%I;', t, t);
    EXECUTE format('CREATE TRIGGER trg_%I_dirty AFTER INSERT OR UPDATE OR DELETE ON core.%I
                    FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();', t, t);
  END LOOP;

  FOREACH t IN ARRAY ARRAY['conversacion_participante','mensaje'] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_dirty ON core.%I;', t, t);
    EXECUTE format('CREATE TRIGGER trg_%I_dirty AFTER INSERT OR UPDATE OR DELETE ON core.%I
                    FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_conversacion();', t, t);
  END LOOP;
END $$;

DROP TRIGGER IF EXISTS trg_solicitud_trabajo_dirty ON core.solicitud_trabajo;
CREATE TRIGGER trg_solicitud_trabajo_dirty
  AFTER INSERT OR UPDATE OR DELETE ON core.solicitud_trabajo
  FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_solicitud();

DROP TRIGGER IF EXISTS trg_solicitud_decision_dirty ON core.solicitud_decision;
CREATE TRIGGER trg_solicitud_decision_dirty
  AFTER INSERT OR UPDATE OR DELETE ON core.solicitud_decision
  FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_solicitud_hija();

DROP TRIGGER IF EXISTS trg_ot_dirty_self ON core.orden_trabajo;
CREATE TRIGGER trg_ot_dirty_self
  AFTER INSERT OR UPDATE ON core.orden_trabajo
  FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_ot_self();

-- ═════════════════════════════════════════════════════════════════════════════
-- PARTE 2 · El constructor del árbol
--
-- Un bloque por sección del JSON. Cada uno es una función pequeña y probable por
-- separado; fn_ot_trazabilidad las compone. Todas devuelven '[]' o '{}' en vez de
-- NULL para que el consumidor nunca tenga que defenderse de nulos.
-- ═════════════════════════════════════════════════════════════════════════════

-- NOTA sobre el ORDEN dentro de los arrays de este archivo:
-- created_at se llena con now(), que devuelve el instante de INICIO DE LA
-- TRANSACCIÓN. Todas las filas escritas por un mismo stored procedure comparten
-- ese valor, así que un ORDER BY created_at a secas no es determinista. Cada
-- ordenación lleva un desempate estable (id, versión, secuencia o número), o el
-- árbol saldría en orden distinto en cada llamada y el snapshot cacheado nunca
-- podría compararse con la función autoritativa.

-- ── Origen: la solicitud que dio pie a la OT y las decisiones sobre ella ─────
CREATE OR REPLACE FUNCTION internal.fn_ot_origen(p_ot_id UUID)
RETURNS JSONB
LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  SELECT jsonb_build_object(
    'solicitud',
      CASE WHEN s.id IS NULL THEN NULL ELSE jsonb_build_object(
        'id',                  s.id,
        'numero',              s.numero,
        'estado',              s.estado,
        'titulo',              s.titulo,
        -- El reporte original se conserva literalmente y no lo altera la OT (cap. 7.2, 24.1).
        'descripcion_original', s.descripcion,
        'lugar',               s.lugar,
        'impacto',             ci.nombre,
        'impacto_comentario',  s.impacto_comentario,
        'prioridad_percibida', s.prioridad_percibida,
        'solicitante',         jsonb_build_object('id', u.id, 'nombre', u.nombres || ' ' || u.apellidos),
        'fecha_envio',         s.fecha_envio,
        'fecha_primera_revision', s.fecha_primera_revision
      ) END,
    'decisiones', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'tipo',            d.tipo,
               'estado_anterior', d.estado_anterior,
               'estado_nuevo',    d.estado_nuevo,
               'motivo',          cm.nombre,
               'comentario',      d.comentario,
               'actor',           du.nombres || ' ' || du.apellidos,
               'fecha',           d.created_at
             ) ORDER BY d.created_at, d.id)
        FROM core.solicitud_decision d
        LEFT JOIN core.usuario du      ON du.id = d.actor_id
        LEFT JOIN core.catalogo_item cm ON cm.id = d.motivo_id
       WHERE d.solicitud_id = s.id), '[]'::jsonb),
    'ot_padre',
      CASE WHEN p.id IS NULL THEN NULL ELSE jsonb_build_object(
        'id',      p.id,
        'numero',  p.numero_ot,
        'estado',  p.estado,
        'motivo_derivacion', coalesce(cd.nombre, o.motivo_derivacion_texto),
        'es_bloqueante',     o.es_bloqueante_para_padre,
        'independizada',     o.independizada_de_padre
      ) END
  )
  FROM core.orden_trabajo o
  LEFT JOIN core.solicitud_trabajo s ON s.id = o.solicitud_origen_id
  LEFT JOIN core.usuario u           ON u.id = s.solicitante_id
  LEFT JOIN core.catalogo_item ci    ON ci.id = s.impacto_operativo_id
  LEFT JOIN core.orden_trabajo p     ON p.id = o.ot_padre_id
  LEFT JOIN core.catalogo_item cd    ON cd.id = o.motivo_derivacion_id
  WHERE o.id = p_ot_id;
$$;

-- ── Adjuntos de cualquier entidad ────────────────────────────────────────────
-- Un archivo nunca queda sin contexto: siempre lleva entidad, etapa y autor (regla 23.1).
CREATE OR REPLACE FUNCTION internal.fn_adjuntos_de(p_entidad_tipo TEXT, p_entidad_id UUID)
RETURNS JSONB
LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id',       a.id,
           'nombre',   a.nombre,
           'tipo',     a.tipo,
           'etapa',    a.etapa,
           'mime',     a.mime_type,
           'tamano',   a.tamano_bytes,
           'estado',   a.estado,
           'autor',    u.nombres || ' ' || u.apellidos,
           'fecha',    a.created_at
         ) ORDER BY a.created_at, a.id), '[]'::jsonb)
  FROM core.adjunto a
  LEFT JOIN core.usuario u ON u.id = a.autor_id
  WHERE a.entidad_tipo = p_entidad_tipo AND a.entidad_id = p_entidad_id;
$$;

-- ── Diagnósticos versionados ─────────────────────────────────────────────────
-- Se devuelven TODOS, con la vigente marcada: un cambio no borra la historia
-- (cap. 9, 26.2). Así el árbol permite distinguir el diagnóstico inicial del
-- vigente, que es un criterio de aceptación explícito (cap. 26.3).
CREATE OR REPLACE FUNCTION internal.fn_ot_diagnosticos(p_ot_id UUID)
RETURNS JSONB
LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id',                 d.id,
           'version',            d.version,
           'vigente',            d.vigente,
           'diagnostico',        d.diagnostico,
           'causa_probable',     d.causa_probable,
           'alcance',            d.alcance,
           'trabajo_a_realizar', d.trabajo_a_realizar,
           'observaciones',      d.observaciones,
           'lecturas_instrumentos', d.lecturas_instrumentos,
           'autor',              a.nombres || ' ' || a.apellidos,
           'aprobado_por',       ap.nombres || ' ' || ap.apellidos,
           'aprobado_at',        d.aprobado_at,
           'motivo_cambio',      d.motivo_cambio,
           'reemplaza_a',        d.reemplaza_a,
           'fecha',              d.created_at,
           'adjuntos',           internal.fn_adjuntos_de('diagnostico', d.id)
         ) ORDER BY d.version), '[]'::jsonb)
  FROM core.diagnostico d
  LEFT JOIN core.usuario a  ON a.id = d.autor_id
  LEFT JOIN core.usuario ap ON ap.id = d.aprobado_por
  WHERE d.ot_id = p_ot_id;
$$;

-- ── Cotizaciones versionadas ─────────────────────────────────────────────────
-- Reemplazar no borra: la versión anterior conserva PDF, metadatos, usuario,
-- fecha y motivo (cap. 28.2, QA-09).
CREATE OR REPLACE FUNCTION internal.fn_ot_cotizaciones(p_ot_id UUID)
RETURNS JSONB
LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id',               c.id,
           'version',          c.version,
           'vigente',          c.vigente AND NOT c.invalidada,
           'invalidada',       c.invalidada,
           'proveedor',        coalesce(p.razon_social, c.proveedor_nombre),
           'proveedor_ruc',    coalesce(p.ruc, c.proveedor_ruc),
           'numero',           c.numero_cotizacion,
           'fecha',            c.fecha_cotizacion,
           'monto',            c.monto,
           'moneda',           c.moneda,
           'plazo_ofrecido_dias', c.plazo_ofrecido_dias,
           'observaciones',    c.observaciones,
           'motivo_reemplazo', c.motivo_reemplazo,
           'reemplaza_a',      c.reemplaza_a,
           'cargada_por',      u.nombres || ' ' || u.apellidos,
           'cargada_at',       c.created_at,
           'adjuntos',         internal.fn_adjuntos_de('cotizacion', c.id)
         ) ORDER BY c.version), '[]'::jsonb)
  FROM core.cotizacion c
  LEFT JOIN core.proveedor p ON p.id = c.proveedor_id
  LEFT JOIN core.usuario u   ON u.id = c.cargada_por
  WHERE c.ot_id = p_ot_id;
$$;

-- ── Ejecución: avances, incidencias y pausas ─────────────────────────────────
CREATE OR REPLACE FUNCTION internal.fn_ot_ejecucion(p_ot_id UUID)
RETURNS JSONB
LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  SELECT jsonb_build_object(
    'inicio_real',   e.inicio_real,
    'termino_real',  e.termino_real,
    'responsable',   r.nombres || ' ' || r.apellidos,
    'confirmado_por', cf.nombres || ' ' || cf.apellidos,
    'inicio_sin_cotizacion', coalesce(e.inicio_sin_cotizacion, false),
    'observaciones', e.observaciones,
    -- Duración en días calendario (cap. 12.3, 35.2). Las pausas se reportan
    -- aparte: el MVP no exige calcular tiempo efectivo.
    'duracion_dias', CASE WHEN e.inicio_real IS NOT NULL AND e.termino_real IS NOT NULL
                          THEN round(extract(epoch FROM (e.termino_real - e.inicio_real)) / 86400.0, 2)
                          END,
    'avances', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', av.id, 'descripcion', av.descripcion, 'porcentaje', av.porcentaje,
               'autor', au.nombres || ' ' || au.apellidos, 'fecha', av.created_at,
               'adjuntos', internal.fn_adjuntos_de('ot_avance', av.id)
             ) ORDER BY av.created_at, av.id)
        FROM core.ot_avance av LEFT JOIN core.usuario au ON au.id = av.autor_id
       WHERE av.ot_id = p_ot_id), '[]'::jsonb),
    'incidencias', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', i.id, 'tipo', ct.nombre, 'descripcion', i.descripcion,
               'resuelta', i.resuelta, 'resuelta_at', i.resuelta_at, 'resolucion', i.resolucion,
               'autor', iu.nombres || ' ' || iu.apellidos, 'fecha', i.created_at,
               'adjuntos', internal.fn_adjuntos_de('ot_incidencia', i.id)
             ) ORDER BY i.created_at, i.id)
        FROM core.ot_incidencia i
        LEFT JOIN core.usuario iu       ON iu.id = i.autor_id
        LEFT JOIN core.catalogo_item ct ON ct.id = i.tipo_id
       WHERE i.ot_id = p_ot_id), '[]'::jsonb),
    'pausas', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', pa.id, 'motivo', coalesce(cp.nombre, pa.motivo_texto),
               'motivo_texto', pa.motivo_texto,
               'fecha_pausa', pa.fecha_pausa, 'fecha_reanudacion', pa.fecha_reanudacion,
               'abierta', pa.fecha_reanudacion IS NULL,
               'horas', CASE WHEN pa.fecha_reanudacion IS NOT NULL
                             THEN round(extract(epoch FROM (pa.fecha_reanudacion - pa.fecha_pausa)) / 3600.0, 2)
                             END,
               'pausada_por', pu.nombres || ' ' || pu.apellidos,
               'reanudada_por', ru.nombres || ' ' || ru.apellidos,
               'observacion_reanudacion', pa.observacion_reanudacion
             ) ORDER BY pa.fecha_pausa, pa.id)
        FROM core.ot_pausa pa
        LEFT JOIN core.usuario pu       ON pu.id = pa.pausada_por
        LEFT JOIN core.usuario ru       ON ru.id = pa.reanudada_por
        LEFT JOIN core.catalogo_item cp ON cp.id = pa.motivo_id
       WHERE pa.ot_id = p_ot_id), '[]'::jsonb)
  )
  FROM core.orden_trabajo o
  LEFT JOIN core.ejecucion e ON e.ot_id = o.id
  LEFT JOIN core.usuario r   ON r.id = e.responsable_id
  LEFT JOIN core.usuario cf  ON cf.id = e.confirmado_por
  WHERE o.id = p_ot_id;
$$;

-- ── Trabajo realizado, cierres y reaperturas ─────────────────────────────────
-- Los cierres son filas, no columnas: el cierre anterior nunca se elimina (cap. 14.4).
CREATE OR REPLACE FUNCTION internal.fn_ot_cierre(p_ot_id UUID)
RETURNS JSONB
LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  SELECT jsonb_build_object(
    'trabajo_realizado', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', t.id, 'version', t.version, 'vigente', t.vigente,
               'descripcion', t.descripcion,
               'resultado', coalesce(cr.nombre, t.resultado_texto),
               'fecha_termino', t.fecha_termino,
               'observaciones', t.observaciones,
               'declarado_por', dp.nombres || ' ' || dp.apellidos,
               'revision', jsonb_build_object(
                 'resultado',   t.resultado_revision,
                 'observacion', t.revision_observacion,
                 'revisor',     rv.nombres || ' ' || rv.apellidos,
                 'fecha',       t.revisado_at),
               'conformidad_solicitante', jsonb_build_object(
                 'estado',     t.conformidad,
                 'comentario', t.conformidad_comentario,
                 'fecha',      t.conformidad_at),
               'adjuntos', internal.fn_adjuntos_de('trabajo_realizado', t.id)
             ) ORDER BY t.version)
        FROM core.trabajo_realizado t
        LEFT JOIN core.usuario dp       ON dp.id = t.declarado_por
        LEFT JOIN core.usuario rv       ON rv.id = t.revisado_por
        LEFT JOIN core.catalogo_item cr ON cr.id = t.resultado_id
       WHERE t.ot_id = p_ot_id), '[]'::jsonb),
    'cierres', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', c.id, 'secuencia', c.secuencia, 'vigente', c.vigente,
               'fecha', c.fecha_cierre,
               'cerrado_por', cu.nombres || ' ' || cu.apellidos,
               'admin_revisado', c.admin_revisado,
               'estado_admin_al_cierre', c.estado_admin_al_cierre,
               -- Cierre con pendiente administrativo: observación obligatoria (cap. 31.2, QA-19)
               'observacion_pendiente', c.observacion_pendiente,
               'derivadas_bloqueantes_resueltas', c.derivadas_bloqueantes_resueltas
             ) ORDER BY c.secuencia)
        FROM core.ot_cierre c LEFT JOIN core.usuario cu ON cu.id = c.cerrado_por
       WHERE c.ot_id = p_ot_id), '[]'::jsonb),
    'reaperturas', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', r.id, 'fecha', r.created_at,
               'motivo', coalesce(cm.nombre, r.motivo_texto),
               'motivo_texto', r.motivo_texto,
               'estado_retorno', r.estado_retorno,
               'reabierta_por', ru.nombres || ' ' || ru.apellidos,
               'cierre_revertido', r.cierre_id
             ) ORDER BY r.created_at, r.id)
        FROM core.ot_reapertura r
        LEFT JOIN core.usuario ru       ON ru.id = r.reabierta_por
        LEFT JOIN core.catalogo_item cm ON cm.id = r.motivo_id
       WHERE r.ot_id = p_ot_id), '[]'::jsonb)
  );
$$;

-- ── Seguimiento administrativo: SOLPED, OC y liberación ──────────────────────
-- Dimensión paralela al estado operativo. Puede quedar pendiente sin bloquear el
-- cierre técnico (cap. 15, 31).
CREATE OR REPLACE FUNCTION internal.fn_ot_administrativo(p_ot_id UUID)
RETURNS JSONB
LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  SELECT jsonb_build_object(
    'estado_consolidado', coalesce(sa.estado_consolidado, o.estado_administrativo),
    'monto_liberado_total', coalesce(sa.monto_liberado_total, 0),
    'moneda',             coalesce(sa.moneda, 'PEN'),
    'revisado_por',       rv.nombres || ' ' || rv.apellidos,
    'revisado_at',        sa.revisado_at,
    'observacion',        sa.observacion,
    'solped', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', s.id, 'version', s.version, 'vigente', s.vigente AND NOT s.anulada,
               'numero_interno', s.numero_interno,
               -- Referencia no editable sin flujo auditado (cap. 22.2)
               'numero_sap',     s.numero_sap,
               'referencia_externa', s.referencia_externa,
               'estado_integracion', s.estado_integracion,
               'formulario',     s.formulario,
               'monto', s.monto, 'moneda', s.moneda, 'fecha', s.fecha_solped,
               'cotizacion_id',  s.cotizacion_id,
               'mensaje_sap',    s.mensaje_sap, 'intentos', s.intentos,
               -- Anulación LÓGICA: el registro permanece con motivo (cap. 15.1, QA-30)
               'anulada', s.anulada, 'motivo_anulacion', s.motivo_anulacion,
               'reemplaza_a', s.reemplaza_a,
               'creada_at', s.created_at
             ) ORDER BY s.version)
        FROM core.solped s WHERE s.ot_id = p_ot_id), '[]'::jsonb),
    'oc', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', oc.id, 'numero', oc.numero_oc, 'fecha', oc.fecha_oc,
               'monto', oc.monto, 'moneda', oc.moneda,
               'observacion', oc.observacion, 'anulada', oc.anulada,
               'solped_id', oc.solped_id,
               'registrada_por', ou.nombres || ' ' || ou.apellidos,
               'registrada_at', oc.created_at
             ) ORDER BY oc.created_at, oc.id)
        FROM core.orden_compra oc LEFT JOIN core.usuario ou ON ou.id = oc.registrada_por
       WHERE oc.ot_id = p_ot_id), '[]'::jsonb),
    'liberaciones', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', l.id,
               'estado_anterior', l.estado_anterior, 'estado_nuevo', l.estado_nuevo,
               -- Cada cambio guarda valor anterior y nuevo (cap. 31.3, QA-21)
               'monto_anterior', l.monto_anterior, 'monto_nuevo', l.monto_nuevo,
               'moneda', l.moneda, 'observacion', l.observacion,
               'actor', lu.nombres || ' ' || lu.apellidos, 'fecha', l.created_at,
               'secuencia', l.secuencia
             ) ORDER BY l.secuencia)
        FROM core.liberacion_historial l LEFT JOIN core.usuario lu ON lu.id = l.actor_id
       WHERE l.ot_id = p_ot_id), '[]'::jsonb)
  )
  FROM core.orden_trabajo o
  LEFT JOIN core.seguimiento_administrativo sa ON sa.ot_id = o.id
  LEFT JOIN core.usuario rv ON rv.id = sa.revisado_por
  WHERE o.id = p_ot_id;
$$;

-- ── Conversación ─────────────────────────────────────────────────────────────
-- Mensajes humanos y eventos de sistema comparten línea de tiempo pero se
-- distinguen por tipo (cap. 13, 30.1). Los retirados conservan el rastro de que
-- existieron, sin su contenido.
CREATE OR REPLACE FUNCTION internal.fn_ot_conversacion(p_ot_id UUID)
RETURNS JSONB
LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  SELECT jsonb_build_object(
    'id',           c.id,
    'solo_lectura', coalesce(c.solo_lectura, false),
    'participantes', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'usuario_id', pu.id,
               'nombre', pu.nombres || ' ' || pu.apellidos,
               'puede_escribir', pp.puede_escribir,
               've_notas_internas', pp.ve_notas_internas,
               'activo', pp.activo
             ) ORDER BY pp.created_at, pp.usuario_id)
        FROM core.conversacion_participante pp
        JOIN core.usuario pu ON pu.id = pp.usuario_id
       WHERE pp.conversacion_id = c.id), '[]'::jsonb),
    'mensajes', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', m.id, 'tipo', m.tipo, 'visibilidad', m.visibilidad, 'estado', m.estado,
               'cuerpo', CASE WHEN m.estado = 'retirado' THEN NULL ELSE m.cuerpo END,
               'responde_a', m.responde_a,
               'autor', mu.nombres || ' ' || mu.apellidos,
               'editado', m.editado_at IS NOT NULL,
               'retirado', m.estado = 'retirado',
               'fecha', m.created_at,
               'adjuntos', internal.fn_adjuntos_de('mensaje', m.id)
             ) ORDER BY m.created_at, m.id)
        FROM core.mensaje m LEFT JOIN core.usuario mu ON mu.id = m.autor_id
       WHERE m.conversacion_id = c.id), '[]'::jsonb)
  )
  FROM core.conversacion c WHERE c.ot_id = p_ot_id;
$$;

-- ── Costos ───────────────────────────────────────────────────────────────────
-- Regla de calidad del cap. 16.4 y 32.4: hay que DIFERENCIAR costo cotizado,
-- liberado y contable. Nunca se mezclan sin etiqueta, y el árbol no presenta un
-- monto como final si sólo hay una cotización.
CREATE OR REPLACE FUNCTION internal.fn_ot_costos(p_ot_id UUID)
RETURNS JSONB
LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  SELECT jsonb_build_object(
    'cotizado', (SELECT jsonb_build_object('monto', c.monto, 'moneda', c.moneda,
                                           'fuente', 'cotizacion_vigente')
                   FROM core.cotizacion c
                  WHERE c.ot_id = p_ot_id AND c.vigente AND NOT c.invalidada LIMIT 1),
    'liberado', (SELECT jsonb_build_object('monto', sa.monto_liberado_total, 'moneda', sa.moneda,
                                           'fuente', 'liberacion_manual')
                   FROM core.seguimiento_administrativo sa WHERE sa.ot_id = p_ot_id),
    -- No hay integración contable definida (cap. 22.4): declararlo explícitamente
    -- evita que alguien lea el liberado como si fuera el costo final.
    'contable', NULL,
    'registros', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', cu.id, 'fuente', cu.fuente,
               'texto_original', cu.texto_original,
               'descripcion_normalizada', dn.etiqueta,
               'tipo_trabajo', tt.nombre, 'concepto', cu.concepto,
               'cantidad', cu.cantidad, 'unidad', cu.unidad,
               'monto_total', cu.monto_total, 'costo_unitario', cu.costo_unitario,
               'moneda', cu.moneda, 'fecha_referencia', cu.fecha_referencia,
               'proveedor', pr.razon_social,
               'calidad', jsonb_build_object(
                 'estado_validacion', cu.estado_validacion,
                 'confianza',   cu.confianza,
                 'es_outlier',  cu.es_outlier,
                 'justificacion_outlier', cu.outlier_justificacion,
                 'es_comparable', cu.es_comparable)
             ) ORDER BY cu.created_at, cu.id)
        FROM core.costo_unitario cu
        LEFT JOIN core.descripcion_normalizada dn ON dn.id = cu.descripcion_normalizada_id
        LEFT JOIN core.tipo_trabajo tt            ON tt.id = cu.tipo_trabajo_id
        LEFT JOIN core.proveedor pr               ON pr.id = cu.proveedor_id
       WHERE cu.ot_id = p_ot_id), '[]'::jsonb)
  );
$$;

-- ── Eventos: la bitácora append-only ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION internal.fn_ot_eventos(p_ot_id UUID, p_limite INT DEFAULT 500)
RETURNS JSONB
LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  -- Se ordena por (fecha, id): dentro de una misma transacción now() es idéntico
  -- para todos los eventos, y sin el id la línea de tiempo saldría desordenada.
  SELECT coalesce(jsonb_agg(e ORDER BY (e->>'fecha'), (e->>'id')::bigint), '[]'::jsonb)
  FROM (
    SELECT jsonb_build_object(
             'id', ev.id, 'dominio', ev.dominio, 'evento', ev.evento,
             'entidad_tipo', ev.entidad_tipo, 'entidad_id', ev.entidad_id,
             'anterior', ev.valor_anterior, 'nuevo', ev.valor_nuevo,
             'motivo', ev.motivo,
             'actor', eu.nombres || ' ' || eu.apellidos,
             'fecha', ev.created_at) AS e
      FROM core.ot_evento ev LEFT JOIN core.usuario eu ON eu.id = ev.actor_id
     WHERE ev.ot_id = p_ot_id
     ORDER BY ev.created_at DESC, ev.id DESC
     LIMIT p_limite
  ) s;
$$;

-- ═════════════════════════════════════════════════════════════════════════════
-- PARTE 3 · La función autoritativa y su refresco
-- ═════════════════════════════════════════════════════════════════════════════

-- Cabecera compacta de una OT. Se usa tanto para el nodo raíz como para cada
-- derivada anidada, así el árbol es homogéneo a cualquier profundidad.
CREATE OR REPLACE FUNCTION internal.fn_ot_cabecera(p_ot_id UUID)
RETURNS JSONB
LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  SELECT jsonb_build_object(
    'id',                  o.id,
    'numero',              o.numero_ot,
    'estado',              o.estado,
    'condicion',           o.condicion,
    'estado_administrativo', o.estado_administrativo,
    'prioridad_tecnica',   o.prioridad_tecnica,
    'es_emergencia',       o.es_emergencia,
    'emergencia', CASE WHEN o.es_emergencia THEN jsonb_build_object(
                         'justificacion', o.emergencia_justificacion,
                         'declarada_por', eu.nombres || ' ' || eu.apellidos,
                         'declarada_at',  o.emergencia_declarada_at,
                         -- La emergencia cambia el orden administrativo, no elimina
                         -- la regularización posterior (cap. 3, principio 5).
                         'regularizacion_pendiente', o.regularizacion_pendiente) END,
    'tipo_mantenimiento',  tm.nombre,
    'tipo_trabajo',        tt.nombre,
    'nivel',               o.nivel,
    'es_derivada',         o.ot_padre_id IS NOT NULL,
    'es_bloqueante_para_padre', o.es_bloqueante_para_padre,
    'coordinador',         co.nombres || ' ' || co.apellidos,
    'ejecutor',            ej.nombres || ' ' || ej.apellidos,
    'fechas', jsonb_build_object(
      'creacion',    o.fecha_creacion,
      'inicio_real', o.fecha_inicio_real,
      'termino_real', o.fecha_termino_real,
      'cierre',      o.fecha_cierre,
      'cancelacion', o.fecha_cancelacion),
    'veces_reabierta', o.veces_reabierta,
    'cancelacion', CASE WHEN o.estado = 'cancelada' THEN jsonb_build_object(
                          'motivo',      cc.nombre,
                          'observacion', o.cancelacion_observacion,
                          'fecha',       o.fecha_cancelacion) END
  )
  FROM core.orden_trabajo o
  LEFT JOIN core.usuario co       ON co.id = o.coordinador_id
  LEFT JOIN core.usuario ej       ON ej.id = o.ejecutor_id
  LEFT JOIN core.usuario eu       ON eu.id = o.emergencia_declarada_por
  LEFT JOIN core.catalogo_item tm ON tm.id = o.tipo_mantenimiento_id
  LEFT JOIN core.tipo_trabajo  tt ON tt.id = o.tipo_trabajo_id
  LEFT JOIN core.catalogo_item cc ON cc.id = o.motivo_cancelacion_id
  WHERE o.id = p_ot_id;
$$;

CREATE OR REPLACE FUNCTION internal.fn_ot_organizacion(p_ot_id UUID)
RETURNS JSONB
LANGUAGE sql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
  SELECT jsonb_build_object(
    'tenant',      jsonb_build_object('id', t.id, 'nombre', t.nombre),
    'sucursal',    CASE WHEN su.id IS NULL THEN NULL
                        ELSE jsonb_build_object('id', su.id, 'codigo', su.codigo, 'nombre', su.nombre) END,
    'empresa_ruc', CASE WHEN er.id IS NULL THEN NULL
                        ELSE jsonb_build_object('id', er.id, 'ruc', er.ruc,
                                                'razon_social', er.razon_social,
                                                'estado', er.estado) END,
    'area',        CASE WHEN ar.id IS NULL THEN NULL
                        ELSE jsonb_build_object('id', ar.id, 'codigo', ar.codigo, 'nombre', ar.nombre) END,
    'cecos',       CASE WHEN ce.id IS NULL THEN NULL
                        ELSE jsonb_build_object('id', ce.id, 'codigo', ce.codigo,
                                                'descripcion', ce.descripcion) END
  )
  FROM core.orden_trabajo o
  JOIN core.tenant t            ON t.id = o.tenant_id
  LEFT JOIN core.sucursal su    ON su.id = o.sucursal_id
  LEFT JOIN core.empresa_ruc er ON er.id = o.empresa_ruc_id
  LEFT JOIN core.area ar        ON ar.id = o.area_id
  LEFT JOIN core.cecos ce       ON ce.id = o.cecos_id
  WHERE o.id = p_ot_id;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- internal.fn_ot_trazabilidad — LA AUTORIDAD.
--
-- Arma el árbol completo desde las tablas reales. Recursiva sobre las derivadas,
-- con corte por profundidad para que una jerarquía patológica no tumbe la sesión.
--
-- p_profundidad: cuántos niveles de derivadas anidar. 0 = sólo esta OT.
-- p_resumido:    en las derivadas anidadas se omiten conversación y eventos, que
--                son los bloques pesados. El árbol del padre sirve para navegar;
--                el detalle completo de una hija se pide sobre la hija.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION internal.fn_ot_trazabilidad(
  p_ot_id       UUID,
  p_profundidad INT     DEFAULT 10,
  p_resumido    BOOLEAN DEFAULT false
)
RETURNS JSONB
LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, internal, public AS $$
DECLARE
  v_arbol      JSONB;
  v_derivadas  JSONB := '[]'::jsonb;
  v_hija       RECORD;
  v_total      INT := 1;
  v_max_nivel  INT := 0;
BEGIN
  IF p_ot_id IS NULL THEN RETURN '{}'::jsonb; END IF;
  IF NOT EXISTS (SELECT 1 FROM core.orden_trabajo WHERE id = p_ot_id) THEN
    RETURN '{}'::jsonb;
  END IF;

  -- Derivadas: recursión en profundidad. Cada hija trae su propio subárbol
  -- completo, de modo que el JSON del padre contiene literalmente todo lo que la
  -- OT generó, incluidas las nietas (cap. 10, 27.1).
  IF p_profundidad > 0 THEN
    FOR v_hija IN
      SELECT id FROM core.orden_trabajo
       WHERE ot_padre_id = p_ot_id AND deleted_at IS NULL
       -- Por número, no por created_at: el número es único y no empata dentro
       -- de una misma transacción.
       ORDER BY numero_ot
    LOOP
      v_derivadas := v_derivadas || jsonb_build_array(
        internal.fn_ot_trazabilidad(v_hija.id, p_profundidad - 1, true)
      );
    END LOOP;
  END IF;

  SELECT coalesce(sum(coalesce((d->'_meta'->>'total_nodos')::int, 1)), 0) + 1,
         coalesce(max(coalesce((d->'_meta'->>'profundidad_arbol')::int, 0)), -1) + 1
    INTO v_total, v_max_nivel
    FROM jsonb_array_elements(v_derivadas) d;

  v_arbol := jsonb_build_object(
    'ot',             internal.fn_ot_cabecera(p_ot_id),
    'organizacion',   internal.fn_ot_organizacion(p_ot_id),
    'origen',         internal.fn_ot_origen(p_ot_id),
    'diagnosticos',   internal.fn_ot_diagnosticos(p_ot_id),
    'cotizaciones',   internal.fn_ot_cotizaciones(p_ot_id),
    'ejecucion',      internal.fn_ot_ejecucion(p_ot_id),
    'cierre',         internal.fn_ot_cierre(p_ot_id),
    'administrativo', internal.fn_ot_administrativo(p_ot_id),
    'derivadas',      v_derivadas,
    'adjuntos',       coalesce((
        SELECT jsonb_agg(jsonb_build_object(
                 'id', a.id, 'nombre', a.nombre, 'tipo', a.tipo, 'etapa', a.etapa,
                 'mime', a.mime_type, 'tamano', a.tamano_bytes, 'estado', a.estado,
                 'entidad_tipo', a.entidad_tipo, 'entidad_id', a.entidad_id,
                 'autor', au.nombres || ' ' || au.apellidos, 'fecha', a.created_at
               ) ORDER BY a.created_at, a.id)
          FROM core.adjunto a LEFT JOIN core.usuario au ON au.id = a.autor_id
         WHERE a.ot_id = p_ot_id), '[]'::jsonb),
    'costos',         internal.fn_ot_costos(p_ot_id)
  );

  -- Bloques pesados: sólo en el nodo por el que se preguntó, no en cada nieta.
  IF NOT p_resumido THEN
    v_arbol := v_arbol
      || jsonb_build_object('conversacion', internal.fn_ot_conversacion(p_ot_id))
      || jsonb_build_object('eventos',      internal.fn_ot_eventos(p_ot_id));
  END IF;

  -- El instante de generación va SÓLO en el nodo raíz. Si cada derivada anidada
  -- llevara el suyo, dos llamadas consecutivas producirían árboles distintos y
  -- sería imposible comparar el snapshot cacheado con la función autoritativa
  -- para verificar la integridad del motor.
  RETURN v_arbol || jsonb_build_object('_meta',
    jsonb_build_object(
      'version',            1,
      'profundidad_arbol',  v_max_nivel,
      'total_nodos',        v_total,
      'resumido',           p_resumido)
    || CASE WHEN p_resumido THEN '{}'::jsonb
            ELSE jsonb_build_object('generado_en', now()) END);
END; $$;

COMMENT ON FUNCTION internal.fn_ot_trazabilidad(UUID, INT, BOOLEAN) IS
  'AUTORIDAD del árbol de trazabilidad. Lo arma desde las tablas reales, que son la fuente de verdad. La columna orden_trabajo.trazabilidad es sólo una proyección cacheada de esta función.';

-- ─────────────────────────────────────────────────────────────────────────────
-- app.sp_ot_trazabilidad_refrescar — recalcula y guarda el snapshot.
--
-- Lo llaman los SP de negocio al terminar su trabajo, y el camino de lectura de
-- forma perezosa cuando encuentra la bandera levantada.
--
-- p_forzar = false y la OT limpia => no hace nada. Eso permite llamarlo sin miedo
-- desde cualquier sitio.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION app.sp_ot_trazabilidad_refrescar(
  p_ot_id  UUID,
  p_forzar BOOLEAN DEFAULT false
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v_dirty  BOOLEAN;
  v_arbol  JSONB;
  v_padre  UUID;
BEGIN
  SELECT trazabilidad_dirty, ot_padre_id INTO v_dirty, v_padre
    FROM core.orden_trabajo WHERE id = p_ot_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('NOT_FOUND', 'La OT no existe'));
  END IF;

  IF NOT v_dirty AND NOT p_forzar THEN
    RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('refrescada', false));
  END IF;

  v_arbol := internal.fn_ot_trazabilidad(p_ot_id, 10, false);

  -- Escribir el snapshot no es "modificar la OT" en el sentido del cap. 21.3, así
  -- que la guarda de OT cerrada se levanta explícitamente para esta operación.
  PERFORM set_config('mip.permitir_update_cerrada', 'on', true);
  UPDATE core.orden_trabajo
     SET trazabilidad         = v_arbol,
         trazabilidad_dirty   = false,
         trazabilidad_version = trazabilidad_version + 1,
         trazabilidad_at      = now()
   WHERE id = p_ot_id;
  PERFORM set_config('mip.permitir_update_cerrada', 'off', true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'refrescada',  true,
    'total_nodos', (v_arbol->'_meta'->>'total_nodos')::int,
    'profundidad', (v_arbol->'_meta'->>'profundidad_arbol')::int));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

-- Devuelve el árbol garantizando frescura: si está sucio, lo refresca antes.
-- Este es el camino de lectura perezoso mencionado arriba.
CREATE OR REPLACE FUNCTION internal.fn_ot_trazabilidad_fresca(p_ot_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v_arbol JSONB;
BEGIN
  IF EXISTS (SELECT 1 FROM core.orden_trabajo WHERE id = p_ot_id AND trazabilidad_dirty) THEN
    PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  END IF;
  SELECT trazabilidad INTO v_arbol FROM core.orden_trabajo WHERE id = p_ot_id;
  RETURN coalesce(v_arbol, '{}'::jsonb);
END; $$;

-- Mantenimiento: refresca en lote todo lo que quedó sucio. Útil tras una carga
-- masiva o una corrección manual, y como tarea programada de seguridad.
CREATE OR REPLACE FUNCTION app.sp_trazabilidad_refrescar_pendientes(p_limite INT DEFAULT 500)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE
  v_ot      RECORD;
  v_contador INT := 0;
BEGIN
  -- De las hojas hacia la raíz: refrescar primero las derivadas evita rehacer el
  -- árbol del padre dos veces.
  FOR v_ot IN
    SELECT id FROM core.orden_trabajo
     WHERE trazabilidad_dirty = true
     ORDER BY nivel DESC, created_at
     LIMIT p_limite
  LOOP
    PERFORM app.sp_ot_trazabilidad_refrescar(v_ot.id, true);
    v_contador := v_contador + 1;
  END LOOP;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('refrescadas', v_contador));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
