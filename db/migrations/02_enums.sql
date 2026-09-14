-- =============================================================================
-- 02_enums.sql
--
-- Todos los estados de MIP son ENUM nativo, nunca texto libre. Los valores salen
-- LITERALMENTE del documento funcional; no se inventa ninguno:
--   ot_estado                 cap. 8.3      solicitud_estado          cap. 24.2
--   estado_administrativo     cap. 31.1     solped_estado_integracion cap. 22.3
--   prioridad                 cap. 34.2     ot_condicion              cap. 29.3
--   concepto_costo            cap. 32.2
--
-- Lo que el spec marca como "catálogo configurable por tenant" (tipo de trabajo,
-- tipo de mantenimiento, motivos, impacto operativo) NO es enum: vive en
-- core.catalogo_item para poder ampliarse sin migración (cap. 17).
-- =============================================================================

DO $$ BEGIN
  CREATE TYPE core.ot_estado AS ENUM
    ('creada','en_diagnostico','en_cotizacion','en_trabajo','trabajo_realizado','cerrada','cancelada');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.ot_condicion AS ENUM ('activa','pausada');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.solicitud_estado AS ENUM
    ('borrador','enviada','en_revision','observada','aceptada','rechazada','derivada','duplicada','convertida_en_ot');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.tipo_decision_solicitud AS ENUM
    ('aceptar','observar','rechazar','derivar','marcar_duplicada','tomar_revision','reenviar');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.prioridad AS ENUM ('critica','alta','media','baja');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.estado_administrativo AS ENUM
    ('sin_solped','solped_pendiente','solped_creada','oc_pendiente','oc_registrada',
     'liberacion_pendiente','liberacion_parcial','liberacion_total','administracion_completa');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.solped_estado_integracion AS ENUM
    ('borrador','lista_para_enviar','enviando_a_sap','confirmacion_pendiente',
     'creada_en_sap','error_sap','reemplazada_anulada');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.estado_liberacion AS ENUM ('pendiente','parcial','total');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.concepto_costo AS ENUM ('material','repuesto','servicio','trabajo_integral');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.moneda_codigo AS ENUM ('PEN','USD','EUR');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.estado_registro AS ENUM ('activo','inactivo');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Los usuarios y organizaciones con historia se INACTIVAN, nunca se borran (cap. 18.1, Anexo C).
DO $$ BEGIN
  CREATE TYPE core.estado_usuario AS ENUM ('activo','inactivo','bloqueado');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Alcance del rol: quién ve qué más allá de su sucursal/RUC/área (cap. 4.1).
DO $$ BEGIN
  CREATE TYPE core.scope_rol AS ENUM ('tenant','global','global_restricted');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Resultado de la revisión del coordinador sobre el trabajo declarado (cap. 14.2).
DO $$ BEGIN
  CREATE TYPE core.resultado_revision AS ENUM ('aprobado','correccion_solicitada','derivada_creada');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Conformidad del solicitante: opcional, no bloquea el cierre (cap. 14.2).
DO $$ BEGIN
  CREATE TYPE core.conformidad_solicitante AS ENUM ('conforme','no_conforme','sin_pronunciarse');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- La línea de tiempo mezcla mensajes humanos y eventos de sistema, pero con tipos
-- distintos y visualmente diferenciados (cap. 13, 30.1).
DO $$ BEGIN
  CREATE TYPE core.tipo_mensaje AS ENUM ('humano','sistema');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.visibilidad_mensaje AS ENUM ('canal','interna');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.estado_mensaje AS ENUM ('publicado','editado','retirado');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Etapa del ciclo a la que pertenece un adjunto: nunca hay archivos sin contexto (regla 23.1).
DO $$ BEGIN
  CREATE TYPE core.etapa_adjunto AS ENUM
    ('solicitud','diagnostico','cotizacion','ejecucion','incidencia','trabajo_realizado',
     'cierre','administrativo','mensaje','otro');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.tipo_adjunto AS ENUM ('pdf','imagen','video','documento','otro');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.estado_adjunto AS ENUM ('vigente','reemplazado','retirado');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Dominios de auditoría del cap. 33.
DO $$ BEGIN
  CREATE TYPE core.dominio_evento AS ENUM
    ('solicitud','ot','diagnostico','cotizacion','ejecucion','administracion','seguridad','configuracion','costos');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.canal_notificacion AS ENUM ('interno','correo');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.estado_notificacion AS ENUM ('pendiente','enviada','leida','fallida');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Calidad del dato económico: el motor NUNCA debe presentar un cotizado como contable (cap. 32.4).
DO $$ BEGIN
  CREATE TYPE core.fuente_costo AS ENUM ('cotizacion','ot_cerrada','documento_administrativo','carga_validada');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE core.estado_validacion_costo AS ENUM ('sin_validar','validado','en_revision','excepcion');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Tipos de catálogo configurables por tenant (cap. 17). Un solo catálogo genérico
-- evita 8 tablas casi idénticas y permite altas sin migración.
DO $$ BEGIN
  CREATE TYPE core.tipo_catalogo AS ENUM
    ('tipo_mantenimiento','tipo_trabajo','impacto_operativo','motivo_cancelacion',
     'motivo_reapertura','motivo_pausa','tipo_incidencia','motivo_rechazo',
     'motivo_reemplazo_cotizacion','motivo_derivacion','resultado_trabajo');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
