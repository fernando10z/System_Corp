# Monitoreo

## Sondas

| Qué | Cómo | Alerta si |
|---|---|---|
| API viva | `GET /api/health` | `ok:false` o no responde en 5 s |
| Base | campo `servicios.base_datos` | `false` — es la única dependencia crítica |
| Redis | `servicios.redis` | `false` más de 15 min (no se pueden revocar sesiones) |
| Almacén | `servicios.almacenamiento` | `false` (no se pueden subir adjuntos) |

## Señales propias del dominio

Estas son las que avisan de que algo va mal **funcionalmente**, no técnicamente:

```sql
-- Árboles sin refrescar. Un número que sólo sube indica que el refresco
-- perezoso no se está ejecutando en ningún camino de lectura.
SELECT count(*) FROM core.orden_trabajo WHERE trazabilidad_dirty;

-- Correos que no salieron. No revierten nada, pero alguien debe verlos.
SELECT count(*) FROM core.notificacion WHERE estado = 'fallida';

-- Emergencias sin regularizar: la deuda administrativa que deja saltarse
-- el flujo normal (cap. 3).
SELECT count(*) FROM core.orden_trabajo
 WHERE regularizacion_pendiente AND estado <> 'cancelada';

-- Cerradas con pendiente administrativo. No es un incumplimiento técnico,
-- pero si crece sostenidamente, Compras va por detrás.
SELECT count(*) FROM core.orden_trabajo
 WHERE estado = 'cerrada' AND estado_administrativo <> 'administracion_completa';

-- Solicitudes que incumplen el SLA de primera revisión (cap. 34.2).
SELECT app.fn_sla_solicitudes(<user>, <tenant>, true);
```

## Logs

`nestjs-pino` en JSON. Cada línea lleva `reqId`, `userId` y `tenantId`, así que
un incidente en un cliente se aísla sin cruzar a mano contra la base.

Se redactan automáticamente: cabecera `authorization`, cookies y los campos
`password`, `passwordActual` y `passwordNueva`.

El `reqId` viaja también a `audit.audit_log.request_id`: dada una línea de log se
puede ver exactamente qué cambió en la base, y al revés.

## Crecimiento

Las tablas que crecen sin límite son `core.ot_evento`, `audit.audit_log` y
`core.notificacion`. La columna `trazabilidad` también pesa: un árbol con
derivadas y conversación larga puede llegar a varios cientos de kilobytes por OT.

Si el tamaño llega a molestar, la palanca es reducir la profundidad por defecto
del snapshot o dejar la conversación fuera de él y servirla aparte —ya existe
`fn_ot_linea_tiempo` para eso—. No purgar eventos.
