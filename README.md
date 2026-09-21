# MIP · Maintenance Intelligence Platform

Plataforma de gestión operativa de mantenimiento con inteligencia de costos e
integración prevista con SAP.

**MIP no es un ERP y no busca reemplazar SAP.** Organiza el ciclo técnico desde
la solicitud de trabajo hasta el cierre de la Orden de Trabajo, y prepara la
trazabilidad que después consume el proceso administrativo de compras. SAP
conserva el control de SOLPED, compras, liberaciones y contabilidad; MIP es
dueño de la operación de mantenimiento.

La fuente de verdad funcional es [`MIP_SPEC.md`](MIP_SPEC.md) — la
Especificación Funcional Maestra Nivel 3 convertida a Markdown. Todo lo que hay
en este repositorio se justifica contra un capítulo de ese documento, y los
comentarios del código lo citan por número.

---

## La decisión que define el sistema

> **La OT es la tabla principal, y su última columna es el árbol de todo lo que
> esa OT generó.**

`core.orden_trabajo` tiene una columna `trazabilidad JSONB` que contiene, en un
solo documento navegable: la solicitud que la originó, sus diagnósticos
versionados, sus OT derivadas recursivas a cualquier profundidad, sus
cotizaciones, la ejecución con avances, incidencias y pausas, el trabajo
realizado, los cierres y reaperturas, el seguimiento administrativo completo
(SOLPED / OC / liberación), los adjuntos, la conversación, los costos y la
bitácora de eventos.

### Cómo se mantiene ese árbol

Tres piezas, cada una barata, con la función como única autoridad:

1. **`internal.fn_ot_trazabilidad()` es la autoridad.** Construye el árbol
   on-demand leyendo las tablas reales, que siguen siendo la fuente de verdad.
   El JSON es una proyección: nunca puede divergir de forma irrecuperable, y
   siempre se puede reconstruir desde cero.

2. **Los triggers sólo marcan, no reconstruyen.** Cada tabla hija tiene un
   trigger que hace una única cosa barata: poner `trazabilidad_dirty = true` en
   la OT afectada, en sus ancestros y en sus hijas directas. Reconstruir el árbol
   entero al insertar un mensaje de chat sería amplificación de escritura pura y
   una fuente de deadlocks. Marcar la bandera garantiza que ningún cambio se
   pierda, ni siquiera un `UPDATE` manual hecho por `psql`.

3. **`app.sp_ot_trazabilidad_refrescar()` recalcula y guarda.** Lo llaman los SP
   de negocio al terminar, y el camino de lectura de forma perezosa si encuentra
   la bandera levantada. En la práctica la columna está siempre fresca.

Además, `core.ot_evento` es una bitácora **append-only e inmutable** (sin
`UPDATE` ni `DELETE`, revocados y bloqueados por trigger) que se embebe en el
árbol como `eventos[]`.

`app.fn_trazabilidad_verificar()` compara el snapshot cacheado contra la función
autoritativa y avisa si alguno se desvió.

---

## Arquitectura

| Tema | Decisión |
|---|---|
| Lógica de negocio | **100 % en stored procedures de PostgreSQL** |
| Superficie del backend | Sólo el schema `app`. Ni un `SELECT` sobre una tabla |
| Organización del backend | Modular vertical: `controller + service + repository + dto/` |
| Multi-cliente | Columna `tenant_id` en todo, resuelta y validada dentro de los SP |
| Autenticación | JWT de acceso 15 min + refresh 7 d con whitelist en Redis por `jti` |
| Sobre de respuesta | `{ ok, data, error, meta }` de extremo a extremo |

```
System_Corp/
├── db/          PostgreSQL 16 · 22 migraciones, 43 tablas, 89 SP, 33 helpers
├── backend/     NestJS 10 + Fastify + TypeScript · 20 módulos
├── frontend/    Vue 3.5 + Vite · JavaScript plano, sin Pinia, sin framework UI
├── docs/        arquitectura, ADRs, base de datos, operaciones
├── infra/       docker (dev), nginx, pm2, scripts
└── MIP_SPEC.md  la especificación funcional, como fuente de verdad versionada
```

### Por qué toda la lógica vive en la base

El usuario PostgreSQL del backend (`mip_app_user`) tiene `EXECUTE` sobre el
schema `app` y **nada más**. No puede leer una tabla ni aunque quisiera.

