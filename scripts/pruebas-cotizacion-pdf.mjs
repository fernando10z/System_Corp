/**
 * Importación de la cotización desde PDF, contra la API real.
 *
 * Comprueba el circuito entero: leer el PDF sin guardar nada, cargar la
 * cotización con lo leído, archivar el documento y volver a abrirlo. Y que la
 * descarga esté acotada al cliente, que era el agujero por el que antes se
 * podía pedir cualquier archivo con sólo conocer su clave de almacén.
 *
 * El PDF se construye aquí mismo, sin comprimir: así se ve en el diff qué dice
 * el documento de prueba. La variedad de formatos (coma decimal, dólares,
 * escaneos) se prueba en los tests unitarios del intérprete.
 */
import { conEsperaSi429 } from "./lib/login.mjs";
const BASE = process.env.API_BASE_URL ?? "http://localhost:3200/api";
let token = null;
let yo = null;
const est = {};
const fallos = [];
let ok = 0;

const j = (v) => JSON.stringify(v);

async function api(path, { method = "GET", body } = {}) {
  const res = await fetch(BASE + path, {
    method,
    headers: {
      ...(body ? { "Content-Type": "application/json" } : {}),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  return { status: res.status, payload: await res.json().catch(() => null) };
}

async function subir(path, archivo, campos = {}) {
  const fd = new FormData();
  for (const [k, v] of Object.entries(campos)) fd.append(k, v);
  fd.append("archivo", new Blob([archivo.bytes], { type: "application/pdf" }), archivo.nombre);
  const res = await fetch(BASE + path, {
    method: "POST",
    headers: { Authorization: `Bearer ${token}` },
    body: fd,
  });
  return { status: res.status, payload: await res.json().catch(() => null) };
}

async function paso(nombre, fn) {
  try {
    const r = await fn();
    ok++;
    console.log(`  ✓ ${nombre}`);
    return r;
  } catch (e) {
    fallos.push(`${nombre} → ${e.message}`);
    console.log(`  ✗ ${nombre} — ${e.message}`);
    return null;
  }
}

function exigir(r, cond, msg) {
  if (!cond) throw new Error(`${msg} · HTTP ${r.status} ${j(r.payload)?.slice(0, 300)}`);
}
function datos(r) {
  exigir(r, r.status < 400 && r.payload?.ok !== false, "respuesta no ok");
  return r.payload.data;
}
function igual(actual, esperado, que) {
  if (String(actual) !== String(esperado)) throw new Error(`${que}: se leyó ${j(actual)}, se esperaba ${j(esperado)}`);
}

// ── PDF de prueba ───────────────────────────────────────────────────────────
const COTIZACION = `MECANICA INDUSTRIAL DEL SUR S.A.C.
RUC: 20512345671
Av. Argentina 3450, Callao - Lima

COTIZACION N° COT-2026-0187
Fecha de emision: 14/03/2026

Señores: DEMO INDUSTRIAL S.A.C.
RUC: 20601234565

1  Rebobinado de motor trifasico 15 HP      2,850.00
2  Cambio de rodamientos SKF 6308-2RS         370.00
3  Balanceo dinamico de rotor                 420.00
4  Mano de obra y pruebas en vacio            310.00

                     Subtotal        S/  3,950.00
                     IGV (18%)       S/    711.00
                     TOTAL A PAGAR   S/  4,661.00

Plazo de entrega: 12 dias calendario
Validez de la oferta: 30 dias`;

function construirPdf(texto) {
  const escapar = (s) => s.replace(/\\/g, "\\\\").replace(/\(/g, "\\(").replace(/\)/g, "\\)");
  const flujo = texto
    .split("\n")
    .filter((l) => l.trim())
    .map((l, i) => `BT /F1 10 Tf 1 0 0 1 56 ${786 - i * 14} Tm (${escapar(l)}) Tj ET`)
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
  const offs = [];
  let cursor = partes[0].length;
  objetos.forEach((cuerpo, i) => {
    offs.push(cursor);
    const b = cuerpo === null
      ? Buffer.concat([
          Buffer.from(`${i + 1} 0 obj\n<< /Length ${contenido.length} >>\nstream\n`, "latin1"),
          contenido,
          Buffer.from("\nendstream\nendobj\n", "latin1"),
        ])
      : Buffer.from(`${i + 1} 0 obj\n${cuerpo}\nendobj\n`, "latin1");
    partes.push(b);
    cursor += b.length;
  });
  partes.push(Buffer.from(
    `xref\n0 ${objetos.length + 1}\n0000000000 65535 f \n` +
    offs.map((d) => `${String(d).padStart(10, "0")} 00000 n \n`).join("") +
    `trailer\n<< /Size ${objetos.length + 1} /Root 1 0 R >>\nstartxref\n${cursor}\n%%EOF\n`,
    "latin1"));
  return Buffer.concat(partes);
}

const PDF = { nombre: "COT-2026-0187.pdf", bytes: construirPdf(COTIZACION) };

// ── Recorrido ───────────────────────────────────────────────────────────────
console.log("\n── importación de cotización desde PDF ───────────────────────");

/**
 * El bloque de seguridad de la suite gasta a propósito los intentos de login
 * permitidos por minuto. Entrar aquí a continuación choca con ese límite, que
 * es exactamente lo que debe pasar: se espera a que la ventana se renueve en
 * vez de relajar la protección para que las pruebas sean cómodas.
 */
await paso("POST /auth/login", async () => {
  const d = datos(await conEsperaSi429(() => api("/auth/login", {
    method: "POST",
    body: { email: "admin@mip.local", password: "CambiarEnDeploy2026" },
  })));
  token = d.accessToken;
  yo = d.usuario;
});

await paso("preparar una OT en cotización", async () => {
  const arbol = datos(await api("/organizacion/arbol"));
  const sucursal = arbol[0];
  const empresa = sucursal?.empresas?.[0];
  const area = empresa?.areas?.[0];
  if (!area) throw new Error("la organización sembrada no llega hasta un área");

  const tipos = datos(await api("/catalogos?tipo=tipo_mantenimiento")).tipo_mantenimiento ?? [];
  if (!tipos.length) throw new Error("catálogo tipo_mantenimiento vacío");

  const sol = datos(await api("/solicitudes", {
    method: "POST",
    body: {
      titulo: "Motor del extractor con ruido (prueba de importación de PDF)",
      descripcion: "Ruido metálico creciente en el conjunto motriz del extractor de la nave 2.",
      lugar: "Nave 2, nivel 0",
      areaId: area.id,
      enviar: true,
    },
  }));
  await api(`/solicitudes/${sol.id}/tomar-revision`, { method: "POST", body: {} });

  est.ot = datos(await api("/ot", {
    method: "POST",
    body: {
      solicitudId: sol.id, areaId: area.id, sucursalId: sucursal.id,
      empresaRucId: empresa.id, tipoMantenimientoId: tipos[0].id,
      prioridadTecnica: "media", coordinadorId: yo.id, esEmergencia: false,
    },
  }));

  // El diagnóstico es lo que mueve la OT a 'en_diagnostico'; sin él no se
  // admite cargar una cotización.
  datos(await api(`/ot/${est.ot.id}/diagnosticos`, {
    method: "POST",
    body: {
      diagnostico: "Rodamiento del lado libre con juego axial y 78 °C en marcha.",
      causaProbable: "Desalineación acumulada por asentamiento de la base.",
      alcance: "Sólo el conjunto motriz; la bancada queda fuera.",
      trabajoARealizar: "Desmontar, reemplazar rodamientos, alinear y probar 2 h.",
    },
  }));
});

await paso("POST /cotizaciones/leer-pdf devuelve los campos del documento", async () => {
  const r = await subir("/cotizaciones/leer-pdf", PDF);
  const d = datos(r);
  exigir(r, d.textoDetectado === true, "no detectó texto en el PDF");
  igual(d.campos.proveedorRuc?.valor, "20512345671", "RUC del proveedor");
  igual(d.campos.numeroCotizacion?.valor, "COT-2026-0187", "número de cotización");
  igual(d.campos.fecha?.valor, "2026-03-14", "fecha del documento");
  igual(d.campos.monto?.valor, "4661", "importe total");
  igual(d.campos.moneda?.valor, "PEN", "moneda");
  igual(d.campos.plazoOfrecidoDias?.valor, "12", "plazo ofrecido");
  igual(d.campos.validezDias?.valor, "30", "validez");
  if (!/MECANICA INDUSTRIAL DEL SUR/.test(d.campos.proveedorNombre?.valor ?? ""))
    throw new Error(`razón social: se leyó ${j(d.campos.proveedorNombre?.valor)}`);
  est.leido = d;
});

await paso("cada campo trae la confianza y la línea que lo respalda", async () => {
  const c = est.leido.campos;
  igual(c.monto.confianza, "alta", "confianza del importe (salió de la línea TOTAL)");
  if (!/4,661/.test(c.monto.evidencia)) throw new Error(`evidencia del importe: ${j(c.monto.evidencia)}`);
  if (!c.fecha.evidencia?.includes("14/03/2026")) throw new Error("la fecha no trae su línea de respaldo");
});

await paso("leer el PDF NO crea ninguna cotización", async () => {
  const cots = datos(await api(`/ot/${est.ot.id}/cotizaciones`));
  if (cots.length !== 0) throw new Error(`la lectura dejó ${cots.length} cotización(es) guardadas`);
});

await paso("cargar la cotización con lo leído, incluida la validez", async () => {
  const c = est.leido.campos;
  est.cot = datos(await api(`/ot/${est.ot.id}/cotizaciones`, {
    method: "POST",
    body: {
      proveedorNombre: c.proveedorNombre.valor,
      proveedorRuc: c.proveedorRuc.valor,
      numeroCotizacion: c.numeroCotizacion.valor,
      fecha: c.fecha.valor,
      monto: c.monto.valor,
      moneda: c.moneda.valor,
      plazoOfrecidoDias: c.plazoOfrecidoDias.valor,
      validezDias: c.validezDias.valor,
    },
  }));
});

await paso("la fecha y la validez se guardaron de verdad", async () => {
  const vig = datos(await api(`/ot/${est.ot.id}/cotizaciones`)).find((c) => c.vigente);
  if (!vig) throw new Error("no quedó una cotización vigente");
  igual(vig.validez_dias, "30", "validez guardada");
  igual(String(vig.fecha).slice(0, 10), "2026-03-14", "fecha guardada");
  igual(vig.numero, "COT-2026-0187", "número guardado");
});

await paso("archivar el PDF junto a la cotización", async () => {
  const d = datos(await subir("/adjuntos", PDF, {
    entidadTipo: "cotizacion",
    entidadId: est.cot.id,
    etapa: "cotizacion",
    otId: est.ot.id,
  }));
  est.adjunto = d;
});

await paso("el PDF aparece colgado de esa versión de la cotización", async () => {
  const vig = datos(await api(`/ot/${est.ot.id}/cotizaciones`)).find((c) => c.vigente);
  const a = (vig.adjuntos ?? []).find((x) => x.nombre === PDF.nombre);
  if (!a) throw new Error(`la cotización no lista el PDF: ${j(vig.adjuntos)}`);
  est.adjuntoId = a.id;
});

await paso("GET /adjuntos/:id/descarga devuelve una URL temporal", async () => {
  const d = datos(await api(`/adjuntos/${est.adjuntoId}/descarga`));
  if (!/^https?:\/\//.test(d.url ?? "")) throw new Error(`URL inesperada: ${j(d.url)}`);
  igual(d.nombre, PDF.nombre, "nombre del archivo");
  if ("storage_key" in d) throw new Error("la respuesta expone la clave del almacén");
  const res = await fetch(d.url);
  if (!res.ok) throw new Error(`la URL firmada no sirve el archivo: HTTP ${res.status}`);
  const bytes = Buffer.from(await res.arrayBuffer());
  if (!bytes.equals(PDF.bytes)) throw new Error("el archivo descargado no es el que se subió");
});

await paso("un adjunto que no existe no revela nada", async () => {
  const r = await api("/adjuntos/00000000-0000-0000-0000-000000000000/descarga");
  if (r.status < 400 && r.payload?.ok !== false) throw new Error("devolvió ok para un id inexistente");
});

await paso("un PDF sin capa de texto se admite pero avisa", async () => {
  const d = datos(await subir("/cotizaciones/leer-pdf", {
    nombre: "escaneo.pdf",
    bytes: construirPdf("Cotizacion"),
  }));
  if (d.textoDetectado !== false) throw new Error("dijo haber leído un documento sin texto");
  if (!/escaneo|foto/i.test(d.aviso ?? "")) throw new Error(`aviso poco claro: ${j(d.aviso)}`);
});

await paso("un archivo que no es PDF se rechaza", async () => {
  const r = await subir("/cotizaciones/leer-pdf", {
    nombre: "trampa.pdf",
    bytes: Buffer.from("GIF89a esto no es un PDF", "latin1"),
  });
  if (r.status < 400) throw new Error("aceptó un archivo que no es PDF");
});

console.log(`\n${fallos.length ? "✗" : "✓"} ${ok} comprobaciones correctas · ${fallos.length} fallo(s)`);
if (fallos.length) {
  for (const f of fallos) console.log(`   · ${f}`);
  process.exit(1);
}
