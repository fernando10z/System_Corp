-- =============================================================================
-- 89_seeds.sql · Datos base
--
-- Idempotente: ON CONFLICT DO NOTHING en todo. Correrlo dos veces no duplica nada.
--
-- Va NUMERADO ANTES de 90_grants a propósito: las semillas deben crearse como
-- owner de la base. En el proyecto hermano esto quedó como 99_seeds y obligaba a
-- documentar una excepción al orden alfanumérico; aquí el orden natural del
-- directorio ya es el orden correcto.
--
-- La matriz de permisos que se siembra es LITERALMENTE el Anexo B. Los permisos
-- marcados con asterisco en el documento ("puede habilitarse o restringirse por
-- configuración del cliente") se siembran en su valor base y se ajustan después
-- con app.sp_rol_asignar_permisos.
-- =============================================================================
SET search_path = core, internal, public;

-- ── Permisos ─────────────────────────────────────────────────────────────────
INSERT INTO core.permiso (codigo, modulo, accion, descripcion) VALUES
  ('solicitudes:crear',            'solicitudes','crear',            'Registrar una solicitud de trabajo'),
  ('solicitudes:listar',           'solicitudes','listar',           'Consultar solicitudes dentro del alcance'),
  ('solicitudes:decidir',          'solicitudes','decidir',          'Revisar y decidir sobre una solicitud'),
  ('ot:crear',                     'ot','crear',                     'Convertir una solicitud en OT'),
  ('ot:editar',                    'ot','editar',                    'Editar el contexto técnico de una OT'),
  ('ot:listar',                    'ot','listar',                    'Consultar el listado de OT'),
  ('ot:ver',                       'ot','ver',                       'Ver la ficha y la trazabilidad de una OT'),
  ('ot:cambiar_estado',            'ot','cambiar_estado',            'Ejecutar transiciones de estado de la OT'),
  ('ot:cambiar_prioridad',         'ot','cambiar_prioridad',         'Cambiar la prioridad técnica'),
  ('ot:derivar',                   'ot','derivar',                   'Crear OT derivadas'),
  ('ot:cancelar',                  'ot','cancelar',                  'Cancelar una OT'),
  ('ot:revisar',                   'ot','revisar',                   'Revisar el trabajo realizado'),
  ('ot:cerrar',                    'ot','cerrar',                    'Cerrar técnicamente una OT'),
  ('ot:reabrir',                   'ot','reabrir',                   'Reabrir una OT cerrada'),
  ('diagnosticos:registrar',       'diagnosticos','registrar',       'Registrar o versionar un diagnóstico'),
  ('diagnosticos:aprobar',         'diagnosticos','aprobar',         'Aprobar el diagnóstico vigente'),
  ('cotizaciones:cargar',          'cotizaciones','cargar',          'Cargar o reemplazar la cotización seleccionada'),
  ('cotizaciones:ver',             'cotizaciones','ver',             'Ver cotizaciones de la OT'),
  ('ejecucion:iniciar',            'ejecucion','iniciar',            'Iniciar la ejecución de una OT'),
  ('ejecucion:avanzar',            'ejecucion','avanzar',            'Registrar avances e incidencias'),
  ('ejecucion:pausar',             'ejecucion','pausar',             'Pausar y reanudar la ejecución'),
  ('ejecucion:declarar_trabajo',   'ejecucion','declarar_trabajo',   'Declarar el trabajo realizado'),
  ('administrativo:ver',           'administrativo','ver',           'Ver el seguimiento administrativo'),
  ('administrativo:solped',        'administrativo','solped',        'Preparar, enviar y regularizar SOLPED'),
  ('administrativo:oc',            'administrativo','oc',            'Registrar órdenes de compra'),
  ('administrativo:liberacion',    'administrativo','liberacion',    'Registrar liberaciones'),
  ('conversacion:escribir',        'conversacion','escribir',        'Participar en la conversación de la OT'),
  ('conversacion:invitar',         'conversacion','invitar',         'Incorporar participantes a la conversación'),
  ('adjuntos:cargar',              'adjuntos','cargar',              'Adjuntar evidencias y documentos'),
  ('adjuntos:retirar',             'adjuntos','retirar',             'Retirar lógicamente un adjunto'),
  ('costos:ver',                   'costos','ver',                   'Consultar costos e históricos'),
  ('costos:registrar',             'costos','registrar',             'Registrar y calificar costos unitarios'),
  ('reportes:ver',                 'reportes','ver',                 'Consultar dashboards y reportes'),
  ('auditoria:ver',                'auditoria','ver',                'Consultar la auditoría técnica'),
  ('usuarios:listar',              'usuarios','listar',              'Consultar usuarios'),
  ('usuarios:crear',               'usuarios','crear',               'Crear usuarios'),
  ('usuarios:editar',              'usuarios','editar',              'Editar o inactivar usuarios'),
  ('roles:listar',                 'roles','listar',                 'Consultar roles y permisos'),
  ('roles:editar',                 'roles','editar',                 'Asignar permisos a roles'),
  ('organizacion:crear',           'organizacion','crear',           'Crear sucursales, empresas/RUC y áreas'),
  ('organizacion:editar',          'organizacion','editar',          'Editar o inactivar la organización'),
  ('catalogos:crear',              'catalogos','crear',              'Crear ítems de catálogo y tipos de trabajo'),
  ('proveedores:crear',            'proveedores','crear',            'Registrar proveedores'),
  ('configuracion:editar',         'configuracion','editar',         'Cambiar la configuración del tenant')
ON CONFLICT (codigo) DO NOTHING;

-- ── Roles base (cap. 4) ──────────────────────────────────────────────────────
INSERT INTO core.rol (tenant_id, codigo, nombre, descripcion, scope, es_sistema) VALUES
  (NULL,'solicitante',  'Solicitante',
   'Registra necesidades, aporta evidencia, consulta sus casos y conversa.','tenant',true),
  (NULL,'tecnico',      'Técnico',
   'Apoya el diagnóstico, registra avances y declara el trabajo realizado.','tenant',true),
  (NULL,'coordinador',  'Coordinador de mantenimiento',
   'Dueño del ciclo técnico: revisa solicitudes, crea y cierra OT, dirige diagnóstico y ejecución.','tenant',true),
  (NULL,'abastecimiento','Abastecimiento',
   'Apoya la carga de cotización, la preparación administrativa y el seguimiento.','tenant',true),
  (NULL,'administrador','Administrador',
   'Gestiona usuarios, roles, catálogos, configuración e integraciones.','tenant',true),
  (NULL,'gerencia',     'Gerencia / consulta',
   'Consulta KPIs, dashboards y reportes. Sin cambios operativos.','tenant',true),
  (NULL,'super_admin',  'Super administrador',
   'Administración de la plataforma MIP, por encima del tenant.','global',true)
ON CONFLICT (tenant_id, codigo) DO NOTHING;

-- ── Matriz del Anexo B ───────────────────────────────────────────────────────
-- Cada bloque es una fila de la matriz. Se lee igual que el documento.
DO $$
DECLARE
  r RECORD;
  v_map JSONB := jsonb_build_object(
    'solicitante', jsonb_build_array(
      'solicitudes:crear','solicitudes:listar','ot:ver','conversacion:escribir','adjuntos:cargar'),
    'tecnico', jsonb_build_array(
      'solicitudes:crear','solicitudes:listar','ot:listar','ot:ver',
      'diagnosticos:registrar','ejecucion:avanzar','ejecucion:pausar','ejecucion:declarar_trabajo',
      'conversacion:escribir','adjuntos:cargar','cotizaciones:ver'),
    'coordinador', jsonb_build_array(
      'solicitudes:crear','solicitudes:listar','solicitudes:decidir',
      'ot:crear','ot:editar','ot:listar','ot:ver','ot:cambiar_estado','ot:cambiar_prioridad',
      'ot:derivar','ot:cancelar','ot:revisar','ot:cerrar','ot:reabrir',
      'diagnosticos:registrar','diagnosticos:aprobar',
      'cotizaciones:cargar','cotizaciones:ver',
      'ejecucion:iniciar','ejecucion:avanzar','ejecucion:pausar','ejecucion:declarar_trabajo',
      'administrativo:ver','administrativo:solped','administrativo:oc','administrativo:liberacion',
      'conversacion:escribir','conversacion:invitar','adjuntos:cargar','adjuntos:retirar',
      'costos:ver','costos:registrar','reportes:ver'),
    'abastecimiento', jsonb_build_array(
      'ot:listar','ot:ver','cotizaciones:cargar','cotizaciones:ver',
      'administrativo:ver','administrativo:solped','administrativo:oc','administrativo:liberacion',
      'conversacion:escribir','adjuntos:cargar','costos:ver','reportes:ver'),
    'gerencia', jsonb_build_array(
      'ot:listar','ot:ver','cotizaciones:ver','administrativo:ver','costos:ver','reportes:ver'),
    'administrador', jsonb_build_array(
      'usuarios:listar','usuarios:crear','usuarios:editar','roles:listar','roles:editar',
      'organizacion:crear','organizacion:editar','catalogos:crear','proveedores:crear',
      'configuracion:editar','auditoria:ver','reportes:ver','costos:ver',
      'ot:listar','ot:ver','solicitudes:listar','administrativo:ver')
  );
  k TEXT; c TEXT;
BEGIN
  FOR k IN SELECT jsonb_object_keys(v_map) LOOP
    FOR c IN SELECT jsonb_array_elements_text(v_map->k) LOOP
      INSERT INTO core.rol_permiso (rol_id, permiso_id)
      SELECT ro.id, pe.id
        FROM core.rol ro, core.permiso pe
       WHERE ro.codigo = k AND ro.tenant_id IS NULL AND pe.codigo = c
      ON CONFLICT DO NOTHING;
    END LOOP;
  END LOOP;
END $$;

-- ── Catálogos base (tenant_id NULL = heredados por todos) ───────────────────
INSERT INTO core.catalogo_item (tenant_id, tipo, codigo, nombre, orden, requiere_comentario) VALUES
  -- Tipos de mantenimiento. La emergencia NO está aquí: es una bandera adicional,
  -- no un tipo de mantenimiento (cap. 8.4).
  (NULL,'tipo_mantenimiento','CORRECTIVO','Correctivo',1,false),
  (NULL,'tipo_mantenimiento','PREVENTIVO','Preventivo',2,false),
  (NULL,'tipo_mantenimiento','PREDICTIVO','Predictivo',3,false),
  (NULL,'tipo_mantenimiento','MEJORA','Mejora o modificación',4,false),
  (NULL,'tipo_mantenimiento','INSPECCION','Inspección',5,false),

  -- Impacto operativo, con 'Otro' exigiendo comentario (cap. 24.3).
  (NULL,'impacto_operativo','PARADA_TOTAL','Parada total de la operación',1,false),
  (NULL,'impacto_operativo','PARADA_PARCIAL','Parada parcial o producción reducida',2,false),
  (NULL,'impacto_operativo','RIESGO_SEGURIDAD','Riesgo de seguridad para personas',3,false),
  (NULL,'impacto_operativo','RIESGO_AMBIENTAL','Riesgo ambiental',4,false),
  (NULL,'impacto_operativo','CALIDAD','Afecta la calidad del producto o servicio',5,false),
  (NULL,'impacto_operativo','SIN_IMPACTO','Sin impacto inmediato',6,false),
  (NULL,'impacto_operativo','OTRO','Otro',99,true),

  (NULL,'motivo_cancelacion','DUPLICADA','Trabajo duplicado',1,false),
  (NULL,'motivo_cancelacion','NO_PROCEDE','No procede tras la evaluación técnica',2,false),
  (NULL,'motivo_cancelacion','RESUELTO','Se resolvió por otra vía',3,false),
  (NULL,'motivo_cancelacion','SIN_PRESUPUESTO','Sin presupuesto o postergado',4,false),
  (NULL,'motivo_cancelacion','ACTIVO_BAJA','El equipo salió de servicio',5,false),
  (NULL,'motivo_cancelacion','OTRO','Otro',99,true),

  (NULL,'motivo_reapertura','FALLA_REINCIDENTE','Falla reincidente',1,false),
  (NULL,'motivo_reapertura','TRABAJO_INCOMPLETO','Trabajo incompleto',2,false),
  (NULL,'motivo_reapertura','INFO_INCORRECTA','Información incorrecta',3,false),
  (NULL,'motivo_reapertura','EVIDENCIA_FALTANTE','Evidencia faltante',4,false),
  (NULL,'motivo_reapertura','OTRO','Otro',99,true),

  (NULL,'motivo_pausa','FALTA_ACCESO','Falta de acceso al equipo o zona',1,false),
  (NULL,'motivo_pausa','ESPERA_REPUESTO','Espera de repuesto o material',2,false),
  (NULL,'motivo_pausa','ESPERA_PROVEEDOR','Espera del proveedor',3,false),
  (NULL,'motivo_pausa','CONDICIONES','Condiciones climáticas u operativas',4,false),
  (NULL,'motivo_pausa','SEGURIDAD','Suspensión por seguridad',5,false),
  (NULL,'motivo_pausa','OTRO','Otro',99,true),

  -- Tipos de incidencia: los que el cap. 12.2 enumera explícitamente.
  (NULL,'tipo_incidencia','FALTA_ACCESO','Falta de acceso',1,false),
  (NULL,'tipo_incidencia','RETRASO_PROVEEDOR','Retraso de proveedor',2,false),
  (NULL,'tipo_incidencia','MATERIAL_INCORRECTO','Material incorrecto',3,false),
  (NULL,'tipo_incidencia','RIESGO_SEGURIDAD','Riesgo de seguridad',4,false),
  (NULL,'tipo_incidencia','INTERFERENCIA','Interferencia con otra operación',5,false),
  (NULL,'tipo_incidencia','OTRO','Otro',99,true),

  (NULL,'motivo_rechazo','NO_MANTENIMIENTO','No corresponde a mantenimiento',1,false),
  (NULL,'motivo_rechazo','DUPLICADA','Duplicada',2,false),
  (NULL,'motivo_rechazo','INFO_INSUFICIENTE','Información insuficiente',3,false),
  (NULL,'motivo_rechazo','FUERA_ALCANCE','Fuera del alcance del área',4,false),
  (NULL,'motivo_rechazo','OTRO','Otro',99,true),

  (NULL,'motivo_reemplazo_cotizacion','CAMBIO_ALCANCE','Cambio de alcance',1,false),
  (NULL,'motivo_reemplazo_cotizacion','MEJOR_OFERTA','Se seleccionó otra oferta',2,false),
  (NULL,'motivo_reemplazo_cotizacion','ERROR_DATOS','Corrección de datos',3,false),
  (NULL,'motivo_reemplazo_cotizacion','VENCIDA','Cotización vencida',4,false),
  (NULL,'motivo_reemplazo_cotizacion','OTRO','Otro',99,true),

  -- Cuándo derivar, según la regla de decisión del cap. 27.1.
  (NULL,'motivo_derivacion','ESPECIALIDAD','Especialidad técnica distinta',1,false),
  (NULL,'motivo_derivacion','PROVEEDOR','Proveedor distinto',2,false),
  (NULL,'motivo_derivacion','ALCANCE','Alcance independiente',3,false),
  (NULL,'motivo_derivacion','CONTRATACION','Forma de contratación distinta',4,false),
  (NULL,'motivo_derivacion','HALLAZGO','Hallazgo durante la ejecución',5,false),
  (NULL,'motivo_derivacion','OTRO','Otro',99,true),

  (NULL,'resultado_trabajo','RESUELTO','Resuelto',1,false),
  (NULL,'resultado_trabajo','RESUELTO_PARCIAL','Resuelto parcialmente',2,false),
  (NULL,'resultado_trabajo','SIN_HALLAZGO','Sin hallazgo',3,false),
  (NULL,'resultado_trabajo','REQUIERE_SEGUIMIENTO','Requiere seguimiento',4,false),
  (NULL,'resultado_trabajo','OTRO','Otro',99,true)
ON CONFLICT (tenant_id, tipo, codigo) DO NOTHING;

-- ── Catálogo base de tipos de trabajo (cap. 16.2, "filosofía B": base ampliable) ──
INSERT INTO core.tipo_trabajo (tenant_id, codigo, nombre, es_base) VALUES
  (NULL,'MEC_GENERAL',   'Mecánica general',                 true),
  (NULL,'MEC_SOLDADURA', 'Soldadura y estructuras',          true),
  (NULL,'MEC_BOMBAS',    'Bombas y sistemas hidráulicos',    true),
  (NULL,'MEC_RODAMIENTO','Rodamientos y transmisión',        true),
  (NULL,'ELE_GENERAL',   'Electricidad general',             true),
  (NULL,'ELE_MOTORES',   'Motores eléctricos',               true),
  (NULL,'ELE_TABLEROS',  'Tableros y control',               true),
  (NULL,'INSTRUMENT',    'Instrumentación',                  true),
  (NULL,'CLIMA',         'Climatización y refrigeración',    true),
  (NULL,'CIVIL',         'Obra civil y albañilería',         true),
  (NULL,'PINTURA',       'Pintura y recubrimientos',         true),
  (NULL,'SANITARIO',     'Sanitarias y gasfitería',          true),
  (NULL,'NEUMATICA',     'Neumática',                        true),
  (NULL,'LUBRICACION',   'Lubricación',                      true),
  (NULL,'LIMPIEZA_TEC',  'Limpieza técnica industrial',      true),
  (NULL,'TRANSPORTE',    'Transporte y montaje',             true),
  (NULL,'SERV_TERCERO',  'Servicio de tercero especializado',true)
ON CONFLICT (tenant_id, codigo) DO NOTHING;

-- ── Tenant de demostración ───────────────────────────────────────────────────
-- Sirve para arrancar el entorno y para el smoke test. En una instalación real
-- se crea el tenant del cliente y este se puede borrar.
DO $$
DECLARE
  v_tenant UUID; v_suc UUID; v_emp UUID; v_area UUID; v_area2 UUID; v_admin UUID;
BEGIN
  INSERT INTO core.tenant (codigo, nombre, zona_horaria, moneda_base)
  VALUES ('demo','Organización Demo MIP','America/Lima','PEN')
  ON CONFLICT (codigo) DO NOTHING;
  SELECT id INTO v_tenant FROM core.tenant WHERE codigo = 'demo';

  INSERT INTO core.sucursal (tenant_id, codigo, nombre, direccion)
  VALUES (v_tenant,'PLANTA-01','Planta principal','Av. Industrial 1000')
  ON CONFLICT (tenant_id, codigo) DO NOTHING;
  SELECT id INTO v_suc FROM core.sucursal WHERE tenant_id=v_tenant AND codigo='PLANTA-01';

  INSERT INTO core.empresa_ruc (tenant_id, ruc, razon_social, nombre_corto)
  VALUES (v_tenant,'20100000001','DEMO INDUSTRIAL S.A.C.','Demo Industrial')
  ON CONFLICT (tenant_id, ruc) DO NOTHING;
  SELECT id INTO v_emp FROM core.empresa_ruc WHERE tenant_id=v_tenant AND ruc='20100000001';

  INSERT INTO core.sucursal_empresa_ruc (tenant_id, sucursal_id, empresa_ruc_id)
  VALUES (v_tenant, v_suc, v_emp) ON CONFLICT DO NOTHING;

  INSERT INTO core.area (tenant_id, empresa_ruc_id, codigo, nombre) VALUES
    (v_tenant, v_emp, 'MANTTO','Mantenimiento'),
    (v_tenant, v_emp, 'PROD',  'Producción'),
    (v_tenant, v_emp, 'ALMAC', 'Almacén')
  ON CONFLICT (empresa_ruc_id, codigo) DO NOTHING;
  SELECT id INTO v_area  FROM core.area WHERE empresa_ruc_id=v_emp AND codigo='MANTTO';
  SELECT id INTO v_area2 FROM core.area WHERE empresa_ruc_id=v_emp AND codigo='PROD';

  INSERT INTO core.cecos (tenant_id, empresa_ruc_id, area_id, codigo, descripcion)
  VALUES (v_tenant, v_emp, v_area, 'CC-MANTTO','Centro de costo Mantenimiento')
  ON CONFLICT (empresa_ruc_id, codigo) DO NOTHING;

  -- Super admin de arranque. La contraseña se cambia en el primer acceso; queda
  -- documentada en README_ORDEN_EJECUCION.md.
  INSERT INTO core.usuario (tenant_id, email, password_hash, nombres, apellidos,
                            cargo, is_super_admin, estado)
  VALUES (v_tenant, 'admin@mip.local', crypt('CambiarEnDeploy2026', gen_salt('bf', 12)),
          'Administrador','MIP','Super administrador', true, 'activo')
  ON CONFLICT (email) DO NOTHING;
  SELECT id INTO v_admin FROM core.usuario WHERE email='admin@mip.local';

  INSERT INTO core.usuario_rol (usuario_id, rol_id)
  SELECT v_admin, r.id FROM core.rol r WHERE r.codigo='super_admin' AND r.tenant_id IS NULL
  ON CONFLICT DO NOTHING;

  -- Configuración por defecto, con los valores del documento.
  INSERT INTO core.tenant_configuracion (tenant_id, clave, valor, descripcion) VALUES
    (v_tenant,'limites_adjunto',
     '{"pdf":26214400,"imagen":10485760,"video":104857600,"documento":26214400,"total_ot":524288000}'::jsonb,
     'Límites de archivos en bytes (cap. 28.3): PDF y documento 25 MB, foto 10 MB, video 100 MB, 500 MB por OT.'),
    (v_tenant,'sla_primera_revision',
     '{"critica":15,"alta":60,"media":480,"baja":1440}'::jsonb,
     'Minutos máximos de primera revisión por prioridad (cap. 34.2). Son objetivos, no cierran nada.'),
    (v_tenant,'bloqueo_credenciales', '{"intentos":5,"minutos":15}'::jsonb,
     'Intentos fallidos consecutivos antes de bloquear la cuenta, y minutos de espera (OWASP A07).'),
    (v_tenant,'umbral_muestra_costos', '{"minimo":3}'::jsonb,
     'Mínimo de casos comparables para publicar un promedio (cap. 32.4).'),
    (v_tenant,'exige_evidencia_cierre', 'false'::jsonb,
     'Si el cierre exige evidencias finales (cap. 14.3).'),
    (v_tenant,'exige_conformidad', 'false'::jsonb,
     'La conformidad del solicitante es opcional y no bloquea el cierre (cap. 14.2).'),
    (v_tenant,'permite_derivada_no_bloqueante', 'true'::jsonb,
     'Permite marcar una derivada como no bloqueante para el cierre del padre (cap. 10).'),
    (v_tenant,'titulo_min_caracteres','5'::jsonb,'Longitud mínima del título de solicitud (cap. 24.3).'),
    (v_tenant,'titulo_max_caracteres','180'::jsonb,'Longitud máxima del título de solicitud (cap. 24.3).')
  ON CONFLICT (tenant_id, clave) DO NOTHING;
END $$;
