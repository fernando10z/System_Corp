MIP
Maintenance Intelligence Platform
Especificacion Funcional Maestra - Nivel 3
Referencia principal para desarrollo, QA, producto e implementacion

| Documento | Valor |
| Nombre del producto | MIP - Maintenance Intelligence Platform (nombre comercial por definir) |
| Version | 1.0 |
| Estado | Especificacion funcional consolidada |
| Fecha | 2026-08-01 |
| Audiencia | Producto, desarrollo, QA, UX/UI, implementacion y administracion funcional |
| Alcance | MVP operativo de mantenimiento; SOLPED/SAP definidos como integracion pendiente de detalle |


| Proposito Este documento convierte las decisiones de negocio acordadas en una fuente de verdad funcional. No prescribe tecnologias, endpoints ni pantallas; define que debe hacer el producto, sus reglas, sus datos y las excepciones que un equipo de desarrollo debe respetar. |


# Control del documento

| Elemento | Definicion |
| Fuente de verdad | Este documento; toda variacion debe gestionarse como una decision de producto versionada. |
| Normativa | Las reglas marcadas como obligatorias prevalecen sobre interpretaciones de interfaz. |
| Pendientes | Se mantienen en el capitulo 22 y no deben asumirse como comportamiento implementado. |
| Terminologia | Se emplea OT para Orden de Trabajo y SOLPED para Solicitud de Pedido SAP. |


# Indice
1. Resumen ejecutivo
2. Objetivo, alcance y filosofia
3. Principios de diseno funcional
4. Actores, roles y permisos
5. Estructura organizacional y alcance
6. Mapa de modulos
7. Solicitudes de trabajo
8. Ordenes de trabajo
9. Diagnostico y planificacion tecnica
10. OT derivadas: jerarquia padre-hija
11. Cotizacion seleccionada
12. Ejecucion, avances e incidencias
13. Conversacion y comunicacion contextual
14. Trabajo realizado, cierre y reapertura
15. Seguimiento administrativo
16. Costos unitarios y aprendizaje continuo
17. Configuracion por cliente
18. Auditoria y trazabilidad
19. Notificaciones
20. Dashboards, KPIs y reportes
21. Modelo conceptual y logico
22. SOLPED, SAP y decisiones pendientes
Anexo A. Estados y transiciones
Anexo B. Matriz de permisos
Anexo C. Reglas de integridad
Anexo D. Glosario

# 1. Resumen ejecutivo
MIP (Maintenance Intelligence Platform) es una plataforma de gestion operativa de mantenimiento con inteligencia de costos e integracion prevista con SAP. No es un ERP ni busca reemplazar SAP; organiza el ciclo tecnico desde la solicitud de trabajo hasta el cierre de la OT y prepara la trazabilidad necesaria para el proceso administrativo de compras.
La propuesta central es convertir una necesidad de mantenimiento en un trabajo tecnico trazable, con una cotizacion seleccionada, seguimiento administrativo, evidencia, conversacion contextual e informacion reutilizable de costo. SAP conserva el control de los procesos administrativos y financieros; MIP es dueño de la operacion de mantenimiento.

| Decisiones de alcance del MVP No incluye gestion completa de activos, comparacion interna de proveedores, creacion de ordenes de compra, liberacion automatica, HES, facturacion, ni modificacion directa de documentos SAP ya creados. |


# 2. Objetivo, alcance y filosofia

## 2.1 Objetivo
Proporcionar una fuente unica para registrar, coordinar, ejecutar, cerrar y analizar trabajos de mantenimiento. El producto reduce la dependencia de correos, mensajes dispersos y transcripcion manual, sin imponer al solicitante conocimiento tecnico que no posee.

## 2.2 Alcance funcional del MVP
Solicitud simple de necesidades de mantenimiento.
Revision, aceptacion y conversion de una solicitud en OT.
Diagnosticos versionados por tecnico o coordinador.
OT principales y derivadas a multiples niveles.
Carga y versionado de cotizacion final seleccionada en PDF.
Ejecucion, avances, incidencias, pausas, evidencias, conversacion y cierre.
Seguimiento administrativo de SOLPED, OC y liberacion.
Costos unitarios basados en cotizaciones y OT cerradas.
Auditoria, notificaciones, dashboards y configuracion multiempresa.

## 2.3 Fuera de alcance actual
Catalogo completo y jerarquico de activos.
Comparacion o puntuacion de cotizaciones dentro de MIP.
Gestion de HES, recepcion de materiales, facturacion u ordenes de compra.
Lecturas de instrumentos como series de datos estructuradas.
IA de recomendacion, prediccion o trabajos similares; queda preparada como evolucion.
Campos exactos de SOLPED y mecanismo tecnico SAP por cliente.

## 2.4 Filosofia
El solicitante reporta una necesidad; no diagnostica.
La OT representa el ciclo tecnico; los procesos administrativos se siguen en una dimension independiente.
Una OT representa una intervencion tecnica ejecutable. Si el alcance se divide, se crean OT derivadas.
El sistema no borra historia operativa: versiona, cancela, invalida o reabre con motivo.
Todo lo que cambia por empresa debe ser configurable; el flujo operativo central es estandar.

# 3. Principios de diseno funcional

| Principio | Aplicacion |
| Simplicidad de captura | El solicitante informa titulo, descripcion, lugar, impacto, prioridad percibida y evidencias; no se le exige activo, CECOS ni diagnostico. |
| Separacion de responsabilidades | MIP opera mantenimiento; SAP administra documentos de compra y finanzas. |
| Trazabilidad por defecto | Cambios relevantes almacenan usuario, fecha, motivo, valores y evidencia. |
| Configuracion sin bifurcacion | Catalogos, permisos, motivos y parametros varian por cliente; el flujo base no. |
| Excepcion controlada | La emergencia cambia el orden administrativo, no elimina la regularizacion posterior. |
| Dato reutilizable | La OT cerrada alimenta costos unitarios y analitica, sin depender de un catalogo de activos. |


# 4. Actores, roles y permisos
El producto usa roles de negocio complementados por permisos configurables. Una persona puede tener mas de un rol si el cliente lo autoriza. El MVP no limita la cantidad de coordinadores de mantenimiento; el rol es unico, pero puede asignarse a varios usuarios.

| Rol | Responsabilidad principal | Limites base |
| Solicitante | Registrar necesidades, aportar evidencia, consultar sus casos y conversar. | No diagnostica, no crea OT, no ve costos ni datos SAP. |
| Tecnico | Apoyar el diagnostico, registrar avances y declarar trabajo realizado. | No cierra OT ni administra SOLPED por defecto. |
| Coordinador de mantenimiento | Dueño del ciclo tecnico: revisa solicitudes, crea y cierra OT, dirige diagnostico y ejecucion. | No modifica directamente documentos SAP ya creados. |
| Abastecimiento | Apoya carga de cotizacion, preparacion administrativa y seguimiento. | No modifica diagnosticos ni cierre tecnico por defecto. |
| Administrador | Gestiona usuarios, roles, catalogos, configuracion e integraciones. | No sustituye responsabilidades operativas salvo permiso expreso. |
| Gerencia/consulta | Consulta KPIs, dashboards y reportes. | Sin cambios operativos por defecto. |


## 4.1 Alcance de acceso
Los permisos se aplican junto con el alcance organizacional asignado: tenant, sucursal, empresa/RUC y area. Un usuario solo consulta o modifica informacion dentro de su alcance autorizado, salvo permisos administrativos globales.

# 5. Estructura organizacional y alcance
La estructura funcional se define como Sucursal -> Empresa/RUC -> Area. Una sucursal puede contener varias empresas o razones sociales. Un area o CECOS pertenece exclusivamente a una empresa/RUC; el mismo nombre de area puede existir bajo otra razon social como entidad distinta.

| Entidad | Regla |
| Tenant/Cliente | Aisla la informacion de cada organizacion usuaria de MIP. |
| Sucursal | Ubicacion operativa; puede asociarse a varias empresas/RUC. |
| Empresa/RUC | Entidad juridica a la que se imputa la OT y, posteriormente, la SOLPED. |
| Area | Contexto operativo afectado; se asocia a una empresa/RUC y puede ayudar a determinar CECOS. |
| CECOS | Catalogo o dato administrativo asociado a una RUC; su detalle SAP queda pendiente. |


| Decision de alcance MIP no exige activos en el MVP. La inteligencia de costos se contextualiza por tipo de trabajo, sucursal, empresa/RUC, area, proveedor, fecha y descripcion normalizada. |


# 6. Mapa de modulos

| Modulo | Responsabilidad |
| Identidad y acceso | Usuarios, sesiones, roles, permisos y alcances. |
| Organizacion | Sucursales, empresas/RUC, areas y catalogos base. |
| Solicitudes | Registro inicial, bandeja, decisiones y conversion a OT. |
| OT | Estados, responsables, prioridad, emergencia y jerarquia. |
| Diagnosticos | Versiones de diagnostico, causa probable, alcance y trabajo a realizar. |
| Ejecucion | Avances, incidencias, pausas, trabajo realizado y cierre tecnico. |
| Cotizacion | PDF seleccionado, datos basicos, versionado y relacion con OT. |
| Seguimiento administrativo | SOLPED, OC y liberacion manual. |
| Conversaciones y evidencias | Mensajes contextuales, adjuntos y documentos centralizados. |
| Costos unitarios | Historicos, normalizacion, variaciones y aprendizaje continuo. |
| Transversales | Auditoria, notificaciones, configuracion, dashboards y reportes. |
| Integraciones | Adaptadores desacoplados; SAP es el primer conector previsto. |


