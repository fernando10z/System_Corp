# El motor de trazabilidad

La pieza que define el producto. Vive en
[`db/migrations/11_trazabilidad.sql`](../../db/migrations/11_trazabilidad.sql).

## Las tres piezas

```
   escritura de negocio
        │
        ├─► trigger de la tabla hija
        │      └─► internal.marcar_ot_dirty(ot)        ← sube por los ancestros
        │      └─► internal.marcar_ot_dirty_hijas(ot)  ← baja un nivel
        │            (sólo pone una bandera; NO reconstruye nada)
        │
        └─► el SP de negocio, al terminar
               └─► app.sp_ot_trazabilidad_refrescar(ot)
                      └─► internal.fn_ot_trazabilidad(ot)   ← LA AUTORIDAD
                             lee las tablas reales y arma el árbol
                      └─► guarda en orden_trabajo.trazabilidad
                          baja dirty, sube version

   lectura
        └─► internal.fn_ot_trazabilidad_fresca(ot)
               si está sucio, refresca; después devuelve el snapshot
```

## Por qué los triggers sólo marcan

Reconstruir el árbol completo en cada escritura significa que insertar un
mensaje de chat reconstruye el documento entero de la OT, incluidas sus
derivadas recursivas. Con una jerarquía de tres niveles y dos usuarios
escribiendo a la vez, eso es amplificación de escritura y una fuente de
deadlocks entre padre e hija.

Marcar una bandera booleana es una escritura de una fila. Y garantiza que
**ningún cambio se pierda**, incluso uno hecho a mano por `psql` fuera de los SP.

## Por qué se marca también hacia abajo

El árbol de una derivada embebe un resumen de su padre (`origen.ot_padre`:
número, estado, motivo de derivación). Cuando el padre cambia de estado, el
snapshot de cada hija queda obsoleto, y la propagación hacia arriba no lo cubre.

Se baja **un solo nivel**: la nieta embebe a su padre, no al abuelo. El marcado
es idempotente —sólo escribe si `dirty` era `false`—, así que la cascada se
detiene sola en lugar de rebotar.

## La trampa del orden

`created_at` se llena con `now()`, que devuelve el **instante de inicio de la
transacción**. Todas las filas escritas por un mismo stored procedure comparten
ese valor.

Consecuencia: `ORDER BY created_at` a secas **no es determinista**, y el árbol
sale con los arrays en orden distinto en cada llamada. Eso rompe la verificación
de integridad, que compara el snapshot contra la función.

Cada ordenación del constructor lleva un desempate estable: `id`, `version`,
`secuencia` o `numero_ot`. `core.liberacion_historial` tiene una columna
`secuencia BIGSERIAL` precisamente por esto: el estado administrativo
consolidado depende de cuál es la última liberación, y ahí la ambigüedad no es
cosmética.

## Verificación

`app.fn_trazabilidad_verificar()` recorre las OT no sucias y compara
`trazabilidad - '_meta'` contra `internal.fn_ot_trazabilidad(id, 10, false) - '_meta'`.
Se descarta `_meta` porque lleva el instante de generación.

Si alguna se desvía, hay un trigger de marcado que no se está disparando. En
condiciones normales devuelve cero desviadas.
