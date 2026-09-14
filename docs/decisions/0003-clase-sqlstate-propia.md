# ADR 0003 · MIP usa su propia clase de SQLSTATE

**Estado:** aceptada · 2026-08-22

## Contexto

Los SP señalan errores de negocio con `RAISE EXCEPTION ... USING ERRCODE`, y los
capturan con `EXCEPTION WHEN OTHERS` para devolver el sobre `{ok:false, error}`.

La convención heredada del proyecto hermano mapeaba `BUSINESS_RULE` a `P0004`.

## El problema

**`P0004` es `assert_failure`**, y PL/pgSQL documenta que `WHEN OTHERS` **no lo
captura** (junto con `query_canceled`). Un SP que usara `P0004` para decir
"regla de negocio incumplida" no devolvería el sobre: reventaría la llamada, y
el backend vería un 500 genérico en vez de un 422 con su mensaje.

Se detectó al ver que un `EXCEPTION WHEN OTHERS` trivial no capturaba nada.

## Decisión

MIP define su propia clase de SQLSTATE:

| Código | Significado | HTTP |
|---|---|---|
| `MIP01` | `VALIDATION` · falta un dato o no cumple su formato | 400 |
| `MIP02` | `NOT_FOUND` · no existe o no es visible | 404 |
| `MIP03` | `CONFLICT` · choca con el estado actual | 409 |
| `MIP04` | `BUSINESS_RULE` · una regla del documento lo impide | 422 |
| `42501` | `FORBIDDEN` · sin permiso o fuera de alcance (estándar) | 403 |

`internal.codigo_error()` traduce el SQLSTATE al código semántico que viaja al
backend, e `internal.error_jsonb()` lo aplica automáticamente.

## Consecuencias

- Ningún código de negocio colisiona con un SQLSTATE que PL/pgSQL trate de forma
  especial.
- El frontend recibe `VALIDATION` o `BUSINESS_RULE`, no `MIP01`: el detalle
  técnico viaja aparte, en `sqlstate`, sólo para diagnóstico.
- La clase `MI` no está reservada por PostgreSQL, así que no hay riesgo de choque
  con códigos futuros del motor.