# 7. Solicitudes de trabajo

## 7.1 Proposito
La solicitud es la puerta de entrada y representa un reporte no tecnico. Su objetivo es comunicar una necesidad; el coordinador transforma esa necesidad en una OT con informacion tecnica.

## 7.2 Datos

| Dato | Regla |
| Titulo | Obligatorio; breve y comprensible. |
| Descripcion | Obligatoria; conserva literalmente el reporte inicial. |
| Lugar | Obligatorio; descripcion libre del sitio reportado. |
| Area solicitante | Obligatoria dentro del alcance del usuario. |
| Solicitante y fecha | Registrados automaticamente. |
| Prioridad percibida | Dato informativo; no sustituye prioridad tecnica. |
| Impacto operativo | Obligatorio; describe el efecto esperado o actual. |
| Evidencias | Fotos, videos, PDFs u otros documentos permitidos; opcionales salvo regla de cliente. |


## 7.3 Decisiones del coordinador
Aceptar y asumir o asignar la atencion: genera OT vinculada.
Observar: devuelve la solicitud al solicitante con comentario.
Rechazar: exige motivo y notifica al solicitante.
Derivar: registra destinatario y motivo.
Marcar duplicada: la relaciona con la solicitud principal sin crear otra OT.
Clasificar como emergencia durante la conversion a OT.
Una solicitud convertida en OT no vuelve a borrador. La solicitud original se conserva aun si la OT se cancela, para comparar reporte, diagnostico y resultado.

# 8. Ordenes de trabajo

## 8.1 Definicion
La OT es el contenedor del ciclo tecnico de una intervencion. Centraliza datos de origen, identificacion tecnica, diagnosticos, cotizacion, ejecucion, evidencias, comunicacion y seguimiento administrativo. No es una tabla unica: se relaciona con registros especializados.

## 8.2 Datos iniciales

| Bloque | Datos |
| Reporte original | Titulo, descripcion, lugar, solicitante, impacto, prioridad percibida y evidencias de la solicitud. |
| Identificacion tecnica | Sucursal, empresa/RUC, area, tipo de mantenimiento, tipo de trabajo, prioridad tecnica, coordinador y condicion de emergencia. |
| Control | Numero interno, estado, fechas de creacion/inicio/termino/cierre, padre directo si es derivada. |
| Administracion | Cotizacion vigente, SOLPED/OC/liberacion como seguimiento separado. |


## 8.3 Estados operativos

| Estado | Significado |
| CREADA | OT generada desde una solicitud aceptada; falta completar diagnostico. |
| EN DIAGNOSTICO | Tecnico o coordinador investiga y documenta el alcance. |
| EN COTIZACION | El trabajo esta definido y se gestiona externamente la cotizacion seleccionada. |
| EN TRABAJO | La ejecucion ha comenzado. |
| TRABAJO REALIZADO | Ejecutor declara termino; coordinador debe revisar. |
| CERRADA | Cierre tecnico aprobado; puede conservar pendientes administrativos. |
| CANCELADA | Intervencion no continuara; exige motivo y conserva historial. |


## 8.4 Prioridad y emergencia
La prioridad tecnica es definida por el coordinador y puede diferir de la prioridad percibida. La emergencia es una clasificacion adicional, no un tipo de mantenimiento: exige motivo, impacto y justificacion. Habilita iniciar trabajo sin cotizacion ni SOLPED previas, pero no elimina el deber de regularizacion.

# 9. Diagnostico y planificacion tecnica
El diagnostico puede ser registrado por tecnico autorizado o coordinador. El coordinador puede aprobarlo, complementarlo o reemplazarlo. Todo diagnostico se conserva para trazabilidad y el sistema identifica la version vigente.

| Campo | Regla |
| Diagnostico | Obligatorio para pasar a En Cotizacion. |
| Causa probable | Obligatoria; puede evolucionar tras inspeccion o desmontaje. |
| Alcance | Obligatorio; delimita la intervencion tecnica. |
| Trabajo a realizar | Obligatorio; plan de trabajo, no trabajo ya ejecutado. |
| Evidencias | Fotos, videos, documentos y observaciones libres. |
| Lecturas de instrumentos | Se permiten solo como texto/observacion; no se modelan unidades ni series medibles en el MVP. |
| Autor, fecha y version | Siempre obligatorios y automaticos al registrar. |


| Cambio de diagnostico Un cambio no sobrescribe la historia. Si revela una intervencion independiente, se crea una OT derivada. No toda modificacion de diagnostico exige crear una hija; la hija se usa para dividir trabajo, alcance, proveedor o contratacion. |


# 10. OT derivadas: jerarquia padre-hija
Una OT puede generar otras OT y estas, a su vez, nuevas derivadas. El modelo es recursivo: cada OT conoce a su padre directo. La jerarquia permite separar intervenciones tecnicas independientes por especialidad, alcance, proveedor o forma de contratacion.

| Regla | Comportamiento |
| Intervencion unica | Una OT debe representar una intervencion tecnica ejecutable. Si el trabajo se divide, se crean derivadas. |
| Autonomia | Cada derivada tiene estados, diagnosticos, cotizacion, ejecucion, conversacion y seguimiento administrativo propios. |
| Jerarquia | Se permiten varios niveles; se prohiben ciclos y una OT no puede ser padre de si misma. |
| Herencia | Sucursal, empresa/RUC y area se proponen desde la superior, pero pueden cambiar si el nuevo trabajo lo exige. |
| Cierre superior | La OT superior no cierra si tiene derivadas activas, salvo que una derivada se marque no bloqueante conforme a una regla y permiso configurados. |
| Cancelacion | Al cancelar una principal con hijas activas, el usuario decide: cancelar hijas, mantenerlas independientes o resolverlas antes. Cada cancelacion exige motivo. |

Ejemplo: una intervencion principal de reparacion integral puede generar una OT mecanica con proveedor A, una electrica con proveedor B y una de pintura con proveedor C. Esto evita mezclar costos, cotizaciones, estados y responsables no comparables en una sola OT.

# 11. Cotizacion seleccionada
MIP no compara proveedores ni calcula puntajes de adjudicacion en el MVP. Esa gestion se realiza fuera del sistema. MIP recibe y registra la cotizacion final seleccionada que respalda la intervencion.

| Regla | Detalle |
| Una vigente por OT | Cada OT tiene una sola cotizacion vigente; intervenciones con proveedores o alcances independientes deben modelarse como OT derivadas. |
| Formato | El documento soporte es PDF. La plataforma admite metadatos manuales del PDF. |
| Metadatos | Proveedor, RUC, numero de cotizacion, fecha, monto, moneda, plazo ofrecido, observaciones, usuario y fecha de carga. |
| Versionado | Una nueva cotizacion reemplaza logicamente la anterior; se conserva PDF, datos, usuario, fecha y motivo. |
| Origen de materiales/servicios | La informacion de materiales, repuestos y servicios proviene de la cotizacion seleccionada. El coordinador no mantiene una lista de compra formal previa en el MVP. |
| Inicio normal | La cotizacion vigente es requisito para pasar de En Cotizacion a En Trabajo, junto con responsable e inicio real. |
| Emergencia | Se puede iniciar sin cotizacion; esta queda pendiente de regularizacion. |


# 12. Ejecucion, avances e incidencias

## 12.1 Inicio
Para iniciar una OT normal: cotizacion vigente, responsable de ejecucion, fecha/hora real de inicio y confirmacion del coordinador. Para emergencia: clasificacion y justificacion de emergencia, responsable e inicio real. No se registra dias estimados en la OT; el plazo ofrecido pertenece a la cotizacion.

## 12.2 Registros durante la ejecucion
Avances narrativos con fecha, autor y evidencias. Los porcentajes no son obligatorios.
Incidencias: falta de acceso, retraso de proveedor, material incorrecto, riesgo de seguridad, interferencia u otro hecho que afecte el trabajo.
Pausas y reanudaciones con motivo, autor y marca temporal.
Cambios de alcance: se registran formalmente; si representan una intervencion separada, originan OT derivada.
Evidencias de ejecucion: fotos, videos, PDF u otros documentos autorizados.

## 12.3 Duracion
El sistema almacena fecha/hora de creacion, inicio real, termino real y cierre. La duracion se calcula en dias calendario; las pausas se conservan para analitica futura, sin requerir calculo de tiempo efectivo en el MVP.

# 13. Conversacion y comunicacion contextual
Cada OT cuenta con una conversacion contextual principalmente entre solicitante y coordinador. El tecnico puede leer o participar cuando el coordinador lo autorice. Abastecimiento u otros usuarios pueden incorporarse por autorizacion y permisos.

