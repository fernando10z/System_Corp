-- =============================================================================
-- smoke-trazabilidad.sql
--
-- Recorre el ciclo COMPLETO del documento usando exclusivamente stored
-- procedures del schema `app` — es decir, exactamente por donde pasa el backend.
--
--   solicitud -> aceptar -> OT -> diagnóstico v1 -> diagnóstico v2 ->
--   cotización v1 -> cotización v2 (reemplazo) -> iniciar -> avance ->
--   pausa -> reanudar -> incidencia -> derivada -> nieta -> mensaje ->
--   trabajo realizado -> devolver a corrección -> trabajo realizado v2 ->
--   aprobar -> SOLPED -> número SAP -> OC -> liberación parcial ->
--   cerrar con pendiente -> registrar OC posterior -> reabrir -> cerrar
--
-- Al final imprime el árbol de trazabilidad y comprueba que el snapshot cacheado
-- coincide con la función autoritativa.
--
-- Uso:  bash db/scripts/smoke.sh
-- =============================================================================
\set ON_ERROR_STOP on
SET search_path = app, core, internal, public;

DO $SMOKE$
DECLARE
  t UUID; adm UUID; coord UUID; tec UUID; solic UUID; abast UUID;
  suc UUID; emp UUID; ar UUID; tipo_mant UUID; tipo_trab UUID; impacto UUID;
  r JSONB; sol_id UUID; ot UUID; hija UUID; nieta UUID; solped UUID; oc UUID;
  cot_id UUID;
  paso TEXT;

  PROCEDURE_FALLA TEXT;
  FUNCTION_OK BOOLEAN;
