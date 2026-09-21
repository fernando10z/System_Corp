import type { ValidationError } from "class-validator";

/**
 * Traduce los mensajes de class-validator al español. La interfaz de MIP está en
 * español; que un error de validación salga en inglés rompe la experiencia justo
 * en el momento en que el usuario más necesita entender qué pasó.
 */
const PLANTILLAS: Array<[RegExp, (campo: string, m: RegExpMatchArray) => string]> = [
  [/should not be empty/, (c) => `${c} es obligatorio`],
  [/must be a string/, (c) => `${c} debe ser texto`],
  [/must be a number/, (c) => `${c} debe ser un número`],
  [/must be a boolean/, (c) => `${c} debe ser verdadero o falso`],
  [/must be a UUID/, (c) => `${c} no es un identificador válido`],
  [/must be an email/, (c) => `${c} no es un correo válido`],
  [/must be a valid ISO 8601 date/, (c) => `${c} no es una fecha válida`],
  [
    /must be longer than or equal to (\d+)/,
    (c, m) => `${c} debe tener al menos ${m[1]} caracteres`,
  ],
  [
    /must be shorter than or equal to (\d+)/,
    (c, m) => `${c} no puede superar los ${m[1]} caracteres`,
  ],
  [/must not be less than (\d+)/, (c, m) => `${c} no puede ser menor que ${m[1]}`],
  [/must not be greater than (\d+)/, (c, m) => `${c} no puede ser mayor que ${m[1]}`],
  [/must be one of the following values: (.+)/, (c, m) => `${c} debe ser uno de: ${m[1]}`],
];

export function mensajesValidacionES(errores: ValidationError[], prefijo = ""): string[] {
  const salida: string[] = [];
  for (const e of errores) {
    const campo = prefijo ? `${prefijo}.${e.property}` : e.property;
    for (const bruto of Object.values(e.constraints ?? {})) {
      let traducido: string | null = null;
      for (const [patron, fn] of PLANTILLAS) {
        const m = bruto.match(patron);
        if (m) {
          traducido = fn(campo, m);
          break;
        }
      }
      salida.push(traducido ?? bruto);
    }
    if (e.children?.length) salida.push(...mensajesValidacionES(e.children, campo));
  }
  return salida;
}