| Elemento | Regla |
| Mensajes | Texto, respuestas, adjuntos y notificaciones a participantes. |
| Eventos de sistema | La linea de tiempo muestra hitos como creacion, cambio de estado, carga de cotizacion y cierre, diferenciados de mensajes humanos. |
| Separacion formal | Un mensaje no reemplaza diagnostico, avance, incidencia ni trabajo realizado; un usuario autorizado debe registrarlo formalmente. |
| Edicion/retiro | Puede configurarse; toda edicion o retiro conserva marca de auditoria. |
| Cierre | La conversacion queda en modo lectura tras cerrar la OT, salvo reapertura o permiso excepcional. |
| Visibilidad | Solicitante no ve costos, RUC, CECOS, cotizaciones ni notas internas salvo regla expresa. |


# 14. Trabajo realizado, cierre y reapertura

## 14.1 Trabajo realizado
El ejecutor registra descripcion del trabajo realizado, resultado, fecha/hora de termino, responsable, evidencias finales y observaciones. La OT pasa a TRABAJO REALIZADO y queda disponible para revision del coordinador.

## 14.2 Revision
Aprobar: permite el cierre tecnico.
Solicitar correcciones: devuelve la OT a En Trabajo con observacion registrada.
Crear una derivada: cuando se descubre una nueva intervencion independiente, sin reescribir el trabajo concluido.
Conformidad del solicitante: es opcional; no bloquea el cierre, pero puede registrarse como conforme/no conforme con comentario.

## 14.3 Cierre
El cierre requiere trabajo realizado aprobado, evidencias finales cuando la empresa las exija, fecha de termino, revision del coordinador y tratamiento de OT derivadas bloqueantes. La cotizacion vigente y la SOLPED se revisan como parte de la validacion administrativa; OC y liberacion pueden continuar pendientes.

| Cierre con pendiente administrativo La OT puede quedar CERRADA aunque no exista OC o liberacion total, si el coordinador marca que reviso el seguimiento y deja constancia del pendiente. El estado administrativo continua visible, por ejemplo: 'CERRADA - OC PENDIENTE'. Actualizar OC/liberacion no reabre la OT. |


## 14.4 Reapertura
Reabrir exige permiso, motivo obligatorio, usuario, fecha/hora y estado de retorno. El cierre anterior nunca se elimina. Motivos tipicos: falla reincidente, trabajo incompleto, informacion incorrecta o evidencia faltante.

# 15. Seguimiento administrativo
El seguimiento administrativo es paralelo al estado operativo. Permite conservar trazabilidad desde la cotizacion hasta la SOLPED y, manualmente, OC y liberacion. No automatiza OC, HES, recepcion ni facturacion en el MVP.

| Bloque | Datos y comportamiento |
| SOLPED | Formulario interno, referencia externa, numero SAP cuando exista, estado, fecha, monto, moneda, cotizacion relacionada, mensajes de integracion e historial. |
| OC | Numero de orden de compra, fecha, observacion y usuario que lo registra manualmente. |
| Liberacion | Estado Pendiente/Parcial/Total, monto liberado editable, fecha, observacion e historial de cambios. |
| Indicador | Estado administrativo consolidado: sin SOLPED, SOLPED creada, OC pendiente, OC registrada, liberacion pendiente/parcial/total o administracion completa. |
| Cierre | No bloquea el cierre tecnico si el coordinador confirma revision y documenta pendientes. |


## 15.1 SOLPED manual posterior
Tras crear la SOLPED en SAP, MIP no modifica ni elimina el documento SAP. Si se corrige, anula o sustituye en SAP, el usuario actualiza en MIP el numero, el formulario interno o el estado mediante un flujo auditado. La interfaz puede ofrecer 'Eliminar SOLPED', pero internamente es una anulacion logica: el registro permanece con motivo y puede originar una nueva SOLPED.

# 16. Costos unitarios y aprendizaje continuo
El motor de costos es un componente de conocimiento. No sustituye contabilidad ni selecciona proveedores. Su objetivo es conservar precios y experiencias de intervenciones comparables para dar contexto al coordinador y alimentar analitica.

## 16.1 Fuentes de aprendizaje
Cotizacion seleccionada vigente: monto, moneda, proveedor, fecha, plazo, PDF y descripciones disponibles.
OT cerrada: tipo de trabajo, sucursal, empresa/RUC, area, emergencia, duracion real, diagnostico, trabajo realizado y resultado.
Regularizaciones administrativas: SOLPED, OC y liberacion como trazabilidad; no se asumen costos contables finales sin integracion definida.

## 16.2 Unidad de aprendizaje
El aprendizaje se organiza por tipo de trabajo y descripcion normalizada, no solo por OT. Esto evita que una OT de alcance mixto distorsione el historico. La regla de una intervencion por OT, apoyada por OT derivadas, es esencial para que el costo sea comparable.

| Dimension | Uso |
| Tipo de trabajo | Agrupacion principal. El sistema tendra catalogo base ampliable por empresa (filosofia B). |
| Descripcion normalizada | Permite agrupar denominaciones equivalentes de servicios, materiales o trabajos. |
| Contexto organizacional | Sucursal, empresa/RUC y area explican diferencias de precio e imputacion. |
| Proveedor | Permite ver recurrencia y costo historico sin ejecutar ranking automatico. |
| Tiempo | Fecha de cotizacion/OT para observar variaciones; duracion real para contexto operativo. |
| Moneda | Se conserva de origen. Conversiones, inflacion y homologacion se definen en una etapa posterior. |


## 16.3 Logica de costos unitarios
Capturar la cotizacion seleccionada y su PDF, preservando version y contexto.
Extraer o registrar descripciones de trabajo, materiales, repuestos y servicios. En el MVP la extraccion puede ser asistida/manual; OCR/IA se deja como evolucion.
Normalizar descripciones mediante catalogo, sinonimos y reglas de equivalencia aprobadas. No se destruye el texto original.
Registrar costo de origen, unidad cuando exista, cantidad cuando exista, moneda, fecha, proveedor y origen documental.
Vincular el registro a OT, tipo de trabajo, sucursal, RUC y area.
Al cerrar la OT, marcar el caso como experiencia operativa valida para historicos, conservando excepciones y alcance.
Calcular ultimo costo, promedio simple y variacion frente a referencias comparables. Los indicadores deben mostrar numero de casos y contexto, no una falsa precision.
Conservar valores atipicos y marcar su contexto; no se eliminan del historial. Una futura politica puede excluirlos de ciertos promedios con trazabilidad.

## 16.4 Salidas del MVP
Historico de costos por tipo de trabajo, descripcion, sucursal, empresa/RUC, area y proveedor.
Ultimo costo conocido, promedio, rango simple y variacion porcentual cuando existan casos comparables.
Consulta de trabajos/cotizaciones anteriores como referencia; no copia automaticamente diagnosticos ni adjudica proveedores.
Base preparada para IA, deteccion de anomalias, normalizacion automatica y recomendaciones futuras.

| Regla de calidad El motor debe diferenciar costo observado, costo cotizado y costo administrativo registrado. MIP no debe presentar un costo como contablemente final si solo dispone de una cotizacion o monto de liberacion. |


# 17. Configuracion por cliente
MIP es multiempresa. Los elementos que cambian entre clientes se configuran sin alterar el codigo ni bifurcar el flujo central.

| Configurable | No configurable en el MVP |
| Sucursales, empresas/RUC, areas y CECOS relacionados. | Secuencia base Solicitud -> OT -> Diagnostico -> Cotizacion -> Trabajo -> Cierre. |
| Usuarios, roles, permisos y alcances. | Estados operativos principales de la OT. |
| Prioridades, tipos de mantenimiento, tipos de trabajo, motivos y parametros. | Concepto de emergencia y su obligacion de regularizacion. |
| Preferencias y eventos de notificacion. | Relacion estructural entre OT y sus registros de trazabilidad. |
| Reglas de evidencia, conformidad, cierre y derivadas no bloqueantes. | Conservacion de auditoria, versionado y eliminacion logica. |


# 18. Auditoria y trazabilidad
La auditoria es transversal y automatica. El historial operativo muestra eventos comprensibles; la auditoria conserva el detalle tecnico y de control. Ninguna accion sensible depende solo de un comentario manual.

| Evento | Requisito de trazabilidad |
| Cambios de estado | Anterior, nuevo, usuario, fecha, motivo si aplica. |
| Diagnostico | Version, autor, fecha, vigente/reemplazado. |
| Cotizacion | Version anterior/nueva, motivo de reemplazo, usuario, documentos. |
| Emergencia | Clasificacion, justificacion, autor y fecha. |
| Cancelacion/reapertura | Motivo obligatorio, usuario, fecha y relacion jerarquica. |
| SOLPED/OC/liberacion | Numero, cambios, motivo, usuario, fecha y mensaje SAP cuando exista. |
| Usuarios/organizacion | No se eliminan con historia; se inactivan y mantienen referencias. |
| Configuracion y permisos | Valor anterior/nuevo, actor y fecha. |


## 18.1 Retencion y eliminacion
Las OT se cancelan, no se eliminan. Las cotizaciones se reemplazan, no se destruyen. Los usuarios con historia se inactivan. Una SOLPED confirmada no se elimina fisicamente; puede anularse logicamente en MIP luego de gestion manual en SAP. Archivos y mensajes retirados conservan evidencia de la accion conforme a politica de retencion del cliente.

