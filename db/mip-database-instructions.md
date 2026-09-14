# Base de datos de MIP · especificación

PostgreSQL 16. Toda la lógica de negocio vive aquí.

## Reglas de oro

1. **Acceso sólo por SP/FN.** El rol `mip_app_user` tiene `EXECUTE` en el schema
   `app` y nada más. Sin `SELECT`, `INSERT`, `UPDATE` ni `DELETE` sobre tablas.
2. **Contexto en los tres primeros parámetros.** Todo SP/FN de `app` recibe
   `p_user_id UUID`, `p_tenant_id UUID`, `p_is_super_admin BOOLEAN`, y vuelve a
   validar por su cuenta. La base no confía en el backend.
3. **Retorno estándar JSONB.** `{ ok, data, error, meta }`. Los errores se
   **devuelven**, no se propagan como excepción al cliente.
4. **Baja lógica.** `deleted_at TIMESTAMPTZ NULL`. Nada se borra (ADR 0005).
5. **Auditoría dentro de la transacción.** Cada SP de mutación escribe en
   `audit.audit_log` y, si toca una OT, en `core.ot_evento`.
6. **La OT es la raíz.** Toda tabla operativa cuelga de `core.orden_trabajo` y
   lleva `tenant_id`.

## Schemas

| Schema | Contenido | Acceso del backend |
|---|---|---|
| `core` | tablas, enums, triggers | ninguno |
| `app` | SP y FN públicos | `EXECUTE` |
| `internal` | helpers `SECURITY DEFINER` | ninguno |
| `audit` | auditoría | ninguno |

## Convenciones de nombres

| Objeto | Patrón | Ejemplo |
|---|---|---|
| Tabla | snake_case singular | `orden_trabajo` |
| Columna | snake_case | `fecha_inicio_real` |
| FK | `<entidad>_id` | `empresa_ruc_id` |
| PK | `id UUID DEFAULT gen_random_uuid()` | |
| Enum | snake_case, en `core` | `core.ot_estado` |
| SP de mutación | `app.sp_<entidad>_<accion>` | `app.sp_ot_cerrar` |
| FN de lectura | `app.fn_<entidad>_<accion>` | `app.fn_ot_listar` |
| Helper | `internal.<accion>` | `internal.assert_alcance` |
| Trigger | `trg_<tabla>_<evento>` | `trg_ot_jerarquia` |
| Índice | `ix_<tabla>_<col>` | `ix_ot_padre` |
| Único | `uq_<tabla>_<qué>` | `uq_ot_numero` |
| Check | `ck_<tabla>_<qué>` | `ck_ot_no_autopadre` |

**Tipos.** Montos `NUMERIC(14,2)`; instantes `TIMESTAMPTZ` (nunca `TIMESTAMP`);
estados siempre enum nativo, jamás texto libre; booleanos con prefijo `es_`.

**Columnas de control**, en toda tabla operativa:

```sql
tenant_id  UUID NOT NULL REFERENCES core.tenant(id),
created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
deleted_at TIMESTAMPTZ,
created_by UUID REFERENCES core.usuario(id),
updated_by UUID REFERENCES core.usuario(id)
```

## Plantilla de un SP

```sql
CREATE OR REPLACE FUNCTION app.sp_<entidad>_<accion>(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_<negocio> TYPE
)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'modulo:accion');
  PERFORM internal.assert_alcance(p_user_id, v_sucursal, v_empresa, v_area);

  -- reglas de negocio y operación

  PERFORM internal.registrar_evento_ot(...);   -- bitácora append-only
  PERFORM internal.registrar_auditoria(...);   -- audit_log con diff
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id);

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
```

## Códigos de error

MIP usa **su propia clase de SQLSTATE**. El motivo está en el ADR 0003 y no es
cosmético: `P0004` es `assert_failure`, y `EXCEPTION WHEN OTHERS` se niega a
capturarlo.

| SQLSTATE | Código semántico | HTTP |
|---|---|---|
| `MIP01` | `VALIDATION` | 400 |
| `MIP02` | `NOT_FOUND` | 404 |
| `MIP03` | `CONFLICT` | 409 |
| `MIP04` | `BUSINESS_RULE` | 422 |
| `42501` | `FORBIDDEN` | 403 |

## Trampas conocidas

**Una función `STABLE` no puede crear tablas temporales.** Los listados usan CTE,
que además evalúan el filtro una sola vez para el conteo y la página.

**`now()` es el instante de inicio de la transacción.** Todas las filas escritas
por un mismo SP comparten `created_at`. Cualquier "última fila" u ordenación
dentro del árbol necesita un desempate estable: `id`, `version`, `secuencia` o
`numero_ot`. Por eso `core.liberacion_historial` tiene `secuencia BIGSERIAL`.

**`UNIQUE` trata los `NULL` como distintos.** Las tablas cuyos ítems base llevan
`tenant_id NULL` (`rol`, `catalogo_item`, `tipo_trabajo`) usan
`UNIQUE NULLS NOT DISTINCT`. Sin eso, el `ON CONFLICT DO NOTHING` de las semillas
nunca dispara y cada corrida duplica el catálogo.

**Los agregados no se anidan.** `jsonb_agg(... sum(...) ...)` es un error; el
`sum()` va en una subconsulta propia.

**node-postgres convierte los arrays de JS a arrays de Postgres, no a JSON.** Para
parámetros `jsonb` hay que pasar el JSON ya serializado (`jsonbArg`). Y ojo:
`jsonbArg(null)` devuelve `'null'`, que castea al jsonb `null`, y
`'null'::jsonb IS NULL` es **false**.

## Orden de ejecución

Ver [`migrations/README_ORDEN_EJECUCION.md`](migrations/README_ORDEN_EJECUCION.md).
El orden alfanumérico es el correcto: las semillas van en `89_seeds.sql`, antes
de `90_grants.sql`, para crearse como owner.
