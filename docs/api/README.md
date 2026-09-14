# Superficie HTTP

Prefijo `/api`. Todo devuelve el sobre `{ ok, data, error, meta }`.

## Autenticación
| Método | Ruta | Notas |
|---|---|---|
| POST | `/auth/login` | público |
| POST | `/auth/refresh` | público |
| POST | `/auth/logout` | revoca todas las sesiones del usuario |
| GET | `/auth/perfil` | roles, permisos y alcance |
| POST | `/auth/cambiar-password` | |

## Solicitudes
`GET /solicitudes` · `GET /solicitudes/:id` · `POST /solicitudes` ·
`POST /solicitudes/:id/enviar` · `POST /solicitudes/:id/tomar-revision` ·
`POST /solicitudes/:id/decidir`

## Órdenes de trabajo
`GET /ot` · `GET /ot/:id` · `POST /ot` · `PATCH /ot/:id` ·
`PATCH /ot/:id/estado` · `PATCH /ot/:id/prioridad` · `POST /ot/:id/cancelar` ·
`POST /ot/:id/derivadas`

### Trazabilidad
| Ruta | Devuelve |
|---|---|
| `GET /ot/:id/trazabilidad` | el árbol completo, garantizando frescura |
| `GET /ot/:id/jerarquia` | sólo el esqueleto de derivadas, sin los bloques pesados |
| `GET /ot/:id/consolidado` | resumen informativo de descendientes |
| `GET /ot/:id/linea-tiempo` | mensajes humanos + eventos de sistema, mezclados y diferenciados |
| `GET /ot/:id/historial` | la bitácora en lenguaje de negocio |
| `GET /ot/verificar-trazabilidad` | integridad del motor (requiere `auditoria:ver`) |
| `POST /ot/buscar-trazabilidad` | búsqueda por contención dentro del árbol |

## Ciclo técnico
`POST /ot/:id/diagnosticos` · `POST /diagnosticos/:id/aprobar` ·
`POST /ot/:id/cotizaciones` · `POST /cotizaciones/:id/invalidar` ·
`POST /ot/:id/iniciar` · `/avances` · `/incidencias` · `/pausar` · `/reanudar` ·
`/trabajo-realizado` · `/revisar` · `/conformidad` · `/cerrar` · `/reabrir`

## Administrativo
`GET /ot/:id/administrativo` · `POST /ot/:id/solped` ·
`POST /solped/:id/marcar-lista` · `POST /solped/:id/numero-sap` ·
`POST /solped/:id/anular` · `POST /ot/:id/orden-compra` · `POST /ot/:id/liberacion`

## Resto
`/conversacion` · `/mensajes` · `/participantes` · `/adjuntos` · `/costos` ·
`/dashboard/{coordinador,solicitante,kpis}` · `/reportes/ot` · `/auditoria` ·
`/configuracion` · `/notificaciones` · `/organizacion` · `/usuarios` · `/roles`

## Dos endpoints que devuelven `ok:false` sin que sea un error

- **`POST /ot/:id/cerrar`** — si hay pendientes administrativos responde
  `ok:false` con `data.requiere_confirmacion` y el estado actual. La interfaz
  pide entonces la confirmación explícita y la observación obligatoria.
- **`POST /ot/:id/cancelar`** — si hay derivadas activas y el tratamiento es
  `bloquear`, responde `ok:false` con `data.derivadas_activas` para que el
  usuario decida qué hacer con ellas.

En ambos casos el cliente usa `esperarNoOk: true` y trata el sobre como un paso
del flujo, no como un fallo.
