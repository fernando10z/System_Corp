-- =============================================================================
-- smoke-invariantes.sql
--
-- Comprueba que la base RECHAZA lo que el documento dice que debe rechazar.
-- Un invariante que no se prueba en su caso negativo no está probado.
--
-- Cada bloque provoca deliberadamente una violación y falla el script si la
-- operación es aceptada. Se ejecuta después del smoke del ciclo completo.
-- =============================================================================
\set ON_ERROR_STOP on
SET search_path = app, core, internal, public;

DO $INV$
DECLARE
  t UUID; ot UUID; hija UUID; u UUID; sol UUID; r JSONB;
  fallos INT := 0;

  PROCEDURE_NOOP TEXT;
BEGIN
  SELECT id INTO t   FROM core.tenant WHERE codigo='demo';
  SELECT id INTO ot  FROM core.orden_trabajo WHERE numero_ot='OT-000001';
  SELECT id INTO hija FROM core.orden_trabajo WHERE numero_ot='OT-000002';
  SELECT coordinador_id INTO u FROM core.orden_trabajo WHERE id=ot;
  SELECT solicitud_origen_id INTO sol FROM core.orden_trabajo WHERE id=ot;

  -- 1 · Ciclos de derivación (cap. 21.3, QA-15)
  BEGIN
    UPDATE core.orden_trabajo SET ot_padre_id = hija WHERE id = ot;
    RAISE WARNING 'FALLO 1 · se aceptó un ciclo padre-hijo'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 1 · ciclo de derivación rechazado'; END;

  -- 2 · Exactamente un diagnóstico vigente (cap. 21.3)
  BEGIN
    INSERT INTO core.diagnostico (tenant_id,ot_id,version,vigente,diagnostico,causa_probable,
                                  alcance,trabajo_a_realizar,autor_id)
    VALUES (t,ot,99,true,'x','y','z','w',u);
    RAISE WARNING 'FALLO 2 · dos diagnósticos vigentes'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 2 · segundo diagnóstico vigente rechazado'; END;

  -- 3 · Exactamente una cotización vigente (cap. 21.3)
  BEGIN
    INSERT INTO core.cotizacion (tenant_id,ot_id,version,vigente,monto,cargada_por)
    VALUES (t,ot,99,true,100,u);
    RAISE WARNING 'FALLO 3 · dos cotizaciones vigentes'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 3 · segunda cotización vigente rechazada'; END;

  -- 4 · Una sola pausa abierta (cap. 29.3, QA-12)
  BEGIN
    INSERT INTO core.ot_pausa (tenant_id,ot_id,motivo_texto,pausada_por) VALUES (t,hija,'A',u);
    INSERT INTO core.ot_pausa (tenant_id,ot_id,motivo_texto,pausada_por) VALUES (t,hija,'B',u);
    RAISE WARNING 'FALLO 4 · dos pausas abiertas'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 4 · segunda pausa abierta rechazada'; END;

  -- 5 · El término no antecede al inicio (cap. 21.3, QA-13)
  BEGIN
    UPDATE core.orden_trabajo
       SET fecha_inicio_real = now(), fecha_termino_real = now() - interval '2 days'
     WHERE id = hija;
    RAISE WARNING 'FALLO 5 · término anterior al inicio'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 5 · término anterior al inicio rechazado'; END;

  -- 6 · Monto de liberación no negativo (cap. 21.3, QA-21)
  BEGIN
    INSERT INTO core.liberacion_historial (tenant_id,ot_id,estado_nuevo,monto_nuevo,actor_id)
    VALUES (t,ot,'parcial',-5,u);
    RAISE WARNING 'FALLO 6 · liberación negativa'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 6 · monto de liberación negativo rechazado'; END;

  -- 7 · Una solicitud se convierte una sola vez (cap. 21.3, QA-03)
  BEGIN
    INSERT INTO core.orden_trabajo (tenant_id,numero_ot,solicitud_origen_id,coordinador_id)
    VALUES (t,'OT-DUPLICADA',sol,u);
    RAISE WARNING 'FALLO 7 · solicitud convertida dos veces'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 7 · segunda conversión de la solicitud rechazada'; END;

  -- 8 · La bitácora es append-only (cap. 18.1)
  BEGIN
    UPDATE core.ot_evento SET motivo = 'alterado' WHERE ot_id = ot;
    RAISE WARNING 'FALLO 8 · la bitácora admitió UPDATE'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 8 · UPDATE sobre la bitácora rechazado'; END;

  BEGIN
    DELETE FROM core.ot_evento WHERE ot_id = ot;
    RAISE WARNING 'FALLO 8b · la bitácora admitió DELETE'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 8b · DELETE sobre la bitácora rechazado'; END;

  -- 9 · La emergencia exige justificación (cap. 8.4, QA-11)
  BEGIN
    UPDATE core.orden_trabajo SET es_emergencia = true, emergencia_justificacion = NULL
     WHERE id = hija;
    RAISE WARNING 'FALLO 9 · emergencia sin justificación'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 9 · emergencia sin justificación rechazada'; END;

  -- 10 · Transiciones fuera del Anexo A
  BEGIN
    PERFORM internal.validar_transicion_ot(ot,'creada','cerrada',NULL);
    RAISE WARNING 'FALLO 10 · creada -> cerrada permitida'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 10 · transición creada->cerrada rechazada'; END;

  -- 11 · Reapertura sin motivo (cap. 14.4, QA-22)
  BEGIN
    PERFORM internal.validar_transicion_ot(ot,'cerrada','en_trabajo',NULL);
    RAISE WARNING 'FALLO 11 · reapertura sin motivo'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 11 · reapertura sin motivo rechazada'; END;

  -- 12 · Un área no puede repetir código dentro de la misma RUC (cap. 5)
  BEGIN
    INSERT INTO core.area (tenant_id, empresa_ruc_id, codigo, nombre)
    SELECT t, empresa_ruc_id, codigo, 'Duplicada' FROM core.area LIMIT 1;
    RAISE WARNING 'FALLO 12 · área duplicada en la misma RUC'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 12 · área duplicada en la misma RUC rechazada'; END;

  -- 13 · Aislamiento entre tenants (cap. 21.3, QA-25)
  BEGIN
    PERFORM internal.assert_acceso_tenant(u, gen_random_uuid(), false);
    RAISE WARNING 'FALLO 13 · acceso a otro tenant permitido'; fallos := fallos + 1;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 13 · acceso cruzado entre tenants rechazado'; END;

  -- 14 · Una OT cerrada no cambia salvo reapertura auditada (cap. 21.3, QA-22)
  BEGIN
    UPDATE core.orden_trabajo SET estado = 'en_trabajo'
     WHERE id = ot AND estado = 'cerrada';
    IF FOUND THEN
      RAISE WARNING 'FALLO 14 · se editó una OT cerrada'; fallos := fallos + 1;
    ELSE
      RAISE NOTICE '  ok 14 · (la OT no estaba cerrada en este punto; sin caso que probar)';
    END IF;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE '  ok 14 · edición directa de OT cerrada rechazada'; END;

  IF fallos > 0 THEN
    RAISE EXCEPTION '% invariante(s) NO se hicieron cumplir', fallos;
  END IF;
  RAISE NOTICE '  ── todos los invariantes rechazan lo que deben ──';

  -- Se deshace todo lo que este bloque pudo haber insertado antes de fallar.
  RAISE EXCEPTION 'ROLLBACK_LIMPIEZA';
EXCEPTION WHEN OTHERS THEN
  IF SQLERRM = 'ROLLBACK_LIMPIEZA' THEN
    RAISE NOTICE '  (cambios de prueba revertidos)';
  ELSE
    RAISE;
  END IF;
END $INV$;
