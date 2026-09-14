# ADR 0002 · La OT es la tabla principal y guarda su árbol de trazabilidad

**Estado:** aceptada · 2026-08-22

## Contexto

Requisito explícito del proyecto: la Orden de Trabajo debe ser la tabla
principal, y debe llevar una columna JSON con el árbol de todo lo que esa OT
generó.

Funcionalmente encaja: el cap. 8.1 describe la OT como el contenedor del ciclo
técnico, y el cap. 21.1 la sitúa como origen de diagnósticos, derivadas,
cotizaciones, ejecución, conversación, seguimiento administrativo y auditoría.

La pregunta real no era *si*, sino **cómo mantener esa columna sin que mienta**.

## Alternativas consideradas

1. **Triggers que reconstruyen el árbol en cada escritura.** Correcto pero caro:
   insertar un mensaje de chat reconstruiría el documento completo, con
   amplificación de escritura y riesgo de deadlock entre padre e hija.
2. **JSON append-only.** Barato, pero es una bitácora, no un árbol: no permite
   responder "¿cuál es el diagnóstico vigente?" sin recorrer todo el historial.
3. **Sólo una función on-demand, sin columna.** Correcto y barato de escribir,
   pero incumple el requisito y obliga a recalcular en cada lectura de la ficha.

## Decisión

Las tres cosas, repartidas según lo que cada una hace bien:

- `internal.fn_ot_trazabilidad()` construye el árbol desde las tablas reales y es
  **la autoridad**. La columna es una proyección suya.
- Los triggers de las tablas hijas **sólo marcan** `trazabilidad_dirty`, hacia
  arriba (ancestros) y un nivel hacia abajo (las hijas embeben el resumen del
  padre). No reconstruyen nada.
- `app.sp_ot_trazabilidad_refrescar()` recalcula y guarda; lo llaman los SP de
  negocio y, de forma perezosa, el camino de lectura.
- `core.ot_evento` es una bitácora append-only inmutable que se embebe como
  `eventos[]`.

## Consecuencias

- Lecturas instantáneas, escrituras baratas, y un árbol que no puede divergir de
  forma irrecuperable: siempre se puede reconstruir.
- `app.fn_trazabilidad_verificar()` compara snapshot contra función y detecta si
  algún trigger dejó de dispararse.
- **Obligación no obvia:** todo orden dentro del JSON necesita un desempate
  estable. `created_at` se llena con `now()`, que es el instante de inicio de la
  transacción, así que las filas escritas por un mismo SP empatan. Sin desempate,
  el árbol sale en orden distinto en cada llamada y el snapshot deja de poder
  compararse.
- El árbol de una derivada embebe el resumen de su padre, así que cerrar el padre
  ensucia a las hijas. Se cubre marcando también hacia abajo, un solo nivel.
