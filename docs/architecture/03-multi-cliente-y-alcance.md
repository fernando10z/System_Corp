# Multi-cliente y alcance organizacional

Dos dimensiones distintas de visibilidad, que se validan por separado.

## 1 · Tenant

`tenant_id` en toda tabla operativa. `internal.assert_acceso_tenant()` se invoca
al principio de **todos** los SP, antes de leer o modificar nada.

Un usuario con rol de scope `global` o `global_restricted` atraviesa esa
frontera; `internal.es_acceso_global()` lo resuelve, y los filtros de lectura la
usan siempre en lugar de `p_is_super_admin` a secas.

## 2 · Alcance organizacional

Dentro de un tenant, la jerarquía funcional del cap. 5 es:

```
Sucursal ──┬─► Empresa/RUC ──► Área ──► (CECOS)
           └─► Empresa/RUC ──► Área
```

Reglas que el modelo hace cumplir:

- Una sucursal puede contener **varias** empresas/RUC (`sucursal_empresa_ruc`).
- Un área pertenece a **una sola** empresa/RUC. El mismo nombre bajo otra razón
  social es otra área: el índice único es `(empresa_ruc_id, codigo)`, no
  `(tenant_id, codigo)`.

`core.usuario_alcance` guarda las filas de alcance de cada usuario. Un `NULL` en
un nivel significa "todo ese nivel". Sin filas, el usuario no está restringido a
nivel organizacional: su límite es el tenant.

`internal.assert_alcance()` lo valida en las mutaciones; los listados aplican la
misma condición en su `WHERE`.

## Qué pasa al inactivar

Ni usuarios ni empresas se borran (ADR 0005). Al inactivar:

- **Empresa/RUC** — se conserva, deja de poder usarse en OT nuevas, y el SP
  devuelve cuántas OT abiertas quedan bajo ella para que administración las
  gestione (Anexo C, QA-24).
- **Usuario** — deja de poder entrar; sus OT, mensajes, diagnósticos y auditoría
  conservan su autoría original (QA-23). El SP avisa de las OT abiertas que
  tenía asignadas.
