/**
 * Interpretación de una cotización de proveedor a partir de su texto.
 *
 * Esto NO es OCR ni un modelo de lenguaje: es lectura de la capa de texto que
 * el propio PDF ya trae, más reglas sobre cómo se escriben las cotizaciones en
 * el Perú. La decisión de mantenerlo así es deliberada (cap. 38): el documento
 * de un proveedor no sale de la red del cliente, no cuesta por página y no hay
 * nada que un área legal tenga que autorizar.
 *
 * El precio de esa decisión es que un PDF escaneado —una foto, un fax— no tiene
 * texto que leer. Eso no se disimula: se devuelve `textoDetectado: false` y la
 * persona llena el formulario a mano, como hasta ahora.
 *
 * Ningún campo se da por bueno solo. Cada uno sale con la confianza con la que
 * se obtuvo y con la línea del documento que lo respalda, para que quien
 * confirma vea de dónde salió el número antes de aceptarlo.
 */

/** `alta` = la etiqueta estaba escrita. `media` = se dedujo por posición o por descarte. */
export type Confianza = "alta" | "media";

export interface CampoLeido<T = string> {
  valor: T;
  confianza: Confianza;
  /** La línea del PDF de la que salió: es lo que se le muestra a quien confirma. */
  evidencia: string;
}

export interface CamposCotizacion {
  proveedorNombre?: CampoLeido;
  proveedorRuc?: CampoLeido;
  numeroCotizacion?: CampoLeido;
  fecha?: CampoLeido;
  monto?: CampoLeido<number>;
  moneda?: CampoLeido;
  plazoOfrecidoDias?: CampoLeido<number>;
  validezDias?: CampoLeido<number>;
}

export interface LecturaCotizacion {
  textoDetectado: boolean;
  campos: CamposCotizacion;
  /** Explicación para la persona cuando la lectura no sirvió o quedó coja. */
  aviso?: string;
}

const MESES = [
  "enero",
  "febrero",
  "marzo",
  "abril",
  "mayo",
  "junio",
  "julio",
  "agosto",
  "setiembre",
  "octubre",
  "noviembre",
  "diciembre",
];

/** Sin tildes y en mayúsculas: los PDFs no son consistentes con los acentos. */
const plano = (s: string) =>
  s.normalize("NFD").replace(/[̀-ͯ]/g, "").toUpperCase().replace(/\s+/g, " ").trim();

/**
 * Un importe escrito a la peruana (1,234.56) o a la europea (1.234,56).
 * Se decide por cuál separador aparece de último: ese es el decimal.
 */
export function aNumero(texto: string): number | null {
  const limpio = texto.replace(/[^\d.,]/g, "");
  if (!/\d/.test(limpio)) return null;
  const coma = limpio.lastIndexOf(",");
  const punto = limpio.lastIndexOf(".");
  const normal =
    coma > punto ? limpio.replace(/\./g, "").replace(",", ".") : limpio.replace(/,/g, "");
  const n = Number(normal);
  return Number.isFinite(n) ? n : null;
}

/** Dígito verificador del RUC (módulo 11). Evita confundir un RUC con cualquier número de 11 cifras. */
export function rucValido(ruc: string): boolean {
  if (!/^\d{11}$/.test(ruc)) return false;
  const pesos = [5, 4, 3, 2, 7, 6, 5, 4, 3, 2];
  const suma = pesos.reduce((a, p, i) => a + Number(ruc[i]) * p, 0);
  const resto = 11 - (suma % 11);
  return (resto === 10 ? 0 : resto === 11 ? 1 : resto) === Number(ruc[10]);
}

/** Devuelve ISO `yyyy-mm-dd` o null. Rechaza lo que no es una fecha real. */
function aFechaIso(dia: number, mes: number, anio: number): string | null {
  if (anio < 100) anio += 2000;
  if (mes < 1 || mes > 12 || dia < 1 || dia > 31 || anio < 2000 || anio > 2100) return null;
  const d = new Date(Date.UTC(anio, mes - 1, dia));
  if (d.getUTCMonth() !== mes - 1 || d.getUTCDate() !== dia) return null;
  return d.toISOString().slice(0, 10);
}

function buscarFecha(linea: string): string | null {
  const dmy = linea.match(/\b(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2,4})\b/);
  if (dmy) return aFechaIso(Number(dmy[1]), Number(dmy[2]), Number(dmy[3]));

  const iso = linea.match(/\b(\d{4})-(\d{2})-(\d{2})\b/);
  if (iso) return aFechaIso(Number(iso[3]), Number(iso[2]), Number(iso[1]));

  const larga = plano(linea).match(/\b(\d{1,2})\s+DE\s+([A-Z]+)\s+DE\s+(\d{4})\b/);
  if (larga) {
    const mes = MESES.findIndex(
      (m) => plano(m) === larga[2] || plano(m).startsWith(larga[2].slice(0, 4)),
    );
    if (mes >= 0) return aFechaIso(Number(larga[1]), mes + 1, Number(larga[3]));
  }
  return null;
}