# 19. Notificaciones
El MVP utiliza notificaciones dentro de la plataforma y correo electronico. La regla es notificar cuando el receptor necesita actuar, evitando mensajes por cada cambio menor.

| Evento | Destinatario base | Canal |
| Nueva solicitud | Coordinador/es dentro del alcance | Interno y correo configurable |
| Solicitud observada/rechazada/aceptada | Solicitante | Interno y correo configurable |
| OT asignada | Tecnico/responsable | Interno y correo configurable |
| Nuevo mensaje | Participantes autorizados | Interno y correo configurable |
| Trabajo realizado | Coordinador | Interno y correo configurable |
| OT cerrada | Solicitante | Interno y correo configurable |
| Cotizacion cargada | Coordinador | Interno |
| Error SAP futuro | Responsable administrativo y administrador | Interno y correo configurable |


# 20. Dashboards, KPIs y reportes

## 20.1 Dashboards

| Perfil | Contenido principal |
| Solicitante | Solicitudes propias, estado, OT asociadas, ultimas actualizaciones y conversaciones. |
| Coordinador | Bandeja accionable: solicitudes por revisar, OT por estado, emergencias, trabajos en curso, cierres y pendientes administrativos. |
| Gerencia | Tendencias, volumen, tiempos, emergencias, costos por sucursal/RUC/area y OT abiertas. |
| Administrador | Usuarios, configuracion, auditorias y salud futura de integraciones. |
| Abastecimiento | OT en cotizacion, cotizaciones cargadas, SOLPED y pendientes administrativos, segun permiso. |


## 20.2 KPIs iniciales
Solicitudes creadas, atendidas y observadas; tiempo de primera revision.
OT abiertas, cerradas, canceladas y por estado/prioridad/sucursal/RUC/area.
Tiempo promedio desde solicitud a cierre y tiempo por etapa.
Duracion de ejecucion en dias calendario.
Emergencias: cantidad, porcentaje y tiempo de resolucion.
Costo cotizado/historico disponible por OT, sucursal, RUC, area y tipo de trabajo; distinguir fuente del monto.
OT cerradas con OC pendiente, liberacion pendiente o liberacion parcial.

## 20.3 Filtros y exportacion
Reportes y dashboards deberan filtrar al menos por periodo, sucursal, empresa/RUC, area, estado, prioridad, emergencia, responsable y tipo de trabajo. Las exportaciones a PDF/Excel se implementan en una etapa posterior de reportes, respetando permisos y alcance.

# 21. Modelo conceptual y logico

## 21.1 Relaciones principales
Tenant -> Sucursal -> Empresa/RUC -> Area. Tenant -> Usuarios -> Roles/Permisos. Solicitud -> Decisiones/Evidencias -> 0..1 OT. OT -> N diagnosticos, N derivadas, N evidencias, N avances, N incidencias, N pausas, 1 canal de conversacion, N cotizaciones versionadas, N registros administrativos/SOLPED previstos y N eventos de estado/auditoria.

| Relacion | Cardinalidad | Regla |
| Solicitud - OT | 1 a 0..1 | Una solicitud aceptada genera una OT; no se convierte dos veces. |
| OT - OT derivada | 1 a N | Relacion recursiva por padre directo; se permiten multiples niveles sin ciclos. |
| OT - Diagnostico | 1 a N | Una version es vigente; las demas se conservan. |
| OT - Cotizacion | 1 a N | Una vigente por OT; las anteriores quedan reemplazadas. |
| OT - Ejecucion/Avance/Incidencia/Pausa | 1 a N | Registros especializados, auditables y con evidencia. |
| OT - Conversacion | 1 a 1 | Un canal por OT con N participantes y mensajes. |
| OT - SOLPED | 1 a N futuro | MVP muestra una principal/vigente, pero la estructura soporta varias. |
| Empresa/RUC - Area | 1 a N | Un area pertenece a una sola RUC; puede repetirse por nombre bajo otra. |
| Usuario - Rol | N a N | Un usuario puede tener varios roles; permisos afinan capacidades. |


## 21.2 Entidades logicas

| Entidad | Responsabilidad/atributos esenciales |
| tenant | Aislamiento de cliente. |
| branch, legal_entity, area | Estructura organizacional y alcance. |
| user, role, permission, user_scope | Identidad, capacidades y visibilidad. |
| work_request, request_decision | Reporte inicial y decisiones del coordinador. |
| work_order, work_order_status_history | Nucleo operativo, estado y padre directo. |
| diagnosis | Versiones de diagnostico y plan de trabajo. |
| quotation, supplier | Cotizacion PDF/versiones y proveedor. |
| execution, progress_update, incident, pause | Ejecucion, avances, incidencias y tiempo. |
| work_completion | Declaracion formal de trabajo realizado y revision. |
| conversation, message, participant | Comunicacion contextual y eventos de sistema. |
| attachment | Archivos centralizados con origen, version y estado. |
| administrative_tracking, purchase_requisition, purchase_order, release_history | Seguimiento administrativo desacoplado. |
| unit_cost_record, work_type | Conocimiento economico y catalogo de clasificacion. |
| notification, audit_log, tenant_configuration | Servicios transversales. |


## 21.3 Restricciones de integridad
Todo registro relevante debe contener tenant_id; nunca se mezclan datos de clientes.
Una OT no puede ser su propia ancestro ni crear ciclos de derivacion.
Una OT cerrada solo cambia mediante reapertura auditada.
Una cotizacion reemplazada conserva sus datos y archivo; exactamente una version puede estar vigente por OT.
La fecha de termino no puede ser anterior al inicio; el cierre no puede anteceder al termino.
Monto de liberacion no puede ser negativo; toda modificacion conserva historial.
Usuarios y organizaciones con historia se inactivan, no se eliminan fisicamente.
Si se inactiva una RUC con OT abiertas, se bloquea su uso en nuevas OT y se genera alerta de gestion; las OT existentes se conservan.

# 22. SOLPED, SAP y decisiones pendientes

## 22.1 Decision de integracion
MIP es dueño de solicitudes, OT, diagnosticos, ejecucion, evidencias, conversaciones y costos operativos. SAP es dueño de SOLPED, compras, liberaciones, recepciones, facturacion, maestros y contabilidad. La integracion debe ser desacoplada para permitir futuros conectores sin alterar el nucleo operativo.

## 22.2 Logica ya acordada
MIP tendra un boton 'Crear SOLPED' desde la OT. Al presionarlo, se prepara y envia la solicitud cuando el modulo este definido e integrado.
SAP debe devolver el numero oficial asignado a la SOLPED; MIP lo almacena como referencia no editable sin flujo auditado.
Si no se presiona el boton o no se completa la integracion, la OT puede continuar y cerrarse dejando constancia del pendiente administrativo.
MIP no modifica ni elimina documentos SAP ya creados. Correcciones, cambios o anulaciones SAP son manuales.
En MIP se podra corregir el numero asociado, corregir/versionar el formulario, anular logicamente el registro y crear una nueva SOLPED. Todo conserva motivo e historia.
La estructura soportara multiples SOLPED por OT en el futuro; el MVP presenta una SOLPED principal/vigente.

## 22.3 Estados de integracion previstos

| Estado | Significado |
| BORRADOR | Formulario interno en preparacion. |
| LISTA PARA ENVIAR | Validaciones internas superadas. |
| ENVIANDO A SAP | Solicitud transmitida al conector. |
| CONFIRMACION PENDIENTE | No se conoce con certeza si SAP creo el documento; se consulta por referencia externa para evitar duplicados. |
| CREADA EN SAP | Numero SAP confirmado y almacenado. |
| ERROR SAP | SAP rechazo o el conector fallo; se conservan mensaje e intento. |
| REEMPLAZADA/ANULADA | Registro MIP invalidado logicamente luego de gestion manual en SAP. |


## 22.4 Pendientes obligatorios antes de implementar
Campos exactos de SOLPED y origen de cada campo: OT, cotizacion, configuracion SAP o usuario.
Version de SAP por cliente (ECC/S4HANA), APIs disponibles, seguridad, conectividad y autorizaciones.
Tipos de documento, imputaciones, CECOS, grupos/organizaciones de compra, campos obligatorios y desarrollos Z del cliente.
Regla final de una o varias SOLPED operativas en interfaz y relacion con OT derivadas.
Formato de adjuntos/referencias de cotizacion enviados a SAP.
Politica de reintentos, idempotencia, mensajes amigables y monitoreo del conector.
Reglas exactas de normalizacion, OCR/IA y conversion monetaria para costos unitarios.
Catalogo base de tipos de trabajo y gobierno de sinonimos/equivalencias.
Politica de retencion de archivos, limites de carga y requerimientos de seguridad empresarial.

# Anexo A. Estados y transiciones

