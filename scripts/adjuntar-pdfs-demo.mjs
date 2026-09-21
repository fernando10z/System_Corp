/**
 * Archiva el PDF de cada cotización de demostración.
 *
 * Va DESPUÉS de repartir las fechas, no durante la siembra: ese reparto mueve
 * la fecha de la cotización hacia atrás para que encaje con la edad de su OT, y
 * un PDF generado antes acabaría diciendo una fecha distinta a la de la ficha.
 * Un documento que contradice al sistema es peor que no tener documento.
 *
 *   node scripts/adjuntar-pdfs-demo.mjs
 */
import { conEsperaSi429 } from "./lib/login.mjs";
import { pdfDeCotizacion } from "./lib/pdf-cotizacion.mjs";

const BASE = process.env.API_BASE_URL ?? "http://localhost:3200/api";
let T = null;

async function api(path, { method = "GET", body } = {}) {
  const res = await fetch(BASE + path, {
    method,
    headers: { ...(body ? { "Content-Type": "application/json" } : {}), ...(T ? { Authorization: `Bearer ${T}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  const payload = await res.json().catch(() => null);
  if (res.status >= 400 || payload?.ok === false) {
    throw new Error(`${method} ${path} → ${res.status} ${JSON.stringify(payload?.error ?? payload).slice(0, 180)}`);
  }
  return payload.data;
}

const entrada = await conEsperaSi429(async () => {
  const res = await fetch(`${BASE}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: "admin@mip.local", password: process.env.CLAVE_ADMIN ?? "CambiarEnDeploy2026" }),
  });
  return { status: res.status, payload: await res.json().catch(() => null) };
});
T = entrada.payload?.data?.accessToken;
if (!T) throw new Error(`no se pudo entrar: ${JSON.stringify(entrada.payload).slice(0, 180)}`);

const ots = await api("/ot?page=1&pageSize=200");
let archivados = 0;

for (const o of ots) {
  const ficha = await api(`/ot/${o.id}`);
  for (const c of ficha.cotizaciones ?? []) {
    // Sólo las que tienen datos que mostrar y todavía no tienen documento.
    if (!c.monto || !c.numero || (c.adjuntos ?? []).length) continue;

    const fd = new FormData();
    fd.append("entidadTipo", "cotizacion");
    fd.append("entidadId", c.id);
    fd.append("etapa", "cotizacion");
    fd.append("otId", o.id);
    fd.append("archivo", new Blob([pdfDeCotizacion(c)], { type: "application/pdf" }), `${c.numero}.pdf`);

    const res = await fetch(`${BASE}/adjuntos`, { method: "POST", headers: { Authorization: `Bearer ${T}` }, body: fd });
    if (!res.ok) throw new Error(`adjuntar ${c.numero} → ${res.status}`);
    archivados++;
  }
}

console.log(`  · ${archivados} PDF de cotización archivados, con la fecha que ya tiene la ficha`);
