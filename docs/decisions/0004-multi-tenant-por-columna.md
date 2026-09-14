# ADR 0004 · Multi-cliente por columna `tenant_id`, validada en la base

**Estado:** aceptada · 2026-08-22

## Contexto

El cap. 21.3 lo pone como restricción de integridad: *"Todo registro relevante
debe contener `tenant_id`; nunca se mezclan datos de clientes"*. El criterio
QA-25 lo prueba: un usuario de otro tenant no puede consultar una OT por su
identificador.

Además, dentro de un tenant hay una segunda dimensión de visibilidad: el alcance
organizacional (sucursal / empresa-RUC / área) del cap. 4.1.

## Decisión

- `tenant_id` en toda tabla operativa, con FK a `core.tenant`.
- La validación vive en `internal.assert_acceso_tenant()`, que **todo** SP invoca
  antes de leer o modificar nada.
- El alcance organizacional se valida aparte, en `internal.assert_alcance()`,
  contra las filas de `core.usuario_alcance`. Un `NULL` en un nivel significa
  "todo ese nivel".
- Los filtros de lectura usan siempre `internal.es_acceso_global()`, nunca
  `p_is_super_admin` a secas: hay roles con alcance global que no son super admin.

Se descartó *Row Level Security* porque la política tendría que leer el usuario
de una variable de sesión, y eso reintroduce la confianza en el backend que el
ADR 0001 elimina. Con SP-only, el `WHERE` está dentro de la función y el rol de
aplicación no puede consultar la tabla por su cuenta de ninguna forma.

## Consecuencias

- Aislamiento verificable: el smoke de invariantes prueba el caso negativo.
- Una base por cliente sigue siendo posible como capa adicional de aislamiento
  físico, sin cambiar nada del modelo.
- Coste: cada SP nuevo debe acordarse de llamar a los asserts. Se mitiga porque
  el patrón está en la primera línea de los 89 SP existentes.
