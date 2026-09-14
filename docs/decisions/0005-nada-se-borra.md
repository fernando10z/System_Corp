# ADR 0005 · Nada se borra: se cancela, se versiona, se inactiva o se anula

**Estado:** aceptada · 2026-08-22

## Contexto

El cap. 18.1 es explícito: las OT se cancelan, las cotizaciones se reemplazan,
los usuarios con historia se inactivan, una SOLPED confirmada no se elimina
físicamente. El cap. 2.4 lo eleva a filosofía: *"el sistema no borra historia
operativa: versiona, cancela, invalida o reabre con motivo"*.

Esto no es una preferencia de auditoría. Es lo que permite responder, meses
después, por qué una intervención costó lo que costó.

## Decisión

Cinco mecanismos, según lo que corresponda al caso:

| Caso | Mecanismo |
|---|---|
| OT que no continúa | estado `cancelada` + motivo obligatorio |
| Diagnóstico o cotización superados | versión nueva; la anterior conserva datos y motivo |
| Usuario o empresa que sale | `estado = 'inactivo'`, con alerta de lo que queda abierto |
| SOLPED corregida en SAP | anulación **lógica** con motivo; permite crear una nueva |
| Mensaje o adjunto retirado | retiro lógico; queda el rastro de que existió |

Y dos garantías estructurales:

- `core.ot_evento` es **append-only**: `UPDATE` y `DELETE` revocados al rol de
  aplicación **y** bloqueados por trigger, para que tampoco pueda el owner.
- El cierre de una OT es una fila de `core.ot_cierre`, no un par de columnas. Al
  reabrir, el cierre anterior se marca no vigente pero permanece íntegro.

## Consecuencias

- El árbol de trazabilidad puede mostrar la historia completa, incluidas las
  versiones superadas, que se pintan apagadas pero siguen siendo legibles.
- Las tablas crecen y no se purgan solas. La política de retención por cliente
  (cap. 38) queda pendiente de definir; cuando exista, será un proceso explícito
  y auditado, no un `DELETE` en un cron.
- La interfaz nunca ofrece "eliminar" sin decir qué significa realmente. Donde el
  documento admite la palabra —"Eliminar SOLPED"— el texto aclara que es una
  anulación lógica.