/** Líneas que nombran al cliente, no al proveedor: su RUC no es el que buscamos. */
const ES_LINEA_DE_CLIENTE =
  /SE[NÑ]OR(?:ES)?|CLIENTE|FACTURAR|RAZON SOCIAL DEL CLIENTE|ATENCION|DIRIGIDO A/;
/** Sufijos societarios peruanos: delatan una razón social. */
const SUFIJO_SOCIETARIO =
  /\b(S\.?A\.?C\.?|S\.?A\.?A\.?|S\.?A\.?|E\.?I\.?R\.?L\.?|S\.?R\.?L\.?|S\.?C\.?R\.?L\.?)\.?$/;

export interface OpcionesLectura {
  /** RUCs del propio cliente: si aparecen en el PDF son el destinatario, no el proveedor. */
  rucsPropios?: string[];
}

export function interpretarCotizacion(
  texto: string,
  opciones: OpcionesLectura = {},
): LecturaCotizacion {
  const lineas = texto
    .split("\n")
    .map((l) => l.replace(/\s+/g, " ").trim())
    .filter(Boolean);
  const planas = lineas.map(plano);

  if (lineas.join("").length < 60) {
    return {
      textoDetectado: false,
      campos: {},
      aviso:
        "Este PDF no tiene texto: es un escaneo o una foto. El archivo queda adjunto igual, " +
        "pero los datos hay que escribirlos a mano.",
    };
  }

  const campos: CamposCotizacion = {};
  const propios = new Set((opciones.rucsPropios ?? []).map((r) => r.replace(/\D/g, "")));

  // ── RUC y proveedor ────────────────────────────────────────────────────────
  // Una cotización trae al menos dos RUC: el de quien la emite (membrete) y el
  // del cliente ("Señores: ..."). Se descartan los del propio cliente y los que
  // cuelgan de una línea que nombra al destinatario; queda el del proveedor.
  const candidatos: Array<{ ruc: string; i: number }> = [];
  planas.forEach((l, i) => {
    // "Señores: ACME S.A.C." y debajo "RUC: 20...": el RUC del destinatario
    // casi nunca comparte línea con la palabra que lo delata, así que también
    // se mira la línea inmediatamente anterior.
    if (ES_LINEA_DE_CLIENTE.test(l)) return;
    if (i > 0 && ES_LINEA_DE_CLIENTE.test(planas[i - 1]) && /^R\.?\s?U\.?\s?C\.?\b/.test(l)) return;
    for (const m of l.matchAll(/\b(?:10|15|16|17|20)\d{9}\b/g)) {
      if (rucValido(m[0]) && !propios.has(m[0])) candidatos.push({ ruc: m[0], i });
    }
  });

  if (candidatos.length) {
    const elegido = candidatos[0];
    campos.proveedorRuc = {
      valor: elegido.ruc,
      confianza: candidatos.length === 1 ? "alta" : "media",
      evidencia: lineas[elegido.i],
    };

    // La razón social suele estar en la misma línea que el RUC; si no, es el
    // membrete inmediatamente anterior con sufijo societario.
    const restoDeLaLinea = lineas[elegido.i]
      .replace(elegido.ruc, "")
      .replace(/R\.?\s?U\.?\s?C\.?/i, "")
      .replace(/[:\-–|]/g, " ")
      .replace(/\s+/g, " ")
      .trim();

    if (restoDeLaLinea.length >= 4) {
      campos.proveedorNombre = {
        valor: restoDeLaLinea,
        confianza: "alta",
        evidencia: lineas[elegido.i],
      };
    } else {
      const arriba = lineas.slice(0, elegido.i).reverse();
      const conSufijo = arriba.find((l) => SUFIJO_SOCIETARIO.test(plano(l)));
      const membrete = conSufijo ?? arriba.find((l) => l.length >= 4);
      if (membrete) {
        campos.proveedorNombre = {
          valor: membrete,
          confianza: conSufijo ? "alta" : "media",
          evidencia: membrete,
        };
      }
    }
  }

  // ── Número de cotización ───────────────────────────────────────────────────
  // Se exige que el código tenga al menos un dígito: así "COTIZACION VALIDA"
  // no se confunde con un número de documento.
  //
  // Las abreviaturas del "número" van de la más larga a la más corta: si "N"
  // se probara antes que "NRO", se comería la ene de "Nro." y el código
  // empezaría a leerse en medio de la palabra.
  for (let i = 0; i < planas.length; i++) {
    const m = planas[i].match(
      /\b(?:COTIZACION|COTIZ|PROFORMA|PRESUPUESTO|ORDEN DE SERVICIO)\b\s*(?:NUMERO|NRO|NUM|N[°º]?|#)?\s*[:.\-]?\s*([A-Z0-9][A-Z0-9\-/.]{2,24})/,
    );
    if (m && /\d/.test(m[1])) {
      campos.numeroCotizacion = {
        valor: m[1].replace(/[.]+$/, ""),
        confianza: "alta",
        evidencia: lineas[i],
      };
      break;
    }
  }

  // ── Fecha ──────────────────────────────────────────────────────────────────
  const iEtiquetada = planas.findIndex((l) => /\b(?:FECHA|EMISION|EXPEDICION)\b/.test(l));
  if (iEtiquetada >= 0) {
    const f = buscarFecha(lineas[iEtiquetada]);
    if (f) campos.fecha = { valor: f, confianza: "alta", evidencia: lineas[iEtiquetada] };
  }
  if (!campos.fecha) {
    for (let i = 0; i < lineas.length; i++) {
      const f = buscarFecha(lineas[i]);
      if (f) {
        campos.fecha = { valor: f, confianza: "media", evidencia: lineas[i] };
        break;
      }
    }
  }

  // ── Importe ────────────────────────────────────────────────────────────────
  // El total es la última línea que dice TOTAL sin ser subtotal, IGV ni
  // descuento. Se toma el ÚLTIMO número de esa línea porque a la izquierda
  // suele venir la base o el porcentaje.
  const esTotal = (l: string) =>
    /\bTOTAL\b|\bIMPORTE TOTAL\b|\bTOTAL A PAGAR\b|\bMONTO TOTAL\b/.test(l) &&
    !/SUB\s?TOTAL|\bIGV\b|IMPUESTO|DESCUENTO|TOTAL ITEMS|TOTAL CANT/.test(l);

  let iTotal = -1;
  for (let i = planas.length - 1; i >= 0; i--) {
    if (esTotal(planas[i])) {
      iTotal = i;
      break;
    }
  }

  const numerosDe = (l: string) =>
    [...l.matchAll(/\d[\d.,]*\d|\d/g)]
      .map((m) => aNumero(m[0]))
      .filter((n): n is number => n !== null);

  if (iTotal >= 0) {
    const ns = numerosDe(lineas[iTotal]).filter((n) => n > 0);
    if (ns.length) {
      campos.monto = { valor: ns[ns.length - 1], confianza: "alta", evidencia: lineas[iTotal] };
    }
  }
  if (!campos.monto) {
    // Sin línea de total: el importe más alto del documento es la mejor
    // apuesta, pero se marca como dudoso para que alguien lo mire.
    let mejor: { n: number; i: number } | null = null;
    lineas.forEach((l, i) => {
      if (/\b(?:RUC|TELF|TEL|CEL|FAX|CUENTA|CCI)\b/.test(plano(l))) return;
      for (const n of numerosDe(l)) if (n >= 10 && (!mejor || n > mejor.n)) mejor = { n, i };
    });
    if (mejor) {
      const m = mejor as { n: number; i: number };
      campos.monto = { valor: m.n, confianza: "media", evidencia: lineas[m.i] };
    }
  }

  // ── Moneda ─────────────────────────────────────────────────────────────────
  // Se mira primero la línea del total: si ahí dice S/ o US$, esa es la moneda
  // del importe, aunque el resto del documento mencione otra.
  const detectarMoneda = (l: string): string | null => {
    if (/US\$|USD|DOLAR/.test(l)) return "USD";
    if (/\bEUR\b|€|EURO/.test(l)) return "EUR";
    if (/S\/|\bPEN\b|SOLES/.test(l)) return "PEN";
    return null;
  };
  const enTotal = iTotal >= 0 ? detectarMoneda(planas[iTotal]) : null;
  if (enTotal) {
    campos.moneda = { valor: enTotal, confianza: "alta", evidencia: lineas[iTotal] };
  } else {
    const i = planas.findIndex((l) => detectarMoneda(l));
    if (i >= 0) {
      campos.moneda = {
        valor: detectarMoneda(planas[i]) as string,
        confianza: "media",
        evidencia: lineas[i],
      };
    }
  }

  // ── Plazo y validez ────────────────────────────────────────────────────────
  const diasPor = (re: RegExp): CampoLeido<number> | undefined => {
    for (let i = 0; i < planas.length; i++) {
      const m = planas[i].match(re);
      if (m) {
        const n = Number(m[1]);
        if (n > 0 && n <= 365) return { valor: n, confianza: "alta", evidencia: lineas[i] };
      }
    }
    return undefined;
  };

  campos.plazoOfrecidoDias = diasPor(
    /\bPLAZO\b(?:\s+DE)?(?:\s+(?:ENTREGA|EJECUCION|ATENCION))?[^0-9]{0,30}(\d{1,3})\s*DIAS/,
  );
  campos.validezDias = diasPor(/\b(?:VALIDEZ|VALID[AO]|VIGENCIA)\b[^0-9]{0,40}(\d{1,3})\s*DIAS/);

  const faltan = (["proveedorNombre", "monto"] as const).filter((k) => !campos[k]);
  return {
    textoDetectado: true,
    campos,
    aviso: faltan.length
      ? "No se pudo leer todo: revise los campos vacíos antes de guardar."
      : undefined,
  };
}
