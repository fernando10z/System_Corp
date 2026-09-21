/**
 * Generador de PDF de prueba.
 *
 * El lector de cotizaciones necesita archivos reales contra los que correr, y
 * depender de un PDF binario guardado en el repositorio tiene dos problemas:
 * nadie puede revisar en un diff qué cambió dentro, y no se pueden generar
 * variantes (coma decimal, sin capa de texto, importes en dólares) sin ir
 * acumulando binarios.
 *
 * Por eso se construye el PDF aquí: sin comprimir, con fuente estándar
 * Helvetica y WinAnsiEncoding —que cubre las tildes y la ñ en un solo byte—,
 * que es el mínimo que pdf.js sabe leer.
 */

export interface LineaPdf {
  /** Puntos desde el borde izquierdo. */
  x: number;
  /** Puntos desde el borde INFERIOR: así lo mide PDF, al revés que la pantalla. */
  y: number;
  texto: string;
  tamano?: number;
}

const escapar = (s: string) => s.replace(/\\/g, "\\\\").replace(/\(/g, "\\(").replace(/\)/g, "\\)");

/** Construye un PDF de una página con las líneas indicadas. */
export function construirPdf(lineas: LineaPdf[]): Buffer {
  const flujo = lineas
    .map((l) => `BT /F1 ${l.tamano ?? 10} Tf 1 0 0 1 ${l.x} ${l.y} Tm (${escapar(l.texto)}) Tj ET`)
    .join("\n");
  const contenido = Buffer.from(flujo, "latin1");

  const objetos = [
    "<< /Type /Catalog /Pages 2 0 R >>",
    "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
    "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] " +
      "/Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>",
    null, // el 4 es el flujo de contenido: se arma aparte porque lleva bytes
    "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>",
  ];

  const partes: Buffer[] = [Buffer.from("%PDF-1.4\n", "latin1")];
  const desplazamientos: number[] = [];
  let cursor = partes[0].length;

  objetos.forEach((cuerpo, i) => {
    const n = i + 1;
    desplazamientos.push(cursor);
    const b =
      cuerpo === null
        ? Buffer.concat([
            Buffer.from(`${n} 0 obj\n<< /Length ${contenido.length} >>\nstream\n`, "latin1"),
            contenido,
            Buffer.from("\nendstream\nendobj\n", "latin1"),
          ])
        : Buffer.from(`${n} 0 obj\n${cuerpo}\nendobj\n`, "latin1");
    partes.push(b);
    cursor += b.length;
  });

  const inicioXref = cursor;
  const xref = [
    `xref\n0 ${objetos.length + 1}\n`,
    "0000000000 65535 f \n",
    ...desplazamientos.map((d) => `${String(d).padStart(10, "0")} 00000 n \n`),
    `trailer\n<< /Size ${objetos.length + 1} /Root 1 0 R >>\nstartxref\n${inicioXref}\n%%EOF\n`,
  ].join("");
  partes.push(Buffer.from(xref, "latin1"));

  return Buffer.concat(partes);
}

/** Convierte un bloque de texto en líneas, de arriba hacia abajo. */
export function desdeTexto(texto: string, opciones: { x?: number; interlineado?: number } = {}) {
  const { x = 56, interlineado = 14 } = opciones;
  return texto
    .split("\n")
    .map((t, i) => ({ x, y: 786 - i * interlineado, texto: t }))
    .filter((l) => l.texto.trim() !== "");
}

/** Cotización peruana típica: proveedor arriba, cliente en "Señores", totales abajo. */
export const COTIZACION_TIPICA = `MECANICA INDUSTRIAL DEL SUR S.A.C.
RUC: 20512345671
Av. Argentina 3450, Callao - Lima
Telf. (01) 452-8890   ventas@misur.com.pe

COTIZACION N° COT-2026-0187
Fecha de emision: 14/03/2026

Señores: DEMO INDUSTRIAL S.A.C.
RUC: 20601234565
Atencion: Area de Mantenimiento

Item  Descripcion                              Cant.   P. Unit.    Importe
1     Rebobinado de motor trifasico 15 HP        1      2,850.00    2,850.00
2     Cambio de rodamientos SKF 6308-2RS         2        185.00      370.00
3     Balanceo dinamico de rotor                 1        420.00      420.00
4     Mano de obra y pruebas en vacio            1        310.00      310.00

                                      Subtotal        S/  3,950.00
                                      IGV (18%)       S/    711.00
                                      TOTAL A PAGAR   S/  4,661.00

Plazo de entrega: 12 dias calendario
Validez de la oferta: 30 dias
Forma de pago: credito 30 dias

No incluye desmontaje ni transporte del motor.`;

/** Variante en dólares, con coma decimal y sin etiqueta "cotización". */
export const COTIZACION_DOLARES = `HYDRAULIC PARTS PERU E.I.R.L.
R.U.C. 20548899177
Proforma Nro. PRF-88/2026
Fecha: 02-04-2026

Cliente: DEMO INDUSTRIAL S.A.C.

Reparacion de cilindro hidraulico 80x1200
Repuestos importados y sellos                          1.250,00
Mano de obra especializada                               430,50

IMPORTE TOTAL                                  US$    1.680,50

Plazo de ejecucion: 20 dias habiles
Oferta valida por 15 dias`;
