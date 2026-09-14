# Orden de ejecución

Los archivos se aplican en **orden alfanumérico**, y ese orden ya es el correcto.
No hay excepciones que recordar: las semillas van en `89_seeds.sql`, antes de
`90_grants.sql`, para que se creen como owner de la base.

```bash
bash db/scripts/apply-migrations.sh
```

Cada archivo es **idempotente** (`CREATE ... IF NOT EXISTS`, `CREATE OR REPLACE`,
`ON CONFLICT DO NOTHING`). Correr el script tres veces seguidas debe terminar sin
un solo error y sin duplicar una sola fila.

## Los archivos, y por qué van en ese orden

| Archivo | Contenido | Depende de |
|---|---|---|
| `00_extensions.sql` | `pgcrypto`, `pg_trgm`, `unaccent`, `btree_gin` | — |
| `01_schemas.sql` | `core`, `app`, `internal`, `audit` | 00 |
| `02_enums.sql` | 27 ENUM, todos con valores literales del documento | 01 |
| `03_tables_organizacion.sql` | Tenant, sucursal, empresa/RUC, área, CECOS, usuarios, roles, permisos, alcance, catálogos, tipos de trabajo, proveedores, configuración, correlativos | 02 |
| `04_tables_operacion.sql` | **`core.orden_trabajo`** y todo el ciclo técnico: solicitudes, diagnósticos, cotizaciones, ejecución, cierre, reaperturas | 03 |
| `05_tables_soporte.sql` | SOLPED / OC / liberación, conversación, adjuntos, costos, notificaciones, `ot_evento`, `audit.audit_log` | 04 |
| `06_triggers.sql` | `updated_at` por introspección, anti-ciclo de la jerarquía, guarda de OT cerrada, estado administrativo consolidado, condición pausada, inmutabilidad de la bitácora | 05 |
| `10_internal_helpers.sql` | Asserts de tenant/permiso/alcance, correlativos, auditoría, notificaciones, **`validar_transicion_ot`** (el Anexo A hecho código) | 06 |
| `11_trazabilidad.sql` | **El motor del árbol de trazabilidad.** Va después de `10` porque usa `internal.error_jsonb` | 10 |
| `20`–`40_app_*.sql` | Un archivo por módulo de negocio; sólo aquí se define el schema `app` | 11 |
| `89_seeds.sql` | Permisos, roles, matriz del Anexo B, catálogos base, tipos de trabajo, tenant demo | 40 |
| `90_grants.sql` | Rol `mip_app_user`: `EXECUTE` sólo en `app`, nada más | 89 |

### Detalle de los módulos `app`

```
20_app_auth              login, perfil, cambio de contraseña
21_app_organizacion      sucursales, empresas/RUC, áreas, inactivación con alerta
22_app_usuarios          alta, listado, inactivación (nunca borrado)
23_app_roles_permisos    roles, permisos, reasignación auditada
24_app_catalogos         catálogos configurables, tipos de trabajo, proveedores
25_app_solicitudes       ST-01 crear, tomar revisión, ST-02 decidir
26_app_ot                conversión a OT, derivadas, estados, cancelar, prioridad, ficha y listado
27_app_diagnosticos      DG-01 registrar y versionar, aprobar
28_app_cotizaciones      CT-01 cargar, reemplazar con motivo, invalidar
29_app_ejecucion         iniciar, EJ-01 avance, EJ-02 pausa/reanudar, incidencias, EJ-03 declarar
30_app_cierre            revisar, conformidad, AD-01 cerrar con pendiente, reabrir
31_app_administrativo    SOLPED (manual), OC, liberación
32_app_conversaciones    mensajes, edición y retiro lógicos, invitaciones, línea de tiempo
33_app_adjuntos          registrar con límites configurables, retiro lógico
34_app_costos            registrar, calificar, histórico con umbral de muestra
35_app_notificaciones    bandeja, cola de correo, SLA de primera revisión
36_app_auditoria         historial operativo y auditoría técnica restringida
37_app_dashboards        tablero del coordinador, del solicitante y KPIs
38_app_reportes          reporte de OT con todos los filtros del cap. 20.3
39_app_configuracion     claves configurables del cap. 17, con lista blanca
40_app_trazabilidad      árbol completo, jerarquía, consolidado, verificación, búsqueda
```

## Verificación

```bash
bash db/scripts/smoke.sh
```

Ejecuta el ciclo completo del documento usando **sólo stored procedures de `app`**
—exactamente por donde pasa el backend— y después comprueba que el snapshot
cacheado del árbol coincide con la función autoritativa.

```bash
psql ... -f db/scripts/smoke-invariantes.sql
```

Comprueba que la base **rechaza** lo que el documento dice que debe rechazar
(ciclos, dos diagnósticos vigentes, dos pausas abiertas, reapertura sin motivo,
acceso cruzado entre tenants…). Un invariante que no se prueba en su caso
negativo no está probado.

## Notas

- **Super admin sembrado**: `admin@mip.local` / `CambiarEnDeploy2026`.
  Cámbiela en el primer acceso; el hash se calcula con `bcrypt` dentro de la base
  y la contraseña en claro nunca sale de la transacción.
- **Rol del backend**: `mip_app_user`, con contraseña `cambiar_en_deploy`.
  Tiene `EXECUTE` en `app` y **nada más**: ni un `SELECT` sobre una tabla.
- **Tenant demo**: `demo` · DEMO INDUSTRIAL S.A.C. (RUC 20100000001), una sucursal
  y tres áreas. En una instalación real se crea el tenant del cliente y este se
  puede eliminar.
- **Códigos de error**: MIP usa una clase SQLSTATE propia (`MIP01`…`MIP04`) en vez
  de la clase `P0` de PL/pgSQL. El motivo está explicado en `10_internal_helpers.sql`
  y no es cosmético: `P0004` es `assert_failure`, y `EXCEPTION WHEN OTHERS` se
  niega a capturarlo.
- **SAP**: no hay conector. El cap. 22.4 deja pendientes los campos de SOLPED y el
  mecanismo de integración, y el cap. 38 prohíbe resolver un pendiente con un
  supuesto de desarrollador. Existe la estructura, el botón y la captura manual
  del número SAP.

## Reconstruir desde cero (sólo desarrollo)

```bash
ALLOW_RESET=yes bash db/scripts/reset-dev.sh
```