| Desde | Hacia | Condiciones |
| CREADA | EN DIAGNOSTICO | Coordinador, sucursal, RUC, area, prioridad tecnica y tipo de mantenimiento definidos. |
| EN DIAGNOSTICO | EN COTIZACION | Diagnostico vigente, causa probable, alcance y trabajo a realizar. |
| EN COTIZACION | EN TRABAJO | Flujo normal: cotizacion vigente, responsable, inicio real y confirmacion coordinador. |
| EN DIAGNOSTICO | EN TRABAJO | Solo emergencia: clasificacion y justificacion, responsable e inicio real. |
| EN TRABAJO | TRABAJO REALIZADO | Trabajo realizado, resultado, termino real, responsable y evidencias requeridas. |
| TRABAJO REALIZADO | EN TRABAJO | Coordinador solicita correcciones; observacion obligatoria. |
| TRABAJO REALIZADO | CERRADA | Revision aprobada, derivadas bloqueantes resueltas y seguimiento administrativo revisado. |
| EN COTIZACION | EN DIAGNOSTICO | Cambio de alcance o diagnostico; registrar motivo. |
| EN TRABAJO | EN DIAGNOSTICO | Hallazgo que requiere replanteamiento; registrar motivo. |
| CERRADA | EN TRABAJO/EN DIAGNOSTICO | Reapertura con permiso y motivo. |
| Varios | CANCELADA | Motivo obligatorio; resolver derivadas activas conforme a regla. |


# Anexo B. Matriz base de permisos

| Accion | Solicitante | Tecnico | Coordinador | Abastecimiento | Admin | Gerencia |
| Crear solicitud | Si | Si* | Si | No | Si | No |
| Revisar/decidir solicitud | No | No | Si | No | Si* | No |
| Crear/editar OT | No | No | Si | No | Si* | No |
| Registrar diagnostico | No | Si | Si | No | Si* | No |
| Crear derivada | No | No | Si | No | Si* | No |
| Cargar cotizacion | No | No | Si | Si | Si* | No |
| Iniciar/registrar avances | No | Si* | Si | No | Si* | No |
| Declarar trabajo realizado | No | Si | Si | No | Si* | No |
| Cerrar/reabrir OT | No | No | Si | No | Si* | No |
| Conversar en OT | Si | Autorizado | Si | Autorizado | Si* | No |
| Registrar OC/liberacion | No | No | Si | Si | Si* | No |
| Ver costos | No | No | Si | Si* | Si | Si |
| Configurar tenant | No | No | No | No | Si | No |

* El permiso puede habilitarse o restringirse por configuracion del cliente. La matriz es una base funcional, no una sustitucion de la politica de seguridad de cada organizacion.

# Anexo C. Reglas de integridad y casos especiales
Si un usuario con historial deja la empresa, se inactiva; sus OT, mensajes, diagnosticos y auditoria mantienen la autoria original.
Si una empresa/RUC se inactiva con OT abiertas, se conserva en datos, se impide usarla en nuevas OT y se gestiona la correccion con administracion/sistemas del cliente.
Al reemplazar una cotizacion se conserva quien la reemplazo, fecha, motivo, PDF y datos de todas las versiones.
Al cancelar una OT principal con derivadas activas, el usuario debe cancelar cada derivada, mantenerla independiente o resolverla antes; la relacion se conserva.
La OT puede cerrar con OC/liberacion pendientes solo tras confirmacion explicita y observacion del coordinador.
La reapertura siempre exige motivo y conserva el cierre previo.
Una derivada puede generar nuevas derivadas; el sistema valida que no existan ciclos.
Una SOLPED confirmada puede corregirse en el registro MIP o anularse logicamente, pero MIP no modifica SAP de forma directa despues de la creacion.

# Anexo D. Glosario

| Termino | Definicion |
| Area | Unidad operativa dentro de una empresa/RUC afectada por la solicitud u OT. |
| CECOS | Centro de costo; dato administrativo asociado a una empresa/RUC, pendiente de detalle SAP. |
| Cotizacion vigente | PDF seleccionado que respalda una intervencion; solo una por OT en el MVP. |
| Emergencia | Clasificacion que permite iniciar trabajo sin cotizacion/SOLPED previa, con regularizacion posterior. |
| MIP | Maintenance Intelligence Platform; nombre provisional del producto. |
| OC | Orden de compra; se registra manualmente como seguimiento en el MVP. |
| OT | Orden de Trabajo; unidad de intervencion tecnica trazable. |
| OT derivada | OT creada desde otra OT para separar una intervencion independiente; tambien llamada hija. |
| RUC | Identificador tributario de la empresa/razon social a la que se asocia la OT. |
| SOLPED | Solicitud de Pedido en SAP. MIP preve su creacion y registra su numero oficial. |
| Tenant | Cliente u organizacion que utiliza MIP; limite de aislamiento de datos. |
| Tipo de trabajo | Clasificacion de la intervencion que soporta historicos y costos unitarios. |


# PARTE II - ESPECIFICACION DETALLADA PARA IMPLEMENTACION
Esta ampliacion convierte la logica consolidada en una especificacion funcional operable. Debe leerse junto con la Parte I. Si existe conflicto, prevalece la decision mas reciente documentada en esta Parte II o, si no existe, la regla de la Parte I.

| Uso por el equipo Producto usa este contenido para validar alcance; desarrollo para modelar comportamiento; QA para preparar pruebas; UX/UI para traducir reglas en interfaces. Las decisiones pendientes no deben convertirse en supuestos de implementacion. |


# 23. Convenciones de implementacion funcional

| Etiqueta | Significado para desarrollo |
| Obligatorio | La accion no puede completarse si falta el dato o la condicion indicada. |
| Configurable | El administrador funcional puede habilitar, restringir o parametrizar la regla por tenant. |
| Futuro | El modelo debe permitirlo o conservar datos; no forma parte necesariamente de la primera interfaz. |
| Auditado | Debe generar evento con actor, instante, valores y motivo cuando aplique. |
| No bloqueante | No impide el avance/cierre operativo, pero debe quedar visible y gestionable. |
| Pendiente SAP | No implementar comportamiento especifico hasta conocer el entorno y las reglas del cliente. |


## 23.1 Reglas transversales
Toda fecha y hora se guarda con zona horaria y se muestra en la zona configurada del tenant.
Todos los textos libres preservan su version original; una correccion no elimina el contenido anterior cuando afecta un registro formal.
Los cambios de estado se ejecutan por comandos funcionales, nunca por edicion libre del campo estado.
Las acciones deben validar tenant, rol, permiso y alcance organizacional antes de devolver datos o modificar registros.
Los adjuntos se relacionan con una entidad, una etapa y un autor; no deben quedar como archivos sin contexto.
Los mensajes y eventos de sistema comparten una linea de tiempo, pero tienen tipos distintos.

# 24. Especificacion detallada de solicitudes de trabajo

## 24.1 Caso de uso ST-01: crear solicitud

| Elemento | Especificacion |
| Actor principal | Solicitante; tecnico o coordinador tambien pueden crear si tienen permiso. |
| Precondiciones | Usuario activo, autenticado y con area dentro de su alcance. |
| Entrada | Titulo, descripcion, lugar, area solicitante, impacto operativo y prioridad percibida; evidencias opcionales. |
| Resultado | Solicitud ENVIADA, identificador interno, registro de auditoria y notificacion a coordinadores aplicables. |
| No solicitar | Activo, codigo de equipo, CECOS, diagnostico, causa, proveedor ni costo. |
| Errores | Area fuera de alcance, campos obligatorios vacios, archivo no permitido o usuario inactivo. |
| Criterios de aceptacion | El solicitante puede ver su solicitud inmediatamente; el coordinador ve el reporte original sin que se altere por la futura OT. |


## 24.2 Estados y acciones

| Estado | Acciones permitidas | Salida esperada |
| BORRADOR | Editar, adjuntar, enviar, descartar. | No notifica ni crea OT. |
| ENVIADA | Coordinador revisa; solicitante puede aportar informacion si se habilita. | Pasa a EN REVISION al ser tomada. |
| EN REVISION | Aceptar, observar, rechazar, derivar, marcar duplicada. | Registra decision formal. |
| OBSERVADA | Solicitante responde/corrige y reenvia. | Mantiene comentario de observacion. |
| ACEPTADA | Solo evento intermedio de conversion. | Se crea OT y queda CONVERTIDA EN OT. |
| RECHAZADA | Lectura y conversacion segun politica. | Motivo obligatorio y notificacion. |
| DERIVADA | Nuevo coordinador toma la revision. | Conserva origen, destino y motivo. |
| DUPLICADA | Consulta de relacion con solicitud principal. | No crea nueva OT. |
| CONVERTIDA EN OT | Lectura; referencia directa a OT. | Inmutable como origen. |


## 24.3 Validaciones de calidad
Titulo entre 5 y 180 caracteres configurables; no sustituye la descripcion.
Descripcion no puede contener solo espacios o caracteres repetidos.
Lugar es una referencia libre porque el solicitante puede no conocer la ubicacion tecnica.
Impacto operativo usa catalogo configurable con opcion 'Otro' y comentario.
La prioridad percibida es informativa; solo el coordinador fija prioridad tecnica.
La deteccion de duplicados puede ser una sugerencia futura; el sistema no une solicitudes automaticamente.

