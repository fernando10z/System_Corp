/**
 * Revisión de seguridad: lo que mira el área de sistemas de un cliente grande
 * antes de firmar. No prueba que el producto funcione — prueba que NO deja
 * hacer lo que no debe.
 */
import { conEsperaSi429 } from "./lib/login.mjs";
const BASE = process.env.API_BASE_URL ?? "http://localhost:3200/api";
const fallos = [];
let ok = 0;

async function api(path, { method = "GET", body, token } = {}) {
  const res = await fetch(BASE + path, {
    method,
    headers: { ...(body ? { "Content-Type": "application/json" } : {}), ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  return { status: res.status, payload: await res.json().catch(() => null) };
}

function bien(nombre) { ok++; console.log(`  ✓ ${nombre}`); }
function mal(nombre, detalle) { fallos.push(`${nombre} — ${detalle}`); console.log(`  ✗ ${nombre} — ${detalle}`); }

/** Debe responder 401/403, o {ok:false} con código de permiso. */
async function debeDenegar(nombre, fn) {
  try {
    const r = await fn();
    const denegado =
      r.status === 401 || r.status === 403 || r.status === 404 || r.status === 429 ||
      (r.payload?.ok === false && /PERMISO|FORBIDDEN|UNAUTHORIZED|permis|autoriz/i.test(JSON.stringify(r.payload.error ?? "")));
    if (denegado) bien(nombre);
    else mal(nombre, `PERMITIDO · HTTP ${r.status} ${JSON.stringify(r.payload).slice(0, 220)}`);
  } catch (e) { mal(nombre, e.message); }
}
async function debePermitir(nombre, fn) {
  try {
    const r = await fn();
    if (r.status < 400 && r.payload?.ok !== false) bien(nombre);
    else mal(nombre, `DENEGADO indebidamente · ${JSON.stringify(r.payload).slice(0, 200)}`);
  } catch (e) { mal(nombre, e.message); }
}

const login = async (email, password) => {
  const r = await conEsperaSi429(() => api("/auth/login", { method: "POST", body: { email, password } }));
  return r.payload?.data ?? null;
};

console.log("\n── preparación: un usuario por rol ───────────────────────────");
const admin = await login("admin@mip.local", "CambiarEnDeploy2026");
if (!admin) { console.log("  ✗ no se pudo entrar como admin"); process.exit(1); }
const T = admin.accessToken;
const CLAVE = "ClaveDePrueba2026";
const sello = Date.now().toString().slice(-7);
const cuentas = {};

for (const rol of ["solicitante", "tecnico", "coordinador", "abastecimiento", "gerencia"]) {
  const email = `${rol}${sello}@mip.local`;
  const r = await api("/usuarios", {
    method: "POST", token: T,
    body: { nombres: rol, apellidos: "Prueba", email, password: CLAVE, rolCodigos: [rol] },
  });
  if (r.payload?.ok === false) { console.log(`  ✗ alta de ${rol}: ${JSON.stringify(r.payload.error)}`); continue; }
  const s = await login(email, CLAVE);
  if (!s) { console.log(`  ✗ login de ${rol}`); continue; }
  cuentas[rol] = s;
  console.log(`  ✓ ${rol} · ${s.usuario.permisos.length} permisos`);
}

// Una OT real sobre la que intentar cosas.
const arbol = (await api("/organizacion/arbol", { token: T })).payload.data;
const emp = arbol.flatMap((s) => s.empresas ?? []).find((e) => (e.areas ?? []).length);
const area = emp.areas[0];
const suc = arbol.find((s) => (s.empresas ?? []).some((e) => e.id === emp.id));
const tipos = (await api("/catalogos?tipo=tipo_mantenimiento", { token: T })).payload.data.tipo_mantenimiento;
const sol = (await api("/solicitudes", { method: "POST", token: T, body: { titulo: "OT para prueba de permisos", descripcion: "Se usa para comprobar qué puede hacer cada rol.", lugar: "Taller", areaId: area.id, enviar: true } })).payload.data;
await api(`/solicitudes/${sol.id}/tomar-revision`, { method: "POST", token: T, body: {} });
const ot = (await api("/ot", { method: "POST", token: T, body: { solicitudId: sol.id, areaId: area.id, sucursalId: suc.id, empresaRucId: emp.id, tipoMantenimientoId: tipos[0].id, prioridadTecnica: "media", coordinadorId: admin.usuario.id, esEmergencia: false } })).payload.data;
console.log(`  · OT de pruebas: ${ot?.numero_ot}`);

console.log("\n── 1 · Anexo B · el solicitante no puede operar ──────────────");
const S = cuentas.solicitante?.accessToken;
if (S) {
  await debeDenegar("solicitante NO crea OT", () => api("/ot", { method: "POST", token: S, body: { solicitudId: sol.id, areaId: area.id, sucursalId: suc.id, empresaRucId: emp.id, tipoMantenimientoId: tipos[0].id, prioridadTecnica: "media", coordinadorId: admin.usuario.id } }));
  await debeDenegar("solicitante NO registra diagnóstico", () => api(`/ot/${ot.id}/diagnosticos`, { method: "POST", token: S, body: { diagnostico: "x".repeat(20), causaProbable: "y".repeat(20), alcance: "z".repeat(20), trabajoARealizar: "w".repeat(20) } }));
  await debeDenegar("solicitante NO carga cotización", () => api(`/ot/${ot.id}/cotizaciones`, { method: "POST", token: S, body: { proveedorNombre: "X", monto: 1, moneda: "PEN" } }));
  await debeDenegar("solicitante NO cierra la OT", () => api(`/ot/${ot.id}/cerrar`, { method: "POST", token: S, body: {} }));
  await debeDenegar("solicitante NO ve costos", () => api("/costos/historico?moneda=PEN", { token: S }));
  await debeDenegar("solicitante NO lista usuarios", () => api("/usuarios", { token: S }));
  await debeDenegar("solicitante NO ve la auditoría", () => api("/auditoria", { token: S }));
  await debeDenegar("solicitante NO edita la configuración", () => api("/configuracion", { method: "PUT", token: S, body: { clave: "exige_conformidad", valor: true } }));
  await debePermitir("solicitante SÍ crea su solicitud", () => api("/solicitudes", { method: "POST", token: S, body: { titulo: "Reporte del solicitante", descripcion: "Una necesidad reportada por quien la detecta.", lugar: "Almacén", areaId: area.id, enviar: true } }));
}

console.log("\n── 2 · Anexo B · el técnico opera pero no cierra ─────────────");
const TE = cuentas.tecnico?.accessToken;
if (TE) {
  await debePermitir("técnico SÍ registra diagnóstico", () => api(`/ot/${ot.id}/diagnosticos`, { method: "POST", token: TE, body: { diagnostico: "Bomba con cavitación audible y caudal 20 % bajo.", causaProbable: "Impulsor erosionado.", alcance: "Sólo la bomba.", trabajoARealizar: "Reemplazar impulsor y sellos." } }));
  await debeDenegar("técnico NO cierra la OT", () => api(`/ot/${ot.id}/cerrar`, { method: "POST", token: TE, body: {} }));
  await debeDenegar("técnico NO cancela la OT", () => api(`/ot/${ot.id}/cancelar`, { method: "POST", token: TE, body: { observacion: "Intento indebido de cancelación por el técnico." } }));
  await debeDenegar("técnico NO crea derivadas", () => api(`/ot/${ot.id}/derivadas`, { method: "POST", token: TE, body: { motivoDerivacion: "Intento indebido de derivar desde el rol técnico." } }));
  await debeDenegar("técnico NO administra usuarios", () => api("/usuarios", { method: "POST", token: TE, body: { nombres: "A", apellidos: "B", email: `colado${sello}@mip.local`, password: CLAVE, rolCodigos: ["coordinador"] } }));
}

console.log("\n── 3 · gerencia sólo consulta ────────────────────────────────");
const G = cuentas.gerencia?.accessToken;
if (G) {
  await debePermitir("gerencia SÍ ve KPIs", () => api("/dashboard/kpis", { token: G }));
  await debeDenegar("gerencia NO registra diagnóstico", () => api(`/ot/${ot.id}/diagnosticos`, { method: "POST", token: G, body: { diagnostico: "x".repeat(20), causaProbable: "y".repeat(20), alcance: "z".repeat(20), trabajoARealizar: "w".repeat(20) } }));
  await debeDenegar("gerencia NO cierra la OT", () => api(`/ot/${ot.id}/cerrar`, { method: "POST", token: G, body: {} }));
}

console.log("\n── 4 · escalada de privilegios ───────────────────────────────");
if (S) {
  await debeDenegar("solicitante NO se concede permisos a su rol", async () => {
    const roles = (await api("/roles", { token: T })).payload.data;
    const rSol = roles.find((r) => r.codigo === "solicitante");
    return api(`/roles/${rSol.id}/permisos`, { method: "PUT", token: S, body: { permisos: ["ot:cerrar", "costos:ver", "usuarios:crear"] } });
  });
  await debeDenegar("solicitante NO se crea un usuario admin", () => api("/usuarios", { method: "POST", token: S, body: { nombres: "Escalada", apellidos: "Prueba", email: `escalada${sello}@mip.local`, password: CLAVE, rolCodigos: ["super_admin"] } }));
}

console.log("\n── 5 · aislamiento de tenant ─────────────────────────────────");
await debeDenegar("no se lee una OT con un id de otro tenant", () => api("/ot/00000000-0000-0000-0000-000000000001", { token: S ?? T }));
await debeDenegar("no se descarga un adjunto con un id de otro tenant", () => api("/adjuntos/00000000-0000-0000-0000-000000000001/descarga", { token: S ?? T }));
// La descarga se pedía antes por clave de almacén, sin que nada comprobara de
// quién era el archivo. Esa puerta ya no existe y esta comprobación vigila que
// no vuelva.
await debeDenegar("no se descarga un archivo por su clave de almacén", () =>
  api("/adjuntos/descarga?storageKey=" + encodeURIComponent("00000000-0000-0000-0000-000000000009/sin-ot/x.pdf"), { token: S ?? T }));
await debeDenegar("no se falsifica el tenant por cabecera", async () => {
  const res = await fetch(BASE + "/ot", { headers: { Authorization: `Bearer ${S ?? T}`, "X-Tenant-Id": "00000000-0000-0000-0000-000000000009" } });
  const p = await res.json().catch(() => null);
  // Debe ignorar la cabecera y devolver SÓLO lo del tenant del token.
  if (res.ok && Array.isArray(p?.data)) return { status: 999, payload: { ok: true, nota: "devolvió datos del propio tenant (correcto si ignora la cabecera)" } };
  return { status: res.status, payload: p };
});

console.log("\n── 6 · inyección SQL en los filtros ──────────────────────────");
const inyecciones = [
  "'; DROP TABLE core.orden_trabajo; --",
  "' OR '1'='1",
  "%' UNION SELECT NULL,NULL,NULL--",
  "\\'; SELECT pg_sleep(5); --",
];
for (const mal_ of inyecciones) {
  const nombre = `filtro buscar rechaza o neutraliza: ${mal_.slice(0, 26)}…`;
  try {
    const r = await api(`/ot?buscar=${encodeURIComponent(mal_)}&page=1&pageSize=5`, { token: T });
    if (r.status >= 500) mal(nombre, `HTTP 500 — el filtro rompe el SQL`);
    else bien(nombre);
  } catch (e) { mal(nombre, e.message); }
}
await debePermitir("la tabla sigue viva tras los intentos", () => api("/ot?page=1&pageSize=1", { token: T }));

console.log("\n── 7 · sesión y credenciales ─────────────────────────────────");
await debeDenegar("token manipulado rechazado", () => api("/ot", { token: T.slice(0, -6) + "AAAAAA" }));
await debeDenegar("token vacío rechazado", () => api("/ot", { token: "" }));
await debeDenegar("contraseña incorrecta rechazada", () => api("/auth/login", { method: "POST", body: { email: "admin@mip.local", password: "claveIncorrecta" } }));
await debeDenegar("usuario inexistente rechazado", () => api("/auth/login", { method: "POST", body: { email: "nadie@mip.local", password: CLAVE } }));

console.log("\n── 8 · fuerza bruta en el login ──────────────────────────────");
{
  // Cuenta desechable: machacar al admin lo dejaría bloqueado y rompería el
  // resto de la suite.
  const victima = `victima${sello}@mip.local`;
  await api("/usuarios", { method: "POST", token: T, body: { nombres: "Victima", apellidos: "Prueba", email: victima, password: CLAVE, rolCodigos: ["solicitante"] } });

  let http429 = 0, bloqueoCuenta = false;
  const intentos = 45;
  for (let i = 0; i < intentos; i++) {
    const r = await api("/auth/login", { method: "POST", body: { email: victima, password: "mal" + i } });
    if (r.status === 429) http429++;
    if (/bloquead/i.test(JSON.stringify(r.payload?.error ?? ""))) bloqueoCuenta = true;
  }

  if (http429 > 0) bien(`límite por IP activo: ${http429}/${intentos} intentos cortados con HTTP 429`);
  else mal("límite por IP en el login", `${intentos} intentos sin un solo 429`);

  // La segunda capa (bloqueo de la cuenta a los 5 fallos) vive en el SP y se
  // comprueba con db/scripts/smoke-bloqueo-credenciales.sql, porque por HTTP el
  // límite por IP responde antes y no deja llegar hasta ella.
  if (bloqueoCuenta) bien("bloqueo por cuenta alcanzado también por HTTP");
  else console.log("  · bloqueo por cuenta: lo tapó el límite por IP — se verifica en el smoke SQL");
}

console.log("\n── 9 · cabeceras de seguridad ────────────────────────────────");
{
  const res = await fetch(BASE + "/health");
  const esperadas = {
    "x-content-type-options": "nosniff",
    "x-frame-options": null,
    "strict-transport-security": null,
    "content-security-policy": null,
  };
  for (const [h] of Object.entries(esperadas)) {
    if (res.headers.get(h)) bien(`cabecera ${h} presente`);
    else mal(`cabecera ${h}`, "ausente");
  }
}

console.log("\n══════════════════════════════════════════════════════════════");
console.log(`comprobaciones superadas: ${ok}`);
console.log(`hallazgos: ${fallos.length}`);
fallos.forEach((f) => console.log("   ✗ " + f));
process.exit(fallos.length ? 1 : 0);
