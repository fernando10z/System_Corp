/**
 * node-postgres convierte los ARRAYS de JavaScript a arrays de Postgres (`{...}`),
 * no a JSON. Al llegar a un parámetro `jsonb` eso revienta con
 * "invalid input syntax for type json". Pasar el JSON ya serializado como texto
 * funciona siempre, porque Postgres castea `text -> jsonb` sin ambigüedad.
 *
 * OJO 1 · Úsese SÓLO para parámetros jsonb. Un `uuid[]` o `text[]` nativo debe
 *         recibir el array tal cual.
 * OJO 2 · NO envolver un null que el SP interpreta como "sin valor":
 *         jsonbArg(null) devuelve la cadena "null", que castea al jsonb `null`,
 *         y `'null'::jsonb IS NULL` es false. En esos casos:
 *             valor == null ? null : jsonbArg(valor)
 */
export function jsonbArg(value: unknown): string {
  return JSON.stringify(value ?? null);
}

/**
 * Filtros de listado: el backend habla camelCase y los SP esperan snake_case.
 * La conversión se hace aquí una vez, en lugar de repetirla en cada controlador.
 */
export function filtrosArg(filtros: Record<string, unknown>): string {
  const limpio: Record<string, unknown> = {};
  for (const [k, v] of Object.entries(filtros)) {
    if (v === undefined || v === null || v === "") continue;
    limpio[k.replace(/[A-Z]/g, (c) => `_${c.toLowerCase()}`)] = v;
  }
  return JSON.stringify(limpio);
}