## 24.4 Caso de uso ST-02: decidir solicitud
El coordinador abre la solicitud y revisa reporte, evidencias, comentarios y solicitudes relacionadas.
Elige aceptar, observar, rechazar, derivar o marcar duplicada.
Si acepta, completa los datos minimos de la OT: sucursal, empresa/RUC, area, tipo de mantenimiento, prioridad tecnica, responsable y clasificacion normal/emergencia.
El sistema crea OT en estado CREADA, registra la vinculacion y conserva el reporte original.
El sistema notifica al solicitante que la necesidad fue aceptada y muestra el numero de OT cuando su permiso lo permita.

# 25. Especificacion detallada de ordenes de trabajo

## 25.1 Datos de la OT

| Grupo | Campo | Regla funcional |
| Identidad | Numero OT | Generado por MIP; unico dentro del tenant; no se reutiliza. |
| Origen | Solicitud de origen | Obligatoria para OT nacida de solicitud; derivadas referencian padre y pueden no tener solicitud propia. |
| Organizacion | Sucursal, RUC, area | Obligatorios desde la entrada a diagnostico; cada area corresponde a una RUC. |
| Clasificacion | Tipo de mantenimiento | Catalogo configurable; emergencia es bandera adicional. |
| Clasificacion | Tipo de trabajo | Seleccion del catalogo base/ampliable; puede quedar pendiente hasta diagnostico segun configuracion. |
| Prioridad | Prioridad tecnica | Definida por coordinador; independiente de la percibida. |
| Responsables | Coordinador y ejecutor | Coordinador obligatorio; ejecutor es requisito de inicio. |
| Fechas | Creacion, inicio, termino, cierre | Todas auditadas; duracion en dias calendario. |
| Jerarquia | OT padre | Nulo para principal; apunta al padre directo para derivadas. |
| Estado | Operativo y administrativo | Son dimensiones separadas. |


## 25.2 Caso de uso OT-01: pasar a diagnostico
Al crear la OT, el coordinador confirma el contexto tecnico y activa el diagnostico. La transicion de CREADA a EN DIAGNOSTICO es valida solo si la OT tiene responsable coordinador, sucursal, empresa/RUC, area, prioridad tecnica y tipo de mantenimiento. El activo no es requisito del MVP.

## 25.3 Caso de uso OT-02: cancelar

| Paso | Comportamiento |
| 1. Solicitar cancelacion | Usuario autorizado inicia accion desde un estado permitido. |
| 2. Validar jerarquia | Si tiene derivadas activas, se muestran y se exige elegir tratamiento. |
| 3. Registrar motivo | Motivo de catalogo y observacion libre obligatoria. |
| 4. Resolver descendientes | Cancelar cada una, independizarla o impedir la accion hasta resolverla, segun eleccion y permiso. |
| 5. Confirmar | Estado CANCELADA, auditoria, notificaciones pertinentes y conservacion de todos los registros. |


## 25.4 Caso de uso OT-03: cambio de prioridad
Solo coordinador o permiso equivalente puede cambiar prioridad tecnica. Si baja una prioridad critica/alta o se cambia estando En Trabajo, el sistema exige motivo. El cambio no altera la prioridad percibida original y debe aparecer en historial operativo y auditoria.

# 26. Diagnostico: casos, versiones y reglas

## 26.1 Caso de uso DG-01: registrar diagnostico

| Elemento | Regla |
| Actor | Tecnico autorizado o coordinador. |
| Campos | Diagnostico, causa probable, alcance, trabajo a realizar; observaciones y evidencias segun necesidad. |
| Estado de OT | Solo CREADA/EN DIAGNOSTICO, salvo reapertura o permiso especial. |
| Version | Cada guardado formal crea version; la ultima aprobada/vigente se identifica explicitamente. |
| Aprobacion | El coordinador puede aprobar, complementar o sustituir el diagnostico de un tecnico. |
| Resultado | La OT puede pasar a En Cotizacion si existe diagnostico vigente completo. |


## 26.2 Escenarios alternos

| Escenario | Tratamiento |
| Diagnostico inicial incorrecto | Registrar nueva version; mantener las anteriores y el motivo del cambio. |
| Hallazgo de trabajo independiente | Crear OT derivada; no ampliar silenciosamente la OT original. |
| No se puede diagnosticar por falta de acceso | Registrar incidencia u observacion; OT queda En Diagnostico. |
| Trabajo de inspeccion sin falla | El diagnostico puede indicar 'sin hallazgo'; el coordinador decide cancelar, cerrar por no intervencion o crear nueva OT si corresponde. |
| Lectura de instrumento | Registrar como observacion y/o adjunto; no convertirla en medicion estructurada en el MVP. |


## 26.3 Criterios de aceptacion
El sistema permite distinguir claramente el texto del solicitante, el diagnostico inicial y el diagnostico vigente.
Un usuario no puede editar el texto de un diagnostico historico para cambiar su contenido sin generar nueva version.
La OT no puede entrar a En Cotizacion si falta alguno de los cuatro campos tecnicos obligatorios.
Las evidencias de diagnostico son consultables desde el diagnostico y desde la linea de tiempo de OT.

# 27. OT derivadas y division del alcance

## 27.1 Regla de decision
Se crea una OT derivada cuando el trabajo deja de ser una intervencion unica y requiere control independiente por especialidad, proveedor, alcance, responsable, cotizacion, contrato, secuencia o costo. No se crea una derivada solo para guardar una nota adicional.

| Situacion | Accion recomendada |
| Mismo trabajo, proveedor adicional sin independencia real | Mantener en la OT si el alcance, cierre y cotizacion siguen siendo unicos. |
| Mecanica y electricidad con proveedores distintos | Crear derivadas; cada una tiene cotizacion y seguimiento propios. |
| Trabajo adicional descubierto durante ejecucion | Crear derivada si requiere nuevo alcance o cotizacion; registrar incidencia en la superior. |
| Cambio menor dentro del mismo alcance | Registrar avance/incidencia o nueva version de diagnostico; no derivar. |
| Una derivada descubre otra intervencion | Permitir nueva derivada de segundo nivel; validar ausencia de ciclos. |


## 27.2 Herencia y desvinculacion
La nueva derivada propone sucursal, RUC, area, prioridad y coordinador desde el padre; el coordinador confirma o modifica antes de iniciar.
La derivada conserva referencia al padre, motivo de derivacion y usuario que la creo.
Una derivada puede permanecer activa aunque la principal sea cancelada solo si el usuario lo decide expresamente y la auditoria lo registra.
Una derivada no bloqueante se define por permiso y motivo; se muestra en el cierre del padre como pendiente no bloqueante.

## 27.3 Consolidacion
La OT principal puede mostrar resumen de descendientes: cantidad por estado, costos observados, cotizaciones vigentes, SOLPED/OC/liberacion y bloqueos de cierre. La consolidacion es informativa; no fusiona los estados ni reescribe los historicos de las derivadas.

# 28. Cotizacion seleccionada: especificacion y validaciones

## 28.1 Caso de uso CT-01: cargar cotizacion
Coordinador o abastecimiento autorizado selecciona la OT que se encuentra En Cotizacion o regularizacion de emergencia.
Adjunta el PDF de la cotizacion final seleccionada.
Registra o confirma proveedor, RUC, numero de cotizacion, fecha, monto, moneda, plazo ofrecido y observacion.
El sistema valida el archivo y los campos requeridos por tenant.
La cotizacion queda vigente, se registra en auditoria y notifica al coordinador si fue cargada por abastecimiento.
La OT normal queda habilitada para iniciar trabajo; el inicio aun requiere confirmacion explicita.

## 28.2 Reemplazo
Reemplazar una cotizacion no borra la anterior. La accion exige motivo y crea nueva version. La version anterior conserva PDF, metadatos, usuario, fecha y su referencia a cualquier formulario/SOLPED que hubiese usado. Si ya se genero una SOLPED, el reemplazo debe advertir que el formulario o SAP no se modifican automaticamente.

## 28.3 Archivos y limites funcionales

| Tipo | Limite MVP propuesto | Validacion |
| PDF de cotizacion | Hasta 25 MB por archivo. | Extension, tipo MIME, lectura basica y analisis antivirus por infraestructura. |
| Fotografia | Hasta 10 MB por archivo. | JPG, JPEG, PNG, WEBP; eliminar metadatos sensibles si politica lo exige. |
| Video | Hasta 100 MB por archivo. | MP4, MOV o WEBM; reproduccion depende de almacenamiento/cliente. |
| Documento general | Hasta 25 MB por archivo. | PDF, DOCX, XLSX, TXT segun politica configurada. |
| Total por OT | 500 MB inicialmente. | Advertir antes de superar; limite final configurable por tenant. |


| Limites Son limites funcionales de partida, sujetos a capacidad contratada, seguridad y politica de retencion. La arquitectura debe permitir configurarlos sin alterar la logica de OT. |


# 29. Ejecucion, pausas, incidencias y termino

## 29.1 Inicio normal y emergencia

| Flujo | Requisitos para En Trabajo | Pendientes permitidos |
| Normal | Cotizacion vigente, responsable de ejecucion, inicio real y confirmacion del coordinador. | OC/liberacion pueden no existir; SOLPED puede quedar pendiente segun decision de coordinador. |
| Emergencia | Bandera emergencia, justificacion, responsable e inicio real. | Cotizacion y SOLPED pueden no existir; se marca regularizacion pendiente. |


