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

# 4 · frontend → http://localhost:5180
cd frontend && npm install && npm run dev
```

Credenciales sembradas: `admin@mip.local` / `CambiarEnDeploy2026`.

Los puertos están deliberadamente desplazados de los habituales para poder tener
otros proyectos levantados a la vez.

## Verificar

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
