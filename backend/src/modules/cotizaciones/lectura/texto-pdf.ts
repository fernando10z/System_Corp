import { dirname, join } from "node:path";

/**
 * Extracción de la capa de texto de un PDF, usando pdf.js (Mozilla).
 *
 * Todo ocurre dentro de este proceso: el archivo no se guarda en el almacén ni
 * se envía a ningún servicio externo durante la lectura. Solo se archiva
 * después, si la persona decide guardar la cotización.
 *
 * Se usa la compilación `legacy` de pdf.js 3.x, que es CommonJS igual que el
 * resto del backend. La 4.x solo se publica como ESM y obligaría a trucos de
 * carga que se rompen al compilar y al ejecutar los tests.
 */

/**
 * pdf.js busca `DOMMatrix` y `Path2D` al cargarse y, si no los encuentra,
 * intenta el paquete nativo `canvas` y avisa por consola de que "el renderizado
 * puede estar roto". Aquí no se renderiza nada —solo se lee texto—, así que se
 * declaran vacíos para no arrastrar una dependencia nativa ni ensuciar el log
 * con un aviso que no aplica. Nada llega a llamarlos.
 */
const entorno = globalThis as Record<string, unknown>;
entorno.DOMMatrix ??= class {};
entorno.Path2D ??= class {};

interface ItemTexto {
  str?: string;
  width?: number;
  transform?: number[];
}
interface PaginaPdf {
  getTextContent: () => Promise<{ items: ItemTexto[] }>;
}
interface DocumentoPdf {
  numPages: number;
  getPage: (n: number) => Promise<PaginaPdf>;
  destroy: () => Promise<void>;
}

/**
 * Un PDF no guarda líneas, guarda trozos de texto con coordenadas. Se
 * reconstruyen agrupando por altura (la `y`) y ordenando por posición
 * horizontal, porque las reglas de lectura trabajan sobre líneas: "la línea que
 * dice TOTAL", "la línea de arriba del RUC".
 */
function armarLineas(items: ItemTexto[]): string[] {
  const piezas = items
    .filter((i) => typeof i.str === "string" && i.str !== "")
    .map((i) => ({
      txt: i.str as string,
      x: i.transform?.[4] ?? 0,
      y: i.transform?.[5] ?? 0,
      w: i.width ?? 0,
    }))
    .sort((a, b) => b.y - a.y || a.x - b.x);

  const lineas: string[] = [];
  let actual = "";
  let alturaActual: number | null = null;
  let finAnterior = 0;

  for (const p of piezas) {
    // 2 puntos de tolerancia: los subíndices y las comillas no bajan tanto como
    // para ser otra línea, pero un renglón nuevo siempre baja más.
    if (alturaActual === null || Math.abs(p.y - alturaActual) > 2) {
      if (actual.trim()) lineas.push(actual.trim());
      actual = p.txt;
      alturaActual = p.y;
    } else {
      // Si hay hueco entre el final del trozo anterior y este, había un espacio
      // (o una columna de tabla) en el documento original.
      actual += p.x - finAnterior > 1 ? ` ${p.txt}` : p.txt;
    }
    finAnterior = p.x + p.w;
  }
  if (actual.trim()) lineas.push(actual.trim());
  return lineas;
}

export interface TextoPdf {
  texto: string;
  paginas: number;
  paginasLeidas: number;
}

/**
 * @param maxPaginas Tope de páginas a procesar. Una cotización no tiene
 *   cuarenta hojas; el límite evita que un PDF enorme ocupe la CPU del servidor.
 */
export async function textoDePdf(buffer: Buffer, maxPaginas = 12): Promise<TextoPdf> {
  // Se carga aquí y no arriba por dos razones: no pagar el arranque de pdf.js
  // en cada despliegue del backend —solo hace falta cuando alguien sube un
  // PDF— y asegurar que los sustitutos de DOMMatrix ya estén puestos.
  const modulo = await import("pdfjs-dist/legacy/build/pdf.js");
  const pdfjs = ((modulo as { default?: unknown }).default ?? modulo) as {
    getDocument: (opciones: Record<string, unknown>) => { promise: Promise<DocumentoPdf> };
  };

  const fuentes = join(dirname(require.resolve("pdfjs-dist/package.json")), "standard_fonts/");
  const doc = await pdfjs.getDocument({
    data: new Uint8Array(buffer),
    standardFontDataUrl: fuentes,
    // Un PDF puede traer JavaScript y fuentes incrustadas. Aquí solo se quiere
    // el texto, así que se desactiva todo lo que pueda ejecutar algo.
    isEvalSupported: false,
    disableFontFace: true,
    useSystemFonts: false,
  }).promise;

  try {
    const total = doc.numPages;
    const leer = Math.min(total, maxPaginas);
    const paginas: string[] = [];
    for (let n = 1; n <= leer; n++) {
      const pagina = await doc.getPage(n);
      const contenido = await pagina.getTextContent();
      paginas.push(armarLineas(contenido.items).join("\n"));
    }
    return { texto: paginas.join("\n"), paginas: total, paginasLeidas: leer };
  } finally {
    await doc.destroy().catch(() => undefined);
  }
}