## 29.2 Caso de uso EJ-01: registrar avance
Un avance es una declaracion narrativa del progreso, no un porcentaje obligatorio. Contiene descripcion, autor, fecha/hora y adjuntos opcionales. No cambia el estado de OT por si mismo. La interfaz debe permitir diferenciar avances de comentarios de conversacion y de incidencias.

## 29.3 Caso de uso EJ-02: pausa y reanudacion

| Accion | Datos obligatorios | Efecto |
| Pausar | Motivo, fecha/hora y actor. | La OT sigue En Trabajo con condicion Pausada; alerta de seguimiento opcional. |
| Reanudar | Fecha/hora y actor; observacion opcional. | Cierra la pausa vigente y devuelve condicion Activa. |
| Nueva pausa | No permitida si existe pausa vigente. | Evita intervalos ambiguos. |
| Terminar trabajo | No permitida si existe pausa vigente sin resolver. | Solicita reanudar o registrar motivo de termino desde pausa, segun politica. |


## 29.4 Caso de uso EJ-03: declarar trabajo realizado
Ejecutor registra descripcion final, resultado, fecha/hora de termino, observaciones y evidencias requeridas.
El sistema valida que no haya pausa activa y que el termino no preceda al inicio.
La OT cambia a TRABAJO REALIZADO y notifica al coordinador.
El coordinador revisa: aprueba para cierre, solicita correccion o genera derivada por hallazgo independiente.

# 30. Conversacion, visibilidad y eventos

## 30.1 Participacion

| Participante | Acceso base |
| Solicitante | Lee y escribe en la conversacion de su OT; no ve informacion interna restringida. |
| Coordinador | Lee, escribe, invita participantes, resuelve visibilidad y publica comunicaciones operativas. |
| Tecnico | Puede leer/escribir cuando el coordinador lo autoriza o la configuracion lo habilita. |
| Abastecimiento | Participa solo cuando se le incorpora o un permiso lo habilita; sus notas pueden marcarse internas. |
| Sistema | Publica eventos no editables de estado, documentos y acciones relevantes. |


## 30.2 Reglas
Los mensajes humanos nunca cambian el estado operativo ni sustituyen registros formales.
Las menciones notifican solo a usuarios con permiso de ver la OT.
Los adjuntos de mensajes heredan la visibilidad del canal o de la nota interna.
La edicion deja marca 'editado' y conserva auditoria con contenido anterior cuando la politica lo exige.
El retiro de un mensaje es logico; no se elimina el rastro de que existio.
Al cerrar OT, la conversacion pasa a solo lectura; reapertura o permiso especial habilita nuevos mensajes.

# 31. Seguimiento administrativo y cierre con pendientes

## 31.1 Estado administrativo consolidado

| Estado | Definicion | Accion esperada |
| SIN SOLPED | No existe registro de SOLPED vigente. | Crear SOLPED o documentar pendiente. |
| SOLPED PENDIENTE | Existe formulario o intencion, pero no numero SAP confirmado. | Completar o regularizar. |
| SOLPED CREADA | Numero SAP confirmado y asociado. | Seguimiento de OC/liberacion si aplica. |
| OC PENDIENTE | SOLPED existe; no se registro numero OC. | Actualizar manualmente cuando Compras informe. |
| OC REGISTRADA | Numero OC guardado. | Registrar liberacion conforme avance. |
| LIBERACION PENDIENTE/PARCIAL/TOTAL | Estado manual y monto liberado historizado. | Completar seguimiento; no altera cierre tecnico. |
| ADMINISTRACION COMPLETA | Criterios de tenant cumplidos. | Sin pendiente administrativo relevante. |


## 31.2 Caso de uso AD-01: cerrar con pendiente
Coordinador solicita cerrar OT desde TRABAJO REALIZADO aprobado.
El sistema muestra SOLPED, OC, liberacion, monto liberado y pendientes actuales.
Si falta OC o liberacion, solicita confirmacion: 'He revisado el seguimiento administrativo'.
El coordinador ingresa observacion obligatoria que explica el pendiente.
La OT pasa a CERRADA; el indicador administrativo se mantiene visible en listas, tablero y ficha.
Posteriores cambios de OC/liberacion actualizan seguimiento, no reabren OT.

## 31.3 Liberacion
La liberacion permite Pendiente, Parcial o Total. El monto liberado es editable porque no hay integracion automatica en este alcance. Cada cambio guarda valor anterior, nuevo valor, usuario, fecha y observacion. El sistema no debe inferir que el monto liberado equivale al costo final de OT.

# 32. Motor de costos unitarios: especificacion ampliada

## 32.1 Objetivo operativo
El motor consolida evidencia economica reutilizable de trabajos y cotizaciones. Debe ayudar a entender cuanto se cotizo o pago/registro administrativamente por intervenciones comparables, sin adjudicar proveedores ni reemplazar la revision humana. Su salida debe declarar el origen y calidad de cada dato.

## 32.2 Registro de costo unitario

| Campo | Descripcion y regla |
| Origen | OT, cotizacion, documento administrativo o carga validada; no existen registros sin procedencia. |
| Texto original | Descripcion exacta capturada del PDF/formulario; inmutable. |
| Descripcion normalizada | Etiqueta estandarizada por regla/catalogo; versionada y reversible. |
| Tipo de trabajo | Clasificacion del caso; catalogo base ampliable por tenant. |
| Concepto | Material, repuesto, servicio o trabajo integral, cuando pueda identificarse. |
| Cantidad/unidad | Se guardan solo si el documento los permite; ausencia no impide registrar costo total. |
| Monto y moneda | Valor original; no se sobreescribe por conversion futura. |
| Costo unitario | Monto/cantidad solo si cantidad es positiva y unidad compatible; si no, se conserva costo total. |
| Contexto | Sucursal, RUC, area, proveedor, fecha, emergencia, OT derivada/principal. |
| Calidad | Fuente, confianza, completitud, estado de validacion y excepcion/outlier si aplica. |


## 32.3 Normalizacion y aprendizaje
Conservar documento y texto original.
Registrar manualmente o extraer los conceptos con asistencia futura de OCR/IA.
Aplicar reglas de normalizacion: mayusculas/minusculas, espacios, unidades y sinonimos aprobados.
Relacionar con tipo de trabajo y contexto organizacional.
Evitar fusion automatica de conceptos ambiguos; enviar a revision/catalogo cuando la confianza sea baja.
Al cerrar OT, calificar si el caso es comparable o si su alcance mixto/extraordinario requiere marca de excepcion.
Calcular referencias con criterios visibles: numero de casos, periodo, moneda, filtros y registros excluidos por politica.

## 32.4 Metricas y prevencion de interpretaciones erroneas

| Metrica | Regla de presentacion |
| Ultimo costo | Mostrar fecha, proveedor, fuente y moneda original. |
| Promedio | Mostrar cantidad de casos y filtros usados; no usar si la muestra no cumple umbral configurable. |
| Rango | Presentar minimo/maximo o percentiles solo con suficientes casos y valores comparables. |
| Variacion | Comparar contra referencia explicita (ultimo, promedio o rango) e indicar formula. |
| Outlier | Marcar por regla configurable; no borrar. Debe poder consultarse con su justificacion. |
| Costo de OT | Separar cotizado, liberado y contable/final si alguna vez se integra. Nunca mezclarlos sin etiqueta. |


## 32.5 Criterios de aceptacion
Un usuario puede rastrear cualquier indicador de costo hasta OT, cotizacion, documento y fecha de origen.
La normalizacion no elimina el texto original ni altera el PDF.
El motor no recomienda proveedor ni aprueba cotizaciones en el MVP.
Los historicos pueden filtrarse por sucursal, RUC, area, tipo de trabajo, proveedor, periodo y moneda.
Una OT derivada alimenta su propio historial y puede consultarse con el contexto de su jerarquia.

# 33. Auditoria: especificacion de eventos

| Dominio | Evento minimo | Datos requeridos |
| Solicitud | Creada, enviada, observada, aceptada, rechazada, derivada, duplicada. | Actor, fecha, estado anterior/nuevo, motivo/comentario. |
| OT | Creada, cambio de estado, prioridad, emergencia, cancelada, reabierta. | Actor, fecha, valores anteriores/nuevos, motivo si sensible. |
| Diagnostico | Creado, aprobado, reemplazado. | Autor, version, referencias y motivo de sustitucion. |
| Cotizacion | Cargada, reemplazada, invalidada. | Version, proveedor/RUC, archivo, actor, motivo. |
| Ejecucion | Inicio, avance, incidencia, pausa, reanudacion, termino. | Actor, fecha, contenido y adjuntos. |
| Administracion | SOLPED, OC, liberacion, correcciones/anulaciones logicas. | Valores anteriores/nuevos, actor, motivo, respuesta SAP cuando exista. |
| Seguridad | Roles, permisos, alcances, configuracion y accesos administrativos. | Actor, sujeto, cambio y contexto tecnico. |

La auditoria completa es de consulta restringida. El historial operativo puede resumir los mismos hechos en lenguaje de negocio. Exportar auditoria requiere permiso y debe respetar el alcance organizacional.

# 34. Notificaciones y SLA operativo

