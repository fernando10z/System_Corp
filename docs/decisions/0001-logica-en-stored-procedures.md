# ADR 0001 · Toda la lógica de negocio vive en stored procedures

**Estado:** aceptada · 2026-08-22

## Contexto

MIP es multi-cliente y sus reglas no son cosméticas: si una OT se cierra con una
derivada bloqueante abierta, o si un usuario de un tenant lee una OT de otro, el
daño es real y difícil de detectar después.

La alternativa habitual —reglas en el backend, base como almacén— deja esas
garantías al alcance de cualquier ruta nueva mal escrita, de un script de
mantenimiento, o de un backend comprometido.

## Decisión

La lógica de negocio se implementa **íntegramente en funciones PL/pgSQL** del
schema `app`. El rol PostgreSQL del backend tiene `EXECUTE` sobre `app` y nada
más: ni `SELECT` sobre una tabla.

Todo SP recibe como tres primeros parámetros `p_user_id`, `p_tenant_id` y
`p_is_super_admin`, y vuelve a validar tenant, permiso y alcance por su cuenta.
La base **no confía en el backend**.

## Consecuencias

**A favor**
- Las reglas se cumplen dentro de la transacción; no hay camino que las esquivo.
- El aislamiento entre clientes es estructural, no una condición `WHERE` que
  alguien pueda olvidar.
- La auditoría se escribe en la misma transacción que el cambio: no puede quedar
  desincronizada.
- El backend queda delgado y aburrido, que es exactamente lo que se busca.

**En contra**
- Depurar PL/pgSQL es menos cómodo que depurar TypeScript.
- Las migraciones son el único mecanismo de despliegue de lógica.
- Hace falta disciplina para que los SP no se conviertan en funciones de mil
  líneas; se mitiga extrayendo helpers a `internal`.

**Consecuencia inesperada, ya resuelta:** una función `STABLE` no puede ejecutar
`CREATE TABLE`, así que los listados no pueden usar tablas temporales. Se usan
CTE, que además evalúan el filtro una sola vez.
