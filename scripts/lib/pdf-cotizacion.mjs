/**
 * PDF mínimo con el contenido de una cotización.
 *
 * Sirve para que la demostración tenga documentos de verdad que abrir, y para
 * que el lector de PDF tenga contra qué correr. Se genera en vez de guardar
 * binarios en el repositorio: así se ve en el diff qué dice cada documento y se
 * pueden hacer variantes sin acumular archivos.
 *
 * Sin comprimir, fuente estándar Helvetica y WinAnsiEncoding —que cubre las
 * tildes y la ñ en un solo byte—, que es el mínimo que pdf.js sabe leer.
 */

const escapar = (s) => s.replace(/\\/g, "\\\\").replace(/\(/g, "\\(").replace(/\)/g, "\\)");

/** Construye un PDF de una página a partir de líneas de texto. */
export function pdfDeLineas(lineas, { interlineado = 16 } = {}) {
  const flujo = lineas
    .map((l, i) => (String(l).trim() ? `BT /F1 10 Tf 1 0 0 1 56 ${786 - i * interlineado} Tm (${escapar(String(l))}) Tj ET` : ""))
    .filter(Boolean)
    .join("\n");
  const contenido = Buffer.from(flujo, "latin1");

  const objetos = [
    "<< /Type /Catalog /Pages 2 0 R >>",
    "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
    "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>",
    null,
    "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>",
  ];

  const partes = [Buffer.from("%PDF-1.4\n", "latin1")];
  const desplazamientos = [];
  let cursor = partes[0].length;
  objetos.forEach((cuerpo, i) => {
    desplazamientos.push(cursor);
    const b =
      cuerpo === null
        ? Buffer.concat([
            Buffer.from(`${i + 1} 0 obj\n<< /Length ${contenido.length} >>\nstream\n`, "latin1"),
            contenido,
            Buffer.from("\nendstream\nendobj\n", "latin1"),
          ])
        : Buffer.from(`${i + 1} 0 obj\n${cuerpo}\nendobj\n`, "latin1");
    partes.push(b);
    cursor += b.length;
  });
  partes.push(
    Buffer.from(
      `xref\n0 ${objetos.length + 1}\n0000000000 65535 f \n` +
        desplazamientos.map((d) => `${String(d).padStart(10, "0")} 00000 n \n`).join("") +
        `trailer\n<< /Size ${objetos.length + 1} /Root 1 0 R >>\nstartxref\n${cursor}\n%%EOF\n`,
      "latin1",
    ),
  );
  return Buffer.concat(partes);
}

/**
 * Cotización con la forma que tienen las peruanas: membrete con RUC arriba,
 * destinatario en "Señores", total al pie y condiciones al final.
 *
 * @param c Lo que MIP tiene guardado de esa cotización. El documento dice
 *   exactamente eso: si alguien lo vuelve a importar, debe leerse lo mismo.
 */
export function pdfDeCotizacion(c) {
  const simbolo = c.moneda === "USD" ? "US$" : c.moneda === "EUR" ? "EUR" : "S/";
  const importe = Number(c.monto).toLocaleString("en-US", { minimumFractionDigits: 2 });
  const fecha = String(c.fecha).slice(0, 10).split("-").reverse().join("/");

  return pdfDeLineas([
    c.proveedor,
    `RUC: ${c.proveedor_ruc ?? ""}`,
    "",
    `COTIZACION N° ${c.numero}`,
    `Fecha de emision: ${fecha}`,
    "",
    "Señores: DEMO INDUSTRIAL S.A.C.",
    "",
    c.observaciones ?? "Servicio de mantenimiento segun el alcance acordado.",
    "",
    `TOTAL A PAGAR    ${simbolo}  ${importe}`,
    "",
    ...(c.plazo_ofrecido_dias ? [`Plazo de entrega: ${c.plazo_ofrecido_dias} dias calendario`] : []),
    ...(c.validez_dias ? [`Validez de la oferta: ${c.validez_dias} dias`] : []),
  ]);
}