BEGIN
  SELECT id INTO t FROM core.tenant WHERE codigo='demo';
  SELECT id INTO adm FROM core.usuario WHERE email='admin@mip.local';
  SELECT id INTO suc FROM core.sucursal WHERE tenant_id=t AND codigo='PLANTA-01';
  SELECT id INTO emp FROM core.empresa_ruc WHERE tenant_id=t AND ruc='20100000001';
  SELECT id INTO ar  FROM core.area WHERE empresa_ruc_id=emp AND codigo='MANTTO';
  SELECT id INTO tipo_mant FROM core.catalogo_item WHERE tipo='tipo_mantenimiento' AND codigo='CORRECTIVO';
  SELECT id INTO tipo_trab FROM core.tipo_trabajo WHERE codigo='MEC_BOMBAS';
  SELECT id INTO impacto FROM core.catalogo_item WHERE tipo='impacto_operativo' AND codigo='PARADA_PARCIAL';

  -- Usuarios de prueba, uno por rol del cap. 4.
  r := app.sp_usuario_crear(adm,t,true,'coord@demo.local','Ana','Ruiz','ClaveSegura2026',
        ARRAY['coordinador'],'Coordinadora de mantenimiento');
  coord := (r->'data'->>'id')::uuid;
  r := app.sp_usuario_crear(adm,t,true,'tecnico@demo.local','Luis','Paredes','ClaveSegura2026',
        ARRAY['tecnico'],'Técnico mecánico');
  tec := (r->'data'->>'id')::uuid;
  r := app.sp_usuario_crear(adm,t,true,'solicitante@demo.local','Rosa','Vega','ClaveSegura2026',
        ARRAY['solicitante'],'Supervisora de producción');
  solic := (r->'data'->>'id')::uuid;
  r := app.sp_usuario_crear(adm,t,true,'abasto@demo.local','Jorge','Salas','ClaveSegura2026',
        ARRAY['abastecimiento'],'Analista de abastecimiento');
  abast := (r->'data'->>'id')::uuid;
  RAISE NOTICE '  01 · usuarios creados (coordinador, técnico, solicitante, abastecimiento)';

  -- ST-01 · el solicitante reporta. Sin activo, sin CECOS, sin diagnóstico.
  r := app.sp_solicitud_crear(solic,t,false,
        'Fuga de aceite en bomba 3',
        'Desde el turno de la mañana la bomba 3 del taller pierde aceite de forma constante. Hay una mancha grande en el piso.',
        'Taller mecánico, nave 2, junto al tablero', ar, impacto, NULL, 'alta', true);
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'ST-01 falló: %', r; END IF;
  sol_id := (r->'data'->>'id')::uuid;
  RAISE NOTICE '  02 · solicitud % creada y enviada', r->'data'->>'numero';

  r := app.sp_solicitud_tomar_revision(coord,t,false,sol_id);
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'tomar revisión falló: %', r; END IF;
  RAISE NOTICE '  03 · coordinadora toma la revisión (marca el KPI de primera revisión)';

  -- ST-02 · aceptar => se crea la OT y la solicitud queda inmutable como origen.
  r := app.sp_ot_crear_desde_solicitud(coord,t,false,sol_id,suc,emp,ar,tipo_mant,'alta',coord,
        false,NULL,tipo_trab);
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'conversión a OT falló: %', r; END IF;
  ot := (r->'data'->>'id')::uuid;
  RAISE NOTICE '  04 · OT % creada desde la solicitud', r->'data'->>'numero_ot';

  r := app.sp_ot_cambiar_estado(coord,t,false,ot,'en_diagnostico','Contexto técnico confirmado');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'a diagnóstico falló: %', r; END IF;

  -- DG-01 · el técnico diagnostica, y luego lo corrige tras desmontar.
  r := app.sp_diagnostico_registrar(tec,t,false,ot,
        'Retén de eje desgastado con fuga por el sello principal.',
        'Fatiga del material por horas de servicio.',
        'Reemplazo del retén del eje de la bomba 3.',
        'Desmontar la bomba, retirar el retén, instalar el repuesto y probar.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'diagnóstico v1 falló: %', r; END IF;

  r := app.sp_diagnostico_registrar(tec,t,false,ot,
        'Además del retén, el eje presenta rayado profundo en la zona de sello.',
        'Desalineación del acoplamiento que aceleró el desgaste.',
        'Reemplazo del retén, rectificado del eje y alineación del acoplamiento.',
        'Desmontar, rectificar el eje en taller externo, reemplazar retén y alinear.',
        NULL, NULL, 'Hallazgo tras el desmontaje: el eje también está comprometido.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'diagnóstico v2 falló: %', r; END IF;
  RAISE NOTICE '  05 · dos versiones de diagnóstico; la v1 se conserva';

  r := app.sp_diagnostico_aprobar(coord,t,false,
        (SELECT id FROM core.diagnostico WHERE ot_id=ot AND vigente));
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'aprobar diagnóstico falló: %', r; END IF;

  -- QA-07 · no se puede pasar a cotización sin diagnóstico... ya lo hay, así que pasa.
  r := app.sp_ot_cambiar_estado(coord,t,false,ot,'en_cotizacion');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'a cotización falló: %', r; END IF;

  -- CT-01 · abastecimiento carga y luego reemplaza la cotización.
  r := app.sp_cotizacion_cargar(abast,t,false,ot,NULL,'Servicios Mecánicos AB S.A.C.','20512345678',
        'COT-2026-0077', current_date, 1500.00, 'PEN', 5, 'Sólo cambio de retén.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'cotización v1 falló: %', r; END IF;

  r := app.sp_cotizacion_cargar(abast,t,false,ot,NULL,'Servicios Mecánicos AB S.A.C.','20512345678',
        'COT-2026-0081', current_date, 2850.00, 'PEN', 8, 'Incluye rectificado de eje.',
        'El nuevo diagnóstico amplió el alcance: se suma el rectificado del eje.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'cotización v2 falló: %', r; END IF;
  cot_id := (r->'data'->>'id')::uuid;
  RAISE NOTICE '  06 · cotización reemplazada; la v1 conserva PDF, datos y motivo';

  -- Ejecución.
  r := app.sp_ejecucion_iniciar(coord,t,false,ot,tec,now() - interval '3 days','Inicio confirmado.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'iniciar falló: %', r; END IF;
  RAISE NOTICE '  07 · ejecución iniciada con responsable y confirmación';

  r := app.sp_avance_registrar(tec,t,false,ot,'Bomba desmontada y eje enviado a rectificado.',40);
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'avance falló: %', r; END IF;

  r := app.sp_pausa_registrar(tec,t,false,ot,'Esperando el eje del taller de rectificado.',
        (SELECT id FROM core.catalogo_item WHERE tipo='motivo_pausa' AND codigo='ESPERA_PROVEEDOR'));
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'pausa falló: %', r; END IF;

  -- QA-12 · una segunda pausa abierta debe rechazarse.
  r := app.sp_pausa_registrar(tec,t,false,ot,'Otra pausa');
  IF (r->>'ok')::boolean THEN RAISE EXCEPTION 'QA-12 FALLÓ: aceptó dos pausas abiertas'; END IF;
  RAISE NOTICE '  08 · QA-12 ok · segunda pausa simultánea rechazada';

  r := app.sp_pausa_reanudar(tec,t,false,ot,'Eje recibido conforme.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'reanudar falló: %', r; END IF;

  r := app.sp_incidencia_registrar(tec,t,false,ot,
        'El acoplamiento llegó con medida distinta a la especificada.',
        (SELECT id FROM core.catalogo_item WHERE tipo='tipo_incidencia' AND codigo='MATERIAL_INCORRECTO'));
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'incidencia falló: %', r; END IF;

  -- Derivadas: mecánica principal + eléctrica con otro proveedor + pintura (nieta).
  r := app.sp_ot_crear_derivada(coord,t,false,ot,
        'El tablero de arranque de la bomba requiere intervención eléctrica con otro proveedor.',
        tipo_mant, (SELECT id FROM core.tipo_trabajo WHERE codigo='ELE_TABLEROS'),
        'media', coord, NULL, NULL, NULL, true,
        (SELECT id FROM core.catalogo_item WHERE tipo='motivo_derivacion' AND codigo='PROVEEDOR'));
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'derivada falló: %', r; END IF;
  hija := (r->'data'->>'id')::uuid;

  r := app.sp_ot_crear_derivada(coord,t,false,hija,
        'Repintado del gabinete tras la intervención eléctrica.',
        tipo_mant, (SELECT id FROM core.tipo_trabajo WHERE codigo='PINTURA'),
        'baja', coord, NULL, NULL, NULL, false);   -- no bloqueante
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'nieta falló: %', r; END IF;
  nieta := (r->'data'->>'id')::uuid;
  RAISE NOTICE '  09 · jerarquía de 3 niveles: OT -> derivada -> nieta';

  -- QA-15 · ciclo prohibido.
  BEGIN
    UPDATE core.orden_trabajo SET ot_padre_id = nieta WHERE id = ot;
    RAISE EXCEPTION 'QA-15 FALLÓ: aceptó un ciclo en la jerarquía';
  EXCEPTION WHEN SQLSTATE 'MIP01' THEN
    RAISE NOTICE '  10 · QA-15 ok · ciclo padre-hijo rechazado';
  END;

  r := app.sp_mensaje_publicar(coord,t,false,ot,
        'Rosa, el eje ya volvió de rectificado. Mañana montamos y probamos.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'mensaje falló: %', r; END IF;

  -- Trabajo realizado, corrección y segunda declaración.
  r := app.sp_trabajo_realizado_declarar(tec,t,false,ot,
        'Se reemplazó el retén y se montó el eje rectificado.', now() - interval '1 day',
        (SELECT id FROM core.catalogo_item WHERE tipo='resultado_trabajo' AND codigo='RESUELTO'));
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'trabajo realizado v1 falló: %', r; END IF;

  r := app.sp_trabajo_revisar(coord,t,false,ot,'correccion_solicitada',
        'Falta registrar la alineación del acoplamiento y la prueba de funcionamiento.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'revisión falló: %', r; END IF;
  RAISE NOTICE '  11 · QA-14 ok · devuelta a EN TRABAJO con observación';

  r := app.sp_trabajo_realizado_declarar(tec,t,false,ot,
        'Retén reemplazado, eje rectificado montado, acoplamiento alineado a 0.05 mm y prueba de 2 horas sin fuga.',
        now(), (SELECT id FROM core.catalogo_item WHERE tipo='resultado_trabajo' AND codigo='RESUELTO'));
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'trabajo realizado v2 falló: %', r; END IF;

  r := app.sp_trabajo_revisar(coord,t,false,ot,'aprobado','Conforme.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'aprobación falló: %', r; END IF;

  r := app.sp_conformidad_registrar(solic,t,false,ot,'conforme','La bomba ya no pierde aceite.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'conformidad falló: %', r; END IF;

  -- Costos. Los registra el COORDINADOR: según el Anexo B, abastecimiento puede
  -- VER costos pero no registrarlos. Que el smoke lo respete es parte de la prueba.
  r := app.sp_costo_registrar(coord,t,false,ot,'RECTIFICADO DE EJE BOMBA 3',1200.00,
        'cotizacion','servicio',1,'servicio','PEN',cot_id);
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'costo falló: %', r; END IF;
  r := app.sp_costo_registrar(coord,t,false,ot,'RETEN 45X65X10 NBR',150.00,
        'cotizacion','repuesto',2,'unidad','PEN',cot_id);
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'costo 2 falló: %', r; END IF;

  -- Y se comprueba que abastecimiento efectivamente NO puede (Anexo B).
  r := app.sp_costo_registrar(abast,t,false,ot,'PRUEBA',1.00);
  IF (r->>'ok')::boolean THEN RAISE EXCEPTION 'Anexo B FALLÓ: abastecimiento registró un costo'; END IF;
  RAISE NOTICE '  11b · Anexo B ok · abastecimiento no puede registrar costos'; 

  -- Administrativo.
  r := app.sp_solped_preparar(abast,t,false,ot,
        '{"grupo_compra":"MTO","imputacion":"K","texto_breve":"Rectificado y reten bomba 3"}'::jsonb);
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'SOLPED falló: %', r; END IF;
  solped := (r->'data'->>'id')::uuid;

  r := app.sp_solped_marcar_lista(abast,t,false,solped);
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'SOLPED lista falló: %', r; END IF;

  r := app.sp_solped_registrar_numero_sap(abast,t,false,solped,'0010045678','Confirmado por Compras.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'número SAP falló: %', r; END IF;
  RAISE NOTICE '  12 · SOLPED preparada, marcada lista y con número SAP capturado a mano';

  -- Cerrar SIN OC todavía: debe exigir confirmación explícita (QA-19).
  r := app.sp_ot_cerrar(coord,t,false,ot,false,NULL);
  IF (r->>'ok')::boolean THEN RAISE EXCEPTION 'QA-19 FALLÓ: cerró sin confirmar el pendiente'; END IF;
  RAISE NOTICE '  13 · QA-19 ok · cierre bloqueado sin confirmación del pendiente administrativo';

  -- QA-16 · tampoco debe cerrar con la derivada bloqueante abierta.
  r := app.sp_ot_cerrar(coord,t,false,ot,true,'Falta la OC; Compras la emite esta semana.');
  IF (r->>'ok')::boolean THEN RAISE EXCEPTION 'QA-16 FALLÓ: cerró con derivada bloqueante abierta'; END IF;
  RAISE NOTICE '  14 · QA-16 ok · cierre bloqueado por derivada bloqueante abierta';

  -- Resolver la derivada bloqueante para poder cerrar el padre.
  PERFORM app.sp_ot_cambiar_estado(coord,t,false,hija,'en_diagnostico','Contexto confirmado');
  PERFORM app.sp_diagnostico_registrar(tec,t,false,hija,'Contactor quemado.','Sobrecarga.',
          'Reemplazo de contactor.','Desmontar y reemplazar.');
  PERFORM app.sp_ot_cambiar_estado(coord,t,false,hija,'en_cotizacion');
  PERFORM app.sp_cotizacion_cargar(abast,t,false,hija,NULL,'Electro Perú S.A.','20587654321',
          'COT-EP-991',current_date,780.00,'PEN',3);
  PERFORM app.sp_ejecucion_iniciar(coord,t,false,hija,tec,now() - interval '1 day');
  PERFORM app.sp_trabajo_realizado_declarar(tec,t,false,hija,'Contactor reemplazado y probado.',now());
  PERFORM app.sp_trabajo_revisar(coord,t,false,hija,'aprobado','Conforme.');
  r := app.sp_ot_cerrar(coord,t,false,hija,true,'Sin SOLPED: se pagó con caja chica. Pendiente regularizar.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'cierre de la derivada falló: %', r; END IF;
  RAISE NOTICE '  15 · derivada cerrada (la nieta no bloqueante sigue abierta)';

  -- Ahora sí: cerrar el padre con pendiente administrativo declarado.
  r := app.sp_ot_cerrar(coord,t,false,ot,true,
        'La OC aún no ha sido emitida por Compras. Se revisó el seguimiento y se dará seguimiento tras el cierre.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'cierre con pendiente falló: %', r; END IF;
  RAISE NOTICE '  16 · OT cerrada con indicador "%"', r->'data'->>'indicador';

  -- QA-20 · registrar la OC después del cierre NO reabre la OT.
  r := app.sp_orden_compra_registrar(abast,t,false,ot,'4500123456',current_date,2850.00,'PEN',
        'Emitida por Compras tras el cierre técnico.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'OC falló: %', r; END IF;
  IF (SELECT estado FROM core.orden_trabajo WHERE id=ot) <> 'cerrada' THEN
    RAISE EXCEPTION 'QA-20 FALLÓ: registrar la OC reabrió la OT';
  END IF;
  RAISE NOTICE '  17 · QA-20 ok · OC registrada tras el cierre y la OT sigue CERRADA';

  r := app.sp_liberacion_registrar(abast,t,false,ot,'parcial',1500.00,'Primera liberación parcial.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'liberación falló: %', r; END IF;

  -- QA-22 · reapertura con motivo, conservando el cierre anterior.
  r := app.sp_ot_reabrir(coord,t,false,ot,'La fuga reapareció a los tres días.','en_trabajo',
        (SELECT id FROM core.catalogo_item WHERE tipo='motivo_reapertura' AND codigo='FALLA_REINCIDENTE'));
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'reapertura falló: %', r; END IF;
  RAISE NOTICE '  18 · QA-22 ok · OT reabierta; el cierre anterior se conserva';

  PERFORM app.sp_avance_registrar(tec,t,false,ot,'Se detectó porosidad en la carcasa; se aplicó sellador.');
  PERFORM app.sp_trabajo_realizado_declarar(tec,t,false,ot,
    'Carcasa sellada y prueba de 8 horas sin fuga.',now());
  PERFORM app.sp_trabajo_revisar(coord,t,false,ot,'aprobado','Conforme, ahora sí.');
  r := app.sp_liberacion_registrar(abast,t,false,ot,'total',2850.00,'Liberación total.');
  r := app.sp_ot_cerrar(coord,t,false,ot,true,'Administración completa.');
  IF NOT (r->>'ok')::boolean THEN RAISE EXCEPTION 'cierre final falló: %', r; END IF;
  RAISE NOTICE '  19 · cierre final · indicador "%"', r->'data'->>'indicador';

  RAISE NOTICE '  ── ciclo completo ejecutado sin errores ──';
END $SMOKE$;