La consecuencia práctica: la validación de tenant, el permiso, el alcance
organizacional, las transiciones del Anexo A y la auditoría ocurren **dentro de
la transacción**, no en una capa que se pueda saltar. Un backend comprometido no
puede leer datos de otro cliente ni cerrar una OT con una derivada bloqueante
abierta.

---

## Arrancar

```bash
# 1 · servicios (postgres 5436, redis 6383, minio 9110/9111)
docker compose -f infra/docker/docker-compose.dev.yml up -d

# 2 · base de datos
bash db/scripts/apply-migrations.sh

# 3 · backend  → http://localhost:3200/api
cd backend && npm install && npm run start:dev

# 4 · frontend → http://localhost:5174
cd frontend && npm install && npm run dev
```

Credenciales sembradas: `admin@mip.local` / `CambiarEnDeploy2026`.

Los puertos están deliberadamente desplazados de los habituales para poder tener
otros proyectos levantados a la vez.

## Verificar

```bash
bash scripts/pruebas.sh           # suite de regresión: flujos + seguridad + bloqueo
```

Es la que debe pasar antes de aprobar un despliegue, y está pensada para que la
ejecute el área de sistemas del cliente sin leerse el código. Son cinco bloques:

| Bloque | Qué comprueba |
|---|---|
| `scripts/pruebas-flujos.mjs` | Los 75 pasos del producto, **llamando a la API igual que lo hacen las pantallas** |
| `scripts/pruebas-qa.mjs` | **Los 30 criterios de aceptación del documento funcional**, uno a uno y por su número |
| `scripts/pruebas-seguridad.mjs` | Anexo B por rol, escalada de privilegios, aislamiento entre clientes, inyección SQL, sesión, fuerza bruta y cabeceras |
| `scripts/pruebas-cotizacion-pdf.mjs` | Lectura del PDF del proveedor, carga de la cotización, archivo del documento y descarga acotada al cliente |
| `db/scripts/smoke-bloqueo-credenciales.sql` | El bloqueo de cuenta tras intentos fallidos, en la base |

El límite de intentos de login se aplica también a la suite: los bloques gastan
la cuota del minuto entre ellos y el arranque de cada uno espera a que la
ventana se renueve. Es a propósito —relajar la protección para que las pruebas
sean cómodas dejaría el sistema abierto a fuerza bruta.

`pruebas-qa.mjs` existe para que el cliente pueda pedir *"demuéstrame QA-16"* y
se le responda con una ejecución en vez de una explicación. Cada comprobación
cita lo que exige el documento antes de verificarlo.

> **Por qué existe además de los smoke anteriores.** Los smoke de abajo conducen
> la máquina de estados a mano (`PATCH /ot/:id/estado`, `sp_ot_cambiar_estado`),
> un camino que **ninguna pantalla usa**. Eso los dejaba en verde mientras el
> producto era inusable por la interfaz: registrar un diagnóstico no sacaba la OT
> de `creada`, así que cotizar, ejecutar y cerrar eran inalcanzables. Una prueba
> que se salta el camino real del usuario no prueba el producto: prueba la base.

```bash
bash db/scripts/smoke.sh          # ciclo completo por SP + integridad del árbol
psql ... -f db/scripts/smoke-invariantes.sql   # que la base RECHAZA lo que debe
bash scripts/smoke-api.sh         # el mismo ciclo por HTTP, con un usuario por rol
```

El smoke recorre: solicitud → aceptar → OT → diagnóstico v1 → v2 → cotización →
reemplazo → iniciar → avance → pausa → reanudar → incidencia → derivada → nieta →
mensaje → trabajo realizado → corrección → aprobar → SOLPED → número SAP → OC →
liberación parcial → cerrar con pendiente → registrar OC → reabrir → cerrar.

El de invariantes comprueba que la base **rechaza** ciclos en la jerarquía, dos
diagnósticos vigentes, dos pausas abiertas, término anterior al inicio,
liberación negativa, doble conversión de una solicitud, mutación de la bitácora,
emergencia sin justificar, transiciones fuera del Anexo A, reapertura sin motivo
y acceso cruzado entre tenants.

---

## Reglas del documento que el código hace cumplir

Éstas no son convenciones de estilo: son restricciones de integridad del
documento, y están implementadas donde no se pueden esquivar.

