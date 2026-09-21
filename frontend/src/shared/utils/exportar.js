/**
 * Exportación de tablas a Excel, sin dependencias externas.
 *
 * Genera un CSV UTF-8 con BOM y separador ";" — que es lo que espera Excel en
 * configuración regional es-PE, donde la coma es el separador decimal. Se abre
 * con doble clic sin pasos intermedios ni asistente de importación.
 *
 * Es el mismo mecanismo que usa el ERP hermano: añadir una librería de xlsx
 * (≈1 MB) para escribir una tabla plana no compensa.
 *
 *   exportarExcel("ordenes-de-trabajo", [
 *     { key: "numero_ot", label: "OT" },
 *     { key: "monto_cotizado", label: "Cotizado", tipo: "numero" },
 *     { key: "fecha_creacion", label: "Creada", tipo: "fecha" },
 *   ], filas);
 */

function celda(valor, tipo) {
  if (valor === null || valor === undefined) return "";
  if (tipo === "numero") {
    const n = Number(valor);
    if (!Number.isFinite(n)) return "";
    // Decimal con coma: Excel es-PE lo lee como número, no como texto.
    return n.toFixed(2).replace(".", ",");
  }
  if (tipo === "entero") {
    const n = Number(valor);
    return Number.isFinite(n) ? String(Math.round(n)) : "";
  }
  if (tipo === "fecha") {
    const d = new Date(valor);
    if (Number.isNaN(d.getTime())) return String(valor);
    return d.toLocaleDateString("es-PE", { day: "2-digit", month: "2-digit", year: "numeric" });
  }
  if (tipo === "fechaHora") {
    const d = new Date(valor);
    if (Number.isNaN(d.getTime())) return String(valor);
    return d.toLocaleString("es-PE", {
      day: "2-digit", month: "2-digit", year: "numeric",
      hour: "2-digit", minute: "2-digit", hour12: false,
    });
  }
  return String(valor);
}

/** RFC 4180: se doblan las comillas y se entrecomilla si hay ; " o salto. */
function escapar(s) {
  const t = String(s).replace(/"/g, '""');
  return /[";\n\r]/.test(t) ? `"${t}"` : t;
}

/**
 * @param {string} nombre  nombre base del archivo, sin extensión
 * @param {Array<{key:string,label:string,tipo?:string,valor?:Function}>} columnas
 * @param {Array<Object>} filas
 */
export function exportarExcel(nombre, columnas, filas) {
  const lineas = [columnas.map((c) => escapar(c.label)).join(";")];

  for (const fila of filas) {
    lineas.push(
      columnas.map((c) => escapar(celda(c.valor ? c.valor(fila) : fila[c.key], c.tipo))).join(";"),
    );
  }

  // El BOM es lo que hace que Excel respete los acentos.
  const blob = new Blob(["﻿" + lineas.join("\r\n")], { type: "text/csv;charset=utf-8;" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = `${nombre}-${new Date().toLocaleDateString("en-CA")}.csv`;
  a.click();
  URL.revokeObjectURL(a.href);
  return filas.length;
}
