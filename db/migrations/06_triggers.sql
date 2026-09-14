-- =============================================================================
-- 06_triggers.sql
--
-- Los invariantes que NO pueden delegarse a la capa de aplicación, porque el
-- documento los declara restricciones de integridad (cap. 21.3, Anexo C) y porque
-- deben resistir incluso un UPDATE manual por psql:
--
--   (a) updated_at automático en toda tabla que lo tenga — por introspección.
--   (b) Anti-ciclo en la jerarquía de OT derivadas + cálculo del nivel  (QA-15).
--   (c) Guarda de OT cerrada: sólo cambia por reapertura auditada       (QA-22).
--   (d) Consolidación del estado administrativo a partir de SOLPED/OC/liberación.
--   (e) Coherencia de la condición pausada con las pausas abiertas      (QA-12).
--
-- El motor de trazabilidad tiene sus propios triggers y vive en 07, aparte, para
-- que se lea como una pieza completa.
-- =============================================================================
SET search_path = core, internal, public;

-- ── (a) updated_at por introspección ─────────────────────────────────────────
-- Un solo trigger genérico aplicado en bucle a toda tabla de core/audit que tenga
-- la columna. Evita 40 bloques de boilerplate idénticos.
CREATE OR REPLACE FUNCTION core.set_updated_at() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END; $$;

DO $$
DECLARE r RECORD;
BEGIN
  FOR r IN
    SELECT c.table_schema, c.table_name
      FROM information_schema.columns c
      JOIN information_schema.tables t
        ON t.table_schema = c.table_schema AND t.table_name = c.table_name
     WHERE c.table_schema IN ('core','audit')
       AND c.column_name  = 'updated_at'
       AND t.table_type   = 'BASE TABLE'
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_set_updated_at ON %I.%I;',
                   r.table_name, r.table_schema, r.table_name);
    EXECUTE format('CREATE TRIGGER trg_%I_set_updated_at BEFORE UPDATE ON %I.%I
                    FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();',
                   r.table_name, r.table_schema, r.table_name);
  END LOOP;
END $$;

-- ── (b) Anti-ciclo y nivel de la jerarquía de OT ─────────────────────────────
-- "Una OT no puede ser su propio ancestro ni crear ciclos de derivación" (cap.
-- 21.3). El CHECK de la tabla ataja el auto-padre; esto ataja los ciclos de N
-- saltos, que es lo que ocurre cuando alguien reasigna un padre.
CREATE OR REPLACE FUNCTION core.validar_jerarquia_ot() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
  v_ancestro UUID := NEW.ot_padre_id;
  v_nivel    INT  := 0;
  v_saltos   INT  := 0;
BEGIN
  IF NEW.ot_padre_id IS NULL THEN
    NEW.nivel := 0;
    RETURN NEW;
  END IF;

  IF NEW.ot_padre_id = NEW.id THEN
    RAISE EXCEPTION 'Una OT no puede ser padre de sí misma' USING ERRCODE = 'MIP01';
  END IF;

  -- Subimos por la cadena de padres. Si volvemos a encontrar a NEW.id, hay ciclo.
  WHILE v_ancestro IS NOT NULL LOOP
    v_saltos := v_saltos + 1;
    IF v_ancestro = NEW.id THEN
      RAISE EXCEPTION 'La jerarquía de OT derivadas no admite ciclos' USING ERRCODE = 'MIP01';
    END IF;
    -- Cinturón de seguridad ante datos corruptos preexistentes: sin esto, un ciclo
    -- ya grabado colgaría el bucle en lugar de fallar.
    IF v_saltos > 100 THEN
      RAISE EXCEPTION 'Jerarquía de OT demasiado profunda o corrupta' USING ERRCODE = 'MIP01';
    END IF;
    v_nivel := v_saltos;
    SELECT ot_padre_id INTO v_ancestro FROM core.orden_trabajo WHERE id = v_ancestro;
  END LOOP;

  NEW.nivel := v_nivel;
  RETURN NEW;
END; $$;

DROP TRIGGER IF EXISTS trg_ot_jerarquia ON core.orden_trabajo;
CREATE TRIGGER trg_ot_jerarquia
  BEFORE INSERT OR UPDATE OF ot_padre_id ON core.orden_trabajo
  FOR EACH ROW EXECUTE FUNCTION core.validar_jerarquia_ot();