| Regla | Dónde vive |
|---|---|
| Una OT no puede ser su propio ancestro | trigger `trg_ot_jerarquia` |
| Exactamente una versión vigente de diagnóstico y de cotización | índices únicos parciales |
| Una sola pausa abierta por OT | índice único parcial |
| El término no antecede al inicio; el cierre no antecede al término | `CHECK` |
| Una solicitud se convierte en OT una sola vez | índice único parcial |
| Una OT cerrada sólo cambia por reapertura auditada | trigger `trg_ot_guarda_cerrada` |
| Registrar la OC tras el cierre no reabre la OT | el trigger administrativo está exento de la guarda |
| Las transiciones siguen el Anexo A | `internal.validar_transicion_ot` |
| La emergencia no elimina la regularización | columna `regularizacion_pendiente` |
| Nada se borra: se cancela, versiona, inactiva o anula | `deleted_at`, versionado, `DELETE` revocado |
| El solicitante no ve costos, RUC, CECOS ni cotizaciones | poda en `app.fn_ot_obtener`, no en el frontend |
| Un promedio no se publica sin muestra suficiente | `fn_costo_historico`, umbral por tenant |

## Datos de demostración

```bash
bash scripts/preparar-demo.sh
```

Hace el ciclo entero: pasa la suite, **borra todo lo transaccional** (incluido lo
que dejaron las pruebas), siembra un juego de muestra y comprueba que el árbol de
trazabilidad quedó íntegro. Si la suite falla no siembra nada: no tiene sentido
enseñar un sistema que no pasa sus propias pruebas.

Lo que queda: 13 OT repartidas por **todos** los estados del Anexo A —incluidas
una emergencia sin regularizar, un padre con dos derivadas, una cancelada y una
reabierta—, 19 solicitudes con su cola sin revisar, 9 personas con sus roles y 8
costos con su texto original. Suficiente para que ninguna pantalla salga vacía y
poco bastante para poder leerla.

Los datos se crean **llamando a la API**, no insertando filas: así los
diagnósticos se versionan de verdad y el árbol lo construye el motor. Unos
`INSERT` directos darían una pantalla bonita y una trazabilidad falsa.

| Paso | Script |
|---|---|
| Borrar lo transaccional | `db/scripts/limpiar-transaccional.sql` |
| Sembrar la muestra | `scripts/datos-demo.mjs` |
| Repartir las fechas en el tiempo | `db/scripts/fechas-demo.sql` |

Los tres exigen confirmación explícita y **no deben correr contra datos reales**.
El de fechas desactiva un instante el trigger que hace append-only la bitácora,
dentro de la misma transacción que lo vuelve a activar; es la única forma de
mover hechos ya sellados, y por eso vive aparte y avisa.

Acceso de demostración: cualquier correo `@demoindustrial.pe` con `Demo.MIP.2026`.
La coordinadora es `rosa.quispe@demoindustrial.pe`; el super admin sigue siendo
`admin@mip.local`.


### Llevárselo a otra máquina

```bash
bash db/scripts/restaurar-dump.sh
```

`db/dump/mip_demo.sql` es el sistema entero en un archivo: esquemas, tablas,
triggers, los 93 stored procedures donde vive la lógica, y el juego de datos de
muestra con su árbol de trazabilidad ya construido. Restaura en un minuto, sin
aplicar migraciones ni sembrar nada, y sirve para enseñar el producto en un
portátil o en un servidor de pruebas.

El volcado se genera sin dueño ni permisos para que entre bajo cualquier
usuario; el script aplica después `90_grants.sql`, que crea el rol de la API y
le da EXECUTE sobre `app` y nada más. Funciona con la base en Docker o contra un
PostgreSQL normal:

```bash
DB_CONTAINER="" DB_HOST=mi-servidor bash db/scripts/restaurar-dump.sh
```

Para un entorno real el camino sigue siendo el largo —`apply-migrations.sh` y
sembrar por la API—, porque es el que deja la base construida por su propia
historia. **El volcado son datos de demostración y borra la base de destino: no
va sobre datos reales.**

## Integración continua

`.github/workflows/ci.yml` levanta Postgres y Redis de verdad —no dobles—, aplica
las migraciones dos veces para probar su idempotencia, comprueba tipos y estilo,
compila, arranca la API y pasa la suite completa más los invariantes de la base.
Toda la lógica vive en stored procedures: una prueba contra una base simulada no
probaría el producto.

## Seguridad

Lo que un área de sistemas pregunta en la revisión previa, y dónde está resuelto.