## 34.1 Reglas de entrega
Toda notificacion tiene destinatario, evento, entidad relacionada, fecha, estado leida/no leida y canal.
Correo es una copia de la notificacion interna, no la fuente de verdad.
Los fallos de entrega de correo no revierten la operacion de negocio; se registran para soporte.
Cada usuario puede ajustar preferencias permitidas; eventos criticos pueden ser obligatorios por tenant.
No se notifica por modificaciones menores que no requieran accion.

## 34.2 SLA de revision propuesto

| Prioridad percibida/técnica | Tiempo maximo de primera revision | Uso |
| Critica | 15 minutos | Indicador y alerta; configurable. |
| Alta | 1 hora | Indicador y alerta; configurable. |
| Media | 8 horas | Indicador y alerta; configurable. |
| Baja | 24 horas | Indicador y alerta; configurable. |

Los SLA son objetivos de atencion y no estimaciones de ejecucion. El tablero debe permitir medir incumplimientos sin cerrar automaticamente solicitudes u OT.

# 35. Dashboards, reportes y criterios de datos

## 35.1 Tablero operativo del coordinador

| Bloque | Contenido | Accion que habilita |
| Solicitudes nuevas | Pendientes de primera revision, ordenadas por prioridad, impacto y antiguedad. | Abrir, tomar, decidir o derivar. |
| Diagnostico | OT creadas/en diagnostico sin diagnostico vigente completo. | Completar o asignar tecnico. |
| Cotizacion | OT en cotizacion sin PDF vigente o con plazo vencido. | Cargar/actualizar cotizacion. |
| Ejecucion | OT en trabajo, pausadas, sin avance y emergencias activas. | Registrar avance, incidencia o cierre. |
| Revision final | Trabajo realizado pendiente de coordinador. | Aprobar, devolver o derivar. |
| Administracion | OT cerradas con OC/liberacion pendiente. | Registrar seguimiento sin reabrir. |


## 35.2 Definiciones KPI

| KPI | Formula/definicion | Notas |
| Tiempo de primera revision | Fecha de primera decision - fecha de envio de solicitud. | Mostrar dias/horas calendario y excluir borradores. |
| Tiempo por etapa | Suma de permanencia entre cambios de estado. | Usar historial de estados; marcar estados reabiertos. |
| Duracion de ejecucion | Termino real - inicio real. | Dias calendario; pausas se reportan por separado. |
| Tasa de emergencia | OT emergencia / OT creadas en periodo. | Filtrable por organizacion. |
| Cierre con pendiente admin | OT cerradas con estado admin distinto de completo. | No implica incumplimiento tecnico. |
| Costo promedio observado | Promedio de registros comparables seleccionados. | Mostrar fuente, moneda, casos y filtros. |


# 36. Diccionario logico de entidades

| Entidad | Proposito |
| tenant | Cliente MIP; limite de aislamiento. |
| branch | Sucursal operativa. |
| legal_entity | Empresa/razon social con RUC. |
| area | Area perteneciente a una RUC. |
| user | Persona autenticable; puede inactivarse. |
| role/permission/user_scope | Capacidades y alcance de datos. |
| work_request | Solicitud original no tecnica. |
| request_decision | Decisiones sobre solicitud con motivo. |
| work_order | Intervencion tecnica; referencia padre opcional. |
| work_order_status_history | Cambios de estado con actor y motivo. |
| diagnosis | Versiones de diagnostico y plan tecnico. |
| supplier | Proveedor identificado por RUC y razon social. |
| quotation | Cotizacion versionada y metadatos; una vigente. |
| attachment | Archivo con origen, autor, tipo y estado. |
| execution/progress_update/incident/pause | Registros de trabajo en campo. |
| work_completion | Declaracion de termino y revision. |
| conversation/participant/message | Comunicacion y eventos contextualizados. |
| administrative_tracking | Resumen administrativo de OT. |
| purchase_requisition | SOLPED interna/SAP, con versiones y estados. |
| purchase_order/release_history | Seguimiento manual de OC y liberacion. |
| work_type/unit_cost_record | Catalogo y conocimiento economico. |
| notification/audit_log | Servicios transversales. |
| tenant_configuration | Parametros y catalogos de cada cliente. |


## 36.1 Campos de control comunes
Las entidades operativas deben incluir, cuando aplique: identificador interno, tenant_id, created_at, created_by, updated_at, updated_by, estado logico, version o referencia de version, y datos de auditoria. Los identificadores tecnicos no sustituyen los numeros de negocio como OT o SOLPED SAP.

# 37. Criterios de prueba y aceptacion del MVP

| ID | Escenario | Resultado esperado |
| QA-01 | Solicitud simple | Solicitante crea solicitud sin activo; coordinador la recibe. |
| QA-02 | Observacion | Solicitud observada no crea OT y el solicitante recibe comentario. |
| QA-03 | Conversion | Aceptar solicitud genera una sola OT vinculada y conserva el texto original. |
| QA-04 | Prioridad | Prioridad tecnica cambia sin alterar prioridad percibida. |
| QA-05 | Diagnostico tecnico | Tecnico crea diagnostico; coordinador lo aprueba y se conserva version. |
| QA-06 | Cambio de diagnostico | Nueva version mantiene la anterior y explica motivo. |
| QA-07 | Transicion cotizacion | No se permite En Cotizacion sin diagnostico completo. |
| QA-08 | Cotizacion PDF | Carga valida PDF y metadatos requeridos; habilita inicio normal. |
| QA-09 | Reemplazo cotizacion | Nueva version no elimina PDF anterior y exige motivo. |
| QA-10 | Inicio normal | No inicia sin responsable e inicio real. |
| QA-11 | Inicio emergencia | Permite iniciar sin PDF/SOLPED, con justificacion obligatoria. |
| QA-12 | Pausa | No permite dos pausas activas a la vez. |
| QA-13 | Trabajo realizado | No permite terminar antes de iniciar o con pausa activa. |
| QA-14 | Correccion | Coordinador devuelve TRABAJO REALIZADO a En Trabajo con observacion. |
| QA-15 | Derivada | Crear hija hereda contexto y no permite ciclo. |
| QA-16 | Jerarquia | OT padre no cierra con hija bloqueante abierta. |
| QA-17 | Cancelacion | Cancelacion con hijas exige decision y motivo. |
| QA-18 | Conversacion | Solicitante no ve cotizacion/costos internos. |
| QA-19 | Cierre pendiente | OT cierra con OC pendiente solo tras confirmacion y observacion. |
| QA-20 | Actualizacion OC | Registrar OC despues del cierre no reabre OT. |
| QA-21 | Liberacion parcial | Cambio de monto deja historial anterior/nuevo. |
| QA-22 | Reapertura | Exige permiso y motivo; conserva cierre anterior. |
| QA-23 | Inactivacion usuario | Historial conserva autor inactivo. |
| QA-24 | RUC inactiva | No se permite nueva OT bajo RUC inactiva; las existentes persisten. |
| QA-25 | Aislamiento | Usuario de otro tenant no puede consultar la OT por identificador. |
| QA-26 | Costo unitario | Registro conserva texto original, normalizado, origen y moneda. |
| QA-27 | Historico costo | Promedio muestra numero de casos y filtros. |
| QA-28 | SOLPED pendiente | OT puede cerrar con SOLPED pendiente si coordinador deja constancia. |
| QA-29 | SOLPED SAP | Respuesta confirmada almacena numero SAP y no permite borrado fisico. |
| QA-30 | Anulacion logica | SOLPED invalidada conserva motivo y permite nueva SOLPED. |


# 38. Decisiones pendientes y ruta de definicion

| Tema | Por que esta pendiente | Decision requerida antes de desarrollo |
| Formulario SOLPED | Cada cliente SAP usa campos, tipos, imputaciones y validaciones propias. | Mapa de campos, responsable de revision, datos obligatorios, adjuntos y multiples SOLPED. |
| Conector SAP | Depende de ECC/S4, APIs, seguridad, red y autorizaciones. | Tecnologia de integracion, idempotencia, manejo de errores, observabilidad y pruebas. |
| Catalogo tipo de trabajo | Debe reflejar operaciones del mercado y permitir gobierno por tenant. | Catalogo base, permisos para alta/baja, sinonimos y versionado. |
| OCR/IA | Afecta calidad, costo y privacidad documental. | Nivel de automatizacion, aprobacion humana, modelos, indicadores de confianza. |
| Moneda/actualizacion monetaria | No debe inventarse conversion historica. | Fuentes de tipo de cambio, politica de inflacion y moneda base por tenant. |
| Activos | Fuera de alcance para evitar construir un EAM completo. | Decidir si se integra catalogo SAP o se incorpora modulo futuro. |
| OC/liberacion/HES | MVP solo registra seguimiento manual. | Alcance de automatizacion y fuentes SAP futuras. |
| Retencion/documentos | Depende de regulacion, costo y seguridad cliente. | Tiempo de retencion, residencia de datos, antivirus y borrado legal. |


| Criterio de gobernanza Una decision pendiente no debe resolverse con un supuesto de desarrollador. Debe registrarse como decision de producto, indicar alcance, responsable, fecha y efecto sobre datos, interfaces, pruebas e integraciones. |