-- ── (c) Guarda de OT cerrada ─────────────────────────────────────────────────
-- "Una OT cerrada sólo cambia mediante reapertura auditada" (cap. 21.3, QA-22).
-- Los SP de reapertura y de seguimiento administrativo levantan la bandera de
-- sesión `mip.permitir_update_cerrada` para poder tocar la fila legítimamente.
--
-- Registrar OC o liberación después del cierre NO reabre la OT (cap. 14.3, QA-20),
-- por eso las columnas administrativas y las de trazabilidad quedan exentas.
CREATE OR REPLACE FUNCTION core.guardar_ot_cerrada() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.estado <> 'cerrada' THEN
    RETURN NEW;
  END IF;

  IF coalesce(current_setting('mip.permitir_update_cerrada', true), 'off') = 'on' THEN
    RETURN NEW;
  END IF;

  -- Exentos: seguimiento administrativo (QA-20) y el snapshot de trazabilidad.
  IF ROW(NEW.*) IS NOT DISTINCT FROM ROW(OLD.*) THEN
    RETURN NEW;
  END IF;

  IF NEW.estado             IS DISTINCT FROM OLD.estado
     OR NEW.fecha_cierre    IS DISTINCT FROM OLD.fecha_cierre
     OR NEW.fecha_inicio_real  IS DISTINCT FROM OLD.fecha_inicio_real
     OR NEW.fecha_termino_real IS DISTINCT FROM OLD.fecha_termino_real
     OR NEW.coordinador_id  IS DISTINCT FROM OLD.coordinador_id
     OR NEW.ejecutor_id     IS DISTINCT FROM OLD.ejecutor_id
     OR NEW.prioridad_tecnica IS DISTINCT FROM OLD.prioridad_tecnica
     OR NEW.ot_padre_id     IS DISTINCT FROM OLD.ot_padre_id
     OR NEW.es_emergencia   IS DISTINCT FROM OLD.es_emergencia
  THEN
    RAISE EXCEPTION 'Una OT cerrada sólo puede modificarse mediante reapertura auditada'
      USING ERRCODE = 'MIP01';
  END IF;

  RETURN NEW;
END; $$;

DROP TRIGGER IF EXISTS trg_ot_guarda_cerrada ON core.orden_trabajo;
CREATE TRIGGER trg_ot_guarda_cerrada
  BEFORE UPDATE ON core.orden_trabajo
  FOR EACH ROW EXECUTE FUNCTION core.guardar_ot_cerrada();

-- ── (d) Estado administrativo consolidado ────────────────────────────────────
-- Traduce SOLPED/OC/liberación al indicador único del cap. 31.1, que se muestra
-- en listas, tablero y ficha. Se recalcula solo, para que ningún SP pueda dejarlo
-- desactualizado por olvido.
CREATE OR REPLACE FUNCTION core.consolidar_estado_administrativo(p_ot_id UUID)
RETURNS core.estado_administrativo
LANGUAGE plpgsql AS $$
DECLARE
  v_solped    core.solped%ROWTYPE;
  v_tiene_oc  BOOLEAN;
  v_liberacion core.estado_liberacion;
  v_estado    core.estado_administrativo;
BEGIN
  SELECT * INTO v_solped
    FROM core.solped
   WHERE ot_id = p_ot_id AND vigente = true AND anulada = false
   LIMIT 1;

  SELECT EXISTS (SELECT 1 FROM core.orden_compra WHERE ot_id = p_ot_id AND anulada = false)
    INTO v_tiene_oc;

  -- Por secuencia, no por created_at: ver la nota en core.liberacion_historial.
  SELECT estado_nuevo INTO v_liberacion
    FROM core.liberacion_historial
   WHERE ot_id = p_ot_id
   ORDER BY secuencia DESC
   LIMIT 1;

  IF v_solped.id IS NULL THEN
    RETURN 'sin_solped';
  ELSIF v_solped.estado_integracion <> 'creada_en_sap' OR v_solped.numero_sap IS NULL THEN
    RETURN 'solped_pendiente';
  END IF;

  -- A partir de aquí la SOLPED está confirmada en SAP.
  IF NOT v_tiene_oc THEN
    RETURN 'oc_pendiente';
  END IF;

  v_estado := CASE v_liberacion
                WHEN 'total'   THEN 'administracion_completa'::core.estado_administrativo
                WHEN 'parcial' THEN 'liberacion_parcial'::core.estado_administrativo
                WHEN 'pendiente' THEN 'liberacion_pendiente'::core.estado_administrativo
                ELSE 'oc_registrada'::core.estado_administrativo
              END;
  RETURN v_estado;