| Control | Dónde vive |
|---|---|
| Permisos por rol (Anexo B) | Los comprueba el stored procedure, no el frontend: forzar un botón no sirve de nada |
| Aislamiento entre clientes | `internal.assert_acceso_tenant` en cada SP; un id de otro tenant responde 404, sin confirmar que existe |
| Alcance por sucursal/empresa/área | `internal.assert_alcance` |
| Adjuntos | Se piden por id, no por clave de almacén: `app.fn_adjunto_obtener` comprueba tenant y alcance antes de firmar una URL temporal, y la clave nunca llega al navegador |
| Contraseñas | `pgcrypto` con bcrypt coste 12; el hash nunca sale de la transacción |
| Fuerza bruta | Dos capas: bloqueo de la **cuenta** a los 5 fallos (configurable por tenant, clave `bloqueo_credenciales`) y tope por **IP** en los endpoints de autenticación |
| Intentos fallidos | Cada uno queda en `audit.audit_log` como `login_fallido`, con el contador y el umbral |
| Inyección SQL | Todo entra como parámetro de un SP; nada se concatena |
| Cabeceras | CSP `default-src 'none'`, HSTS, `nosniff`, `frame-ancestors 'none'`, `no-referrer` |
| Terceros en el navegador | Ninguno: las tipografías se sirven desde la propia aplicación |
| Auditoría | Campo a campo, con autor, instante y motivo; la bitácora es inmutable por trigger |

El bloqueo de credenciales se ajusta por cliente sin tocar código:

```sql
UPDATE core.tenant_configuracion
   SET valor = '{"intentos":3,"minutos":30}'::jsonb
 WHERE clave = 'bloqueo_credenciales';
```

## La cotización del proveedor llega en PDF

El coordinador sube el PDF y el sistema **rellena el formulario con lo que dice
el documento**: proveedor, RUC, número, fecha, importe, moneda, plazo y validez.
Nada se guarda en ese momento. Lo leído se muestra marcado, la persona lo
confirma o lo corrige, y recién al guardar se crea la cotización y se archiva el
PDF junto a esa versión, con un botón para volver a abrirlo.

Cada campo sale con la confianza con la que se obtuvo, en el mismo idioma de
color que el resto del sistema:

| Marca | Qué significa |
|---|---|
| **DEL PDF** (esmeralda) | La etiqueta estaba escrita en el documento: *"TOTAL A PAGAR S/ 4,661.00"* |
| **REVÍSELO** (ámbar) | Se dedujo por posición o por descarte. El formulario muestra la línea exacta de la que salió |

**No es OCR ni un modelo de lenguaje.** Es lectura de la capa de texto que el
propio PDF ya trae, más reglas sobre cómo se escriben las cotizaciones en el
Perú: dígito verificador del RUC módulo 11, el RUC del cliente descartado
—incluido cuando cuelga del renglón de *"Señores:"*—, importes en formato
peruano (`1,234.56`) o europeo (`1.234,56`), y el total distinguido del subtotal
y del IGV.

Esa decisión responde al cap. 38, que deja la automatización como decisión
pendiente del cliente y advierte que *"afecta calidad, costo y privacidad
documental"*. Leyendo en el propio servidor: **el documento del proveedor no
sale de la red del cliente**, no cuesta por página y no hay nada que un área
legal tenga que autorizar.

El precio es explícito: un PDF escaneado —una foto, un fax— no tiene texto que
leer. Eso no se disimula, se dice (*"es un escaneo o una foto; el archivo queda
adjunto igual, pero los datos hay que escribirlos a mano"*) y el formulario
sigue funcionando como siempre. Si el cliente decide más adelante invertir en
OCR, entra detrás de esta misma pantalla sin cambiarle el flujo a nadie.

## Sobre SAP

**No hay conector, y es deliberado.** El cap. 22.4 deja pendientes los campos
exactos de SOLPED, la versión de SAP por cliente, las APIs, las imputaciones y
los desarrollos Z; el cap. 38 cierra con una regla de gobernanza explícita: *una
decisión pendiente no debe resolverse con un supuesto de desarrollador*.

Lo que sí existe: la estructura de datos completa, los estados de integración, el
botón "Crear SOLPED" que prepara el registro interno, y la captura manual y
auditada del número SAP. La interfaz dice claramente que el envío no está
integrado en lugar de aparentar que lo está.

## Documentación

- [`docs/architecture/`](docs/architecture) — visión general, contextos, multi-tenant, auth, trazabilidad, despliegue
- [`docs/decisions/`](docs/decisions) — los ADR, con el contexto y las consecuencias de cada decisión
- [`docs/database/`](docs/database) — especificación de la base y orden de ejecución
- [`docs/operations/`](docs/operations) — runbook, respaldo y restauración, monitoreo