END; $$;

CREATE OR REPLACE FUNCTION core.refrescar_estado_administrativo() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
  v_ot_id  UUID := coalesce(NEW.ot_id, OLD.ot_id);
  v_estado core.estado_administrativo;
  v_monto  NUMERIC(14,2);
BEGIN
  v_estado := core.consolidar_estado_administrativo(v_ot_id);

  SELECT coalesce(monto_nuevo, 0) INTO v_monto
    FROM core.liberacion_historial
   WHERE ot_id = v_ot_id
   ORDER BY secuencia DESC
   LIMIT 1;

  -- El seguimiento existe siempre que la OT exista; se crea perezosamente aquí.
  INSERT INTO core.seguimiento_administrativo (tenant_id, ot_id, estado_consolidado, monto_liberado_total)
  SELECT ot.tenant_id, ot.id, v_estado, coalesce(v_monto, 0)
    FROM core.orden_trabajo ot WHERE ot.id = v_ot_id
  ON CONFLICT (ot_id) DO UPDATE
    SET estado_consolidado   = EXCLUDED.estado_consolidado,
        monto_liberado_total = EXCLUDED.monto_liberado_total,
        updated_at           = now();

  -- Actualizar la OT no debe chocar con la guarda de OT cerrada: el cap. 14.3 dice
  -- justamente que actualizar OC/liberación no reabre la OT.
  PERFORM set_config('mip.permitir_update_cerrada', 'on', true);
  UPDATE core.orden_trabajo SET estado_administrativo = v_estado WHERE id = v_ot_id;
  PERFORM set_config('mip.permitir_update_cerrada', 'off', true);

  RETURN coalesce(NEW, OLD);
END; $$;

DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['solped','orden_compra','liberacion_historial'] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_estado_admin ON core.%I;', t, t);
    EXECUTE format('CREATE TRIGGER trg_%I_estado_admin
                      AFTER INSERT OR UPDATE OR DELETE ON core.%I
                      FOR EACH ROW EXECUTE FUNCTION core.refrescar_estado_administrativo();', t, t);
  END LOOP;
END $$;

-- ── (e) Condición pausada coherente ──────────────────────────────────────────
-- El índice único uq_pausa_abierta ya impide dos pausas simultáneas (QA-12).
-- Esto mantiene sincronizada la condición visible de la OT sin que cada SP tenga
-- que acordarse de hacerlo.
CREATE OR REPLACE FUNCTION core.refrescar_condicion_ot() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
  v_ot_id     UUID := coalesce(NEW.ot_id, OLD.ot_id);
  v_hay_pausa BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM core.ot_pausa WHERE ot_id = v_ot_id AND fecha_reanudacion IS NULL
  ) INTO v_hay_pausa;

  UPDATE core.orden_trabajo
     SET condicion = CASE WHEN v_hay_pausa THEN 'pausada'::core.ot_condicion
                          ELSE 'activa'::core.ot_condicion END
   WHERE id = v_ot_id
     AND condicion IS DISTINCT FROM (CASE WHEN v_hay_pausa THEN 'pausada'::core.ot_condicion
                                          ELSE 'activa'::core.ot_condicion END);

  RETURN coalesce(NEW, OLD);
END; $$;

DROP TRIGGER IF EXISTS trg_pausa_condicion ON core.ot_pausa;
CREATE TRIGGER trg_pausa_condicion
  AFTER INSERT OR UPDATE OR DELETE ON core.ot_pausa
  FOR EACH ROW EXECUTE FUNCTION core.refrescar_condicion_ot();

-- ── (f) Inmutabilidad de la bitácora ─────────────────────────────────────────
-- 90_grants revoca UPDATE/DELETE al rol de aplicación, pero el owner de la BD
-- todavía podría. Esto lo bloquea también para él: la bitácora es append-only y
-- punto (cap. 18.1).
CREATE OR REPLACE FUNCTION core.bloquear_mutacion_bitacora() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'core.ot_evento es append-only: no admite % (cap. 18.1)', TG_OP
    USING ERRCODE = 'MIP01';
END; $$;

DROP TRIGGER IF EXISTS trg_ot_evento_inmutable ON core.ot_evento;
CREATE TRIGGER trg_ot_evento_inmutable
  BEFORE UPDATE OR DELETE ON core.ot_evento
  FOR EACH ROW EXECUTE FUNCTION core.bloquear_mutacion_bitacora();
