/**
 * Puebla el sistema con un juego de datos de demostración.
 *
 * Todo se crea LLAMANDO A LA API, no insertando filas: así los diagnósticos se
 * versionan de verdad, los estados avanzan por su máquina y el árbol de
 * trazabilidad sale construido por el motor, con sus sellos y sus motivos. Unos
 * INSERT directos darían una pantalla bonita y una trazabilidad falsa.
 *
 * El volumen está medido para que ninguna pantalla se vea vacía y ninguna se
 * vea como un volcado: doce OT repartidas por todos los estados del Anexo A,
 * más la cola de solicitudes sin revisar que da sentido a la bandeja.
 *
 *   node scripts/datos-demo.mjs
 */
const BASE = process.env.API_BASE_URL ?? "http://localhost:3200/api";
const CLAVE_DEMO = process.env.CLAVE_DEMO ?? "Demo.MIP.2026";

let T = null;
const tokens = {};

async function api(path, { method = "GET", body, token = T } = {}) {
  const res = await fetch(BASE + path, {
    method,
    headers: { ...(body ? { "Content-Type": "application/json" } : {}), ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  const payload = await res.json().catch(() => null);
  if (res.status >= 400 || payload?.ok === false) {
    const e = payload?.error ?? payload;
    throw new Error(`${method} ${path} → ${res.status} ${JSON.stringify(e).slice(0, 220)}`);
  }
  return payload.data;
}

const paso = (t) => console.log(`  · ${t}`);

// ── entrada ─────────────────────────────────────────────────────────────────
T = (await api("/auth/login", { method: "POST", body: { email: "admin@mip.local", password: process.env.CLAVE_ADMIN ?? "CambiarEnDeploy2026" } })).accessToken;
const admin = await api("/auth/perfil");

const arbol = await api("/organizacion/arbol");
const suc = arbol[0];
const emp = suc.empresas[0];
const areas = Object.fromEntries(emp.areas.map((a) => [a.codigo, a]));
const tipos = (await api("/catalogos?tipo=tipo_mantenimiento")).tipo_mantenimiento;
const impactos = (await api("/catalogos?tipo=impacto_operativo")).impacto_operativo ?? [];
const tipoDe = (n) => (tipos.find((t) => new RegExp(n, "i").test(t.nombre)) ?? tipos[0]).id;

const trabajos = await api("/tipos-trabajo");
/** El tipo de trabajo es lo que agrupa el histórico de costos (cap. 32.4). */
const trabajoDe = (n) => (trabajos.find((t) => new RegExp(n, "i").test(t.nombre)) ?? trabajos[0]).id;

// ── 1 · equipo ──────────────────────────────────────────────────────────────
console.log("\n── equipo ────────────────────────────────────────────────────");
const PERSONAS = [
  { rol: "coordinador",    nombres: "Rosa",   apellidos: "Quispe Vargas",  cargo: "Coordinadora de mantenimiento" },
  { rol: "coordinador",    nombres: "Julio",  apellidos: "Paredes Ramos",  cargo: "Coordinador de taller" },
  { rol: "tecnico",        nombres: "Marco",  apellidos: "Tuesta Ríos",    cargo: "Técnico mecánico" },
  { rol: "tecnico",        nombres: "Elena",  apellidos: "Chávez Soto",    cargo: "Técnica electricista" },
  { rol: "tecnico",        nombres: "Víctor", apellidos: "Ramos Núñez",    cargo: "Técnico hidráulico" },
  { rol: "abastecimiento", nombres: "Carla",  apellidos: "Mendoza León",   cargo: "Analista de abastecimiento" },
  { rol: "solicitante",    nombres: "Pedro",  apellidos: "Aliaga Vera",    cargo: "Supervisor de producción" },
  { rol: "solicitante",    nombres: "Nancy",  apellidos: "Ortiz Huamán",   cargo: "Jefa de almacén" },
  { rol: "gerencia",       nombres: "Andrés", apellidos: "Ferrer Díaz",    cargo: "Gerente de operaciones" },
];

const gente = {};
for (const p of PERSONAS) {
  const email = `${p.nombres.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "")}.${p.apellidos.split(" ")[0].toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "")}@demoindustrial.pe`;
  const u = await api("/usuarios", { method: "POST", body: { ...p, email, password: CLAVE_DEMO, rolCodigos: [p.rol] } });
  gente[`${p.nombres} ${p.apellidos}`] = { ...u, email, rol: p.rol };
  tokens[email] = (await api("/auth/login", { method: "POST", body: { email, password: CLAVE_DEMO } })).accessToken;
}
paso(`${PERSONAS.length} personas dadas de alta`);

const rosa = gente["Rosa Quispe Vargas"];
const julio = gente["Julio Paredes Ramos"];
const marco = gente["Marco Tuesta Ríos"];
const elena = gente["Elena Chávez Soto"];
const victor = gente["Víctor Ramos Núñez"];
const pedro = gente["Pedro Aliaga Vera"];
const nancy = gente["Nancy Ortiz Huamán"];
const tokPedro = tokens[pedro.email];
const tokNancy = tokens[nancy.email];

// ── proveedores ─────────────────────────────────────────────────────────────
// Las cotizaciones se enlazan al PROVEEDOR del catálogo, no a un nombre suelto:
// es lo que permite después agrupar el histórico de costos por proveedor
// (cap. 32.4) y lo que deja el catálogo con contenido.
console.log("\n── proveedores ──────────────────────────────────────────────");
const PROVEEDORES = [
  { razonSocial: "SERVICIOS NEUMÁTICOS DEL PERÚ S.A.C.", ruc: "20512345671", contacto: "Luis Bravo", telefono: "987654321" },
  { razonSocial: "ELECTROMONTAJES ANDINOS S.R.L.",       ruc: "20487654320", contacto: "Sonia Rojas", telefono: "986123456" },
  { razonSocial: "HIDRÁULICA INDUSTRIAL LIMA S.A.C.",    ruc: "20456789014", contacto: "Jorge Salas", telefono: "985222111" },
  { razonSocial: "INSTRUMENTACIÓN Y CONTROL S.A.",       ruc: "20398765436", contacto: "Rocío Prado", telefono: "984333222" },
  { razonSocial: "RECTIFICACIONES DEL SUR S.A.C.",       ruc: "20555123451", contacto: "Iván Flores", telefono: "983444333" },
  { razonSocial: "PUERTAS Y ACCESOS INDUSTRIALES E.I.R.L.", ruc: "20567890121", contacto: "Dora Lino", telefono: "982555444" },
  { razonSocial: "SISTEMAS CONTRA INCENDIO S.A.C.",      ruc: "20601234565", contacto: "Raúl Cáceres", telefono: "981666555" },
];
const provs = {};
for (const pr of PROVEEDORES) {
  try {
    const v = await api("/proveedores", { method: "POST", body: pr });
    provs[pr.razonSocial] = v.id;
  } catch (e) {
    // El catálogo de proveedores NO es transaccional: sobrevive a la limpieza,
    // así que en una segunda siembra el alta choca y se reutiliza el existente.
    // Eso es lo esperado y no se anuncia. Cualquier otro error sí: un RUC mal
    // formado dejaría el catálogo vacío en silencio.
    if (!/CONFLICT|duplicate/i.test(e.message)) {
      console.log(`    ~ ${pr.razonSocial}: ${e.message.slice(0, 90)}`);
    }
  }
}
if (!Object.keys(provs).length) {
  for (const v of await api("/proveedores?pageSize=50")) provs[v.razon_social] = v.id;
}
paso(`${Object.keys(provs).length} proveedores en el catálogo`);

// ── utilidades ──────────────────────────────────────────────────────────────
async function solicitud({ titulo, descripcion, lugar, area = "PROD", quien = tokPedro, prioridad = "", enviar = true }) {
  return api("/solicitudes", { method: "POST", token: quien, body: {
    titulo, descripcion, lugar, areaId: areas[area].id,
    impactoOperativoId: impactos[0]?.id,
    // Un opcional vacío se omite: la API valida el enum y "" no es un valor.
    ...(prioridad ? { prioridadPercibida: prioridad } : {}),
    enviar } });
}

async function convertir(s, { prioridad = "media", coordinador = rosa, tipo = "correctivo", trabajo, emergencia = false, justificacion } = {}) {
  await api(`/solicitudes/${s.id}/tomar-revision`, { method: "POST", body: {} });
  return api("/ot", { method: "POST", body: {
    solicitudId: s.id, areaId: areas.PROD.id, sucursalId: suc.id, empresaRucId: emp.id,
    tipoMantenimientoId: tipoDe(tipo), prioridadTecnica: prioridad, coordinadorId: coordinador.id,
    ...(trabajo ? { tipoTrabajoId: trabajoDe(trabajo) } : {}),
    esEmergencia: emergencia, emergenciaJustificacion: justificacion } });
}

const diagnosticar = (ot, d, tok = T) => api(`/ot/${ot.id}/diagnosticos`, { method: "POST", token: tok, body: d });
/**
 * Carga la cotización tal como lo haría una persona desde la pantalla.
 *
 * El PDF NO se adjunta aquí: se archiva al final, cuando las fechas ya están
 * repartidas, para que el documento y la ficha digan lo mismo. Lo hace
 * scripts/adjuntar-pdfs-demo.mjs.
 */
async function cotizar(ot, c) {
  const fecha = new Date(Date.now() - 6 * 86_400_000).toISOString().slice(0, 10);
  // Si el proveedor está en el catálogo se enlaza por id; el nombre viaja igual
  // para que la cotización conserve el texto tal como llegó.
  return api(`/ot/${ot.id}/cotizaciones`, { method: "POST",
    body: { validezDias: 30, ...c, fecha, ...(provs[c.proveedorNombre] ? { proveedorId: provs[c.proveedorNombre] } : {}) } });
}

const iniciar = (ot, quien) => api(`/ot/${ot.id}/iniciar`, { method: "POST", body: { responsableId: quien.id } });
const avance = (ot, descripcion, tok = T) => api(`/ot/${ot.id}/avances`, { method: "POST", token: tok, body: { descripcion } });
const declarar = (ot, descripcion, tok = T) => api(`/ot/${ot.id}/trabajo-realizado`, { method: "POST", token: tok, body: { descripcion } });
const aprobar = (ot) => api(`/ot/${ot.id}/revisar`, { method: "POST", body: { resultado: "aprobado", observacion: "" } });
const mensaje = (ot, cuerpo, tok = T, visibilidad = "canal") => api(`/ot/${ot.id}/mensajes`, { method: "POST", token: tok, body: { cuerpo, visibilidad } });

// ── 2 · OT cerrada, ciclo completo y administración al día ─────────────────
console.log("\n── órdenes de trabajo ────────────────────────────────────────");
{
  const s = await solicitud({ titulo: "Compresor de planta pierde presión", descripcion: "Desde el martes el compresor no mantiene los 8 bar y la línea de pintura se queda sin aire a media jornada.", lugar: "Sala de compresores, nivel 1", prioridad: "alta" });
  const ot = await convertir(s, { prioridad: "alta", tipo: "correctivo", trabajo: "Neumática" });
  await diagnosticar(ot, { diagnostico: "Válvula de admisión de la segunda etapa con fuga y anillos desgastados.", causaProbable: "Horas de servicio por encima del plan de mantenimiento.", alcance: "Segunda etapa del compresor; el motor eléctrico queda fuera.", trabajoARealizar: "Reemplazar kit de válvulas y anillos, cambiar aceite y probar cuatro horas.", lecturasInstrumentos: "Presión 5,8 bar · temperatura de descarga 96 °C" }, tokens[marco.email]);
  await cotizar(ot, { proveedorNombre: "SERVICIOS NEUMÁTICOS DEL PERÚ S.A.C.", proveedorRuc: "20512345671", numeroCotizacion: "COT-2026-0412", monto: 4850, moneda: "PEN", plazoOfrecidoDias: 7, observaciones: "Incluye kit original, mano de obra y puesta en marcha." });
  await iniciar(ot, marco);
  await avance(ot, "Compresor desmontado y kit de válvulas recibido del proveedor.", tokens[marco.email]);
  await avance(ot, "Anillos reemplazados y aceite cambiado. Pendiente la prueba de cuatro horas.", tokens[marco.email]);
  await mensaje(ot, "¿La prueba se puede correr el sábado para no parar la línea?", tokPedro);
  await mensaje(ot, "Sí, la programamos el sábado a primera hora.", T);
  await declarar(ot, "Kit de válvulas y anillos reemplazados. Cuatro horas de prueba sostenidas a 8,1 bar y 71 °C.", tokens[marco.email]);
  await aprobar(ot);
  await api(`/ot/${ot.id}/solped`, { method: "POST", body: {} });
  const adm = await api(`/ot/${ot.id}/administrativo`);
  const sp = adm.solped.find((x) => x.vigente);
  await api(`/solped/${sp.id}/marcar-lista`, { method: "POST", body: {} });
  await api(`/solped/${sp.id}/numero-sap`, { method: "POST", body: { numeroSap: "0010045612" } });
  await api(`/ot/${ot.id}/orden-compra`, { method: "POST", body: { numeroOc: "4500231188", monto: 4850, moneda: "PEN" } });
  await api(`/ot/${ot.id}/liberacion`, { method: "POST", body: { estado: "total", monto: 4850, moneda: "PEN" } });
  const r = await fetch(`${BASE}/ot/${ot.id}/cerrar`, { method: "POST", headers: { "Content-Type": "application/json", Authorization: `Bearer ${T}` }, body: JSON.stringify({}) });
  const rp = await r.json();
  if (!rp.ok) await api(`/ot/${ot.id}/cerrar`, { method: "POST", body: { adminRevisado: true, observacionPendiente: "Administración conforme; liberación total registrada." } });
  paso(`${ot.numero_ot} · cerrada, ciclo completo con SOLPED, OC y liberación total`);
}

// ── 3 · OT cerrada con pendiente administrativo ────────────────────────────
{
  const s = await solicitud({ titulo: "Puente grúa se detiene en el tramo central", descripcion: "El puente grúa del taller 2 se corta a media carrera y hay que reiniciarlo desde el tablero.", lugar: "Taller 2", area: "MANTTO", quien: tokNancy, prioridad: "alta" });
  const ot = await convertir(s, { prioridad: "alta", coordinador: julio, tipo: "correctivo", trabajo: "Tableros y control" });
  await diagnosticar(ot, { diagnostico: "Contactor del carro principal con carbonización en los contactos.", causaProbable: "Arranques repetidos con carga máxima.", alcance: "Tablero del carro principal.", trabajoARealizar: "Reemplazar contactor y revisar el ajuste del relé térmico." }, tokens[elena.email]);
  await cotizar(ot, { proveedorNombre: "ELECTROMONTAJES ANDINOS S.R.L.", proveedorRuc: "20487654320", numeroCotizacion: "COT-2026-0418", monto: 2140, moneda: "PEN", plazoOfrecidoDias: 5 });
  await iniciar(ot, elena);
  await avance(ot, "Contactor reemplazado y térmico recalibrado a 24 A.", tokens[elena.email]);
  await declarar(ot, "Contactor nuevo instalado. Diez ciclos de prueba con carga nominal sin cortes.", tokens[elena.email]);
  await aprobar(ot);
  await api(`/ot/${ot.id}/solped`, { method: "POST", body: {} });
  await api(`/ot/${ot.id}/cerrar`, { method: "POST", body: { adminRevisado: true, observacionPendiente: "Compras emite la OC la próxima semana; el equipo ya está operativo." } });
  paso(`${ot.numero_ot} · cerrada dejando constancia del pendiente administrativo`);
}

// ── 4 · en trabajo, con avances ────────────────────────────────────────────
{
  const s = await solicitud({ titulo: "Fuga de aceite en la prensa hidráulica 3", descripcion: "Hay un charco bajo la prensa al final de cada turno y el nivel del tanque baja.", lugar: "Nave de prensas", prioridad: "alta" });
  const ot = await convertir(s, { prioridad: "alta", tipo: "correctivo", trabajo: "Bombas y sistemas hidráulicos" });
  await diagnosticar(ot, { diagnostico: "Retén del cilindro principal vencido; pérdida continua por el vástago.", causaProbable: "Desgaste por horas de servicio y partículas en el aceite.", alcance: "Cilindro principal y filtro de retorno.", trabajoARealizar: "Reemplazar retenes, cambiar filtro y reponer aceite." }, tokens[victor.email]);
  await cotizar(ot, { proveedorNombre: "HIDRÁULICA INDUSTRIAL LIMA S.A.C.", proveedorRuc: "20456789014", numeroCotizacion: "COT-2026-0421", monto: 3290, moneda: "PEN", plazoOfrecidoDias: 10 });
  await iniciar(ot, victor);
  await avance(ot, "Cilindro desmontado y enviado al taller de rectificado.", tokens[victor.email]);
  await avance(ot, "Retenes nuevos recibidos; se monta mañana a primera hora.", tokens[victor.email]);
  await mensaje(ot, "Interno: el proveedor avisó que el vástago llega con un día de retraso.", T, "interna");
  paso(`${ot.numero_ot} · en trabajo con avances registrados`);
}

// ── 5 · en trabajo, pausada ────────────────────────────────────────────────
{
  const s = await solicitud({ titulo: "Banco de pruebas sin lectura de par", descripcion: "El banco no muestra el par en pantalla; marca cero con el motor girando.", lugar: "Laboratorio de pruebas", area: "MANTTO", prioridad: "media" });
  const ot = await convertir(s, { prioridad: "media", coordinador: julio, tipo: "correctivo", trabajo: "Instrumentación" });
  await diagnosticar(ot, { diagnostico: "Celda de carga sin señal; el amplificador entrega 0 mV con carga aplicada.", causaProbable: "Celda dañada por sobrecarga en la última prueba.", alcance: "Celda de carga y su cableado.", trabajoARealizar: "Reemplazar la celda, recalibrar el banco y emitir certificado." }, tokens[elena.email]);
  await cotizar(ot, { proveedorNombre: "INSTRUMENTACIÓN Y CONTROL S.A.", proveedorRuc: "20398765436", numeroCotizacion: "COT-2026-0425", monto: 7800, moneda: "PEN", plazoOfrecidoDias: 21, observaciones: "Celda importada; incluye certificado de calibración." });
  await iniciar(ot, elena);
  await avance(ot, "Celda antigua retirada; se confirma el daño en el puente de galgas.", tokens[elena.email]);
  await api(`/ot/${ot.id}/pausar`, { method: "POST", body: { motivoTexto: "Esperando la celda importada; el proveedor confirma tres semanas." } });
  paso(`${ot.numero_ot} · pausada a la espera de un repuesto importado`);
}

// ── 6 · trabajo declarado, esperando revisión ──────────────────────────────
{
  const s = await solicitud({ titulo: "Portón del almacén no cierra completo", descripcion: "Queda una luz de veinte centímetros y entra polvo al almacén.", lugar: "Almacén central", area: "ALMAC", quien: tokNancy, prioridad: "baja" });
  const ot = await convertir(s, { prioridad: "baja", tipo: "correctivo", trabajo: "Soldadura y estructuras" });
  await diagnosticar(ot, { diagnostico: "Guía inferior deformada y final de carrera descalibrado.", causaProbable: "Golpe de montacargas contra la guía.", alcance: "Guía inferior y sensores de final de carrera.", trabajoARealizar: "Enderezar la guía, reemplazar el sensor y recalibrar recorrido." }, tokens[marco.email]);
  await cotizar(ot, { proveedorNombre: "PUERTAS Y ACCESOS INDUSTRIALES E.I.R.L.", proveedorRuc: "20567890121", numeroCotizacion: "COT-2026-0430", monto: 1180, moneda: "PEN", plazoOfrecidoDias: 4 });
  await iniciar(ot, marco);
  await declarar(ot, "Guía enderezada, sensor nuevo y recorrido recalibrado. El portón cierra a ras de piso.", tokens[marco.email]);
  paso(`${ot.numero_ot} · trabajo declarado, esperando revisión del coordinador`);
}

// ── 7 · en cotización ──────────────────────────────────────────────────────
{
  const s = await solicitud({ titulo: "Ruido metálico en el ventilador de extracción", descripcion: "Se oye un golpeteo al arrancar y vibra más de lo normal.", lugar: "Cabina de pintura", prioridad: "media" });
  const ot = await convertir(s, { prioridad: "media", tipo: "correctivo", trabajo: "Rodamientos y transmisión" });
  await diagnosticar(ot, { diagnostico: "Rodamiento del lado libre con juego axial de 0,6 mm.", causaProbable: "Desalineación acumulada por asentamiento de la base.", alcance: "Conjunto motriz del ventilador.", trabajoARealizar: "Reemplazar rodamientos, alinear con láser y balancear el rotor.", lecturasInstrumentos: "Vibración 7,2 mm/s · temperatura 78 °C" }, tokens[marco.email]);
  await cotizar(ot, { proveedorNombre: "RECTIFICACIONES DEL SUR S.A.C.", proveedorRuc: "20555123451", numeroCotizacion: "COT-2026-0433", monto: 2850, moneda: "PEN", plazoOfrecidoDias: 12 });
  paso(`${ot.numero_ot} · en cotización, esperando el inicio`);
}

// ── 8 · en diagnóstico, con una versión reemplazada ────────────────────────
{
  const s = await solicitud({ titulo: "Caldera se apaga sola por las noches", descripcion: "Amanece apagada dos o tres veces por semana y hay que reencenderla manualmente.", lugar: "Casa de fuerza", area: "MANTTO", prioridad: "alta" });
  const ot = await convertir(s, { prioridad: "alta", coordinador: julio, tipo: "correctivo", trabajo: "Sanitarias y gasfitería" });
  await diagnosticar(ot, { diagnostico: "Presostato de seguridad corta por presión baja durante la noche.", causaProbable: "Ajuste del presostato demasiado cerca del mínimo de operación.", alcance: "Lazo de control de presión.", trabajoARealizar: "Reajustar el presostato y monitorear una semana." }, tokens[victor.email]);
  await diagnosticar(ot, { diagnostico: "El corte lo provoca la válvula de gas, que cierra por caída de presión en la red, no el presostato.", causaProbable: "Caída de presión de red en horario nocturno, cuando la planta vecina consume.", alcance: "Se amplía al tren de válvulas y a la acometida de gas.", trabajoARealizar: "Instalar registrador de presión en la acometida y evaluar regulador de mayor capacidad.", motivoCambio: "El registro nocturno descartó el presostato: la presión de red cae antes del corte.", lecturasInstrumentos: "Presión de red 18 mbar a las 02:40 (mínimo de operación 20 mbar)" }, tokens[victor.email]);
  paso(`${ot.numero_ot} · en diagnóstico, con la versión anterior conservada`);
}

// ── 9 · emergencia en trabajo, regularización pendiente ────────────────────
{
  const s = await solicitud({ titulo: "Tablero principal con olor a quemado", descripcion: "Huele a quemado en el tablero general y saltó el diferencial dos veces.", lugar: "Subestación", area: "MANTTO", prioridad: "critica" });
  const ot = await convertir(s, { prioridad: "critica", tipo: "correctivo", trabajo: "Electricidad general", emergencia: true, justificacion: "Riesgo eléctrico inmediato con la planta energizada; no hay tablero de respaldo." });
  await diagnosticar(ot, { diagnostico: "Borne de la barra principal flojo con marcas de arco eléctrico.", causaProbable: "Ajuste perdido por ciclos térmicos.", alcance: "Barra principal y bornes de salida.", trabajoARealizar: "Reajustar con torquímetro, reemplazar el borne dañado y termografiar." }, tokens[elena.email]);
  await iniciar(ot, elena);
  await avance(ot, "Planta desenergizada, borne reemplazado y barra reajustada a torque de catálogo.", tokens[elena.email]);
  paso(`${ot.numero_ot} · emergencia iniciada sin cotización, regularización pendiente`);
}

// ── 10 · jerarquía: padre con dos derivadas ────────────────────────────────
{
  const s = await solicitud({ titulo: "Montacargas 4 sin fuerza y con falla eléctrica", descripcion: "Levanta a media carga y en el tablero se prende una luz que no conocemos.", lugar: "Patio de maniobras", area: "ALMAC", quien: tokNancy, prioridad: "alta" });
  const padre = await convertir(s, { prioridad: "alta", tipo: "correctivo", trabajo: "Bombas y sistemas hidráulicos" });
  await diagnosticar(padre, { diagnostico: "Dos problemas independientes: caída de presión en el circuito de elevación y falla en el módulo de control.", causaProbable: "Bomba desgastada por un lado; módulo con avería de fábrica por otro.", alcance: "Sistema hidráulico de elevación; el eléctrico se separa.", trabajoARealizar: "Reparar el circuito hidráulico y derivar la parte eléctrica a un especialista." }, tokens[victor.email]);
  const hijaElec = await api(`/ot/${padre.id}/derivadas`, { method: "POST", body: { motivoDerivacion: "El módulo de control lo atiende el concesionario de la marca, con otro proveedor y otra contratación." } });
  const hijaHidr = await api(`/ot/${padre.id}/derivadas`, { method: "POST", body: { motivoDerivacion: "El rectificado de la bomba va a un taller externo especializado." } });
  await diagnosticar({ id: hijaHidr.id }, { diagnostico: "Bomba de engranajes con holgura fuera de tolerancia.", causaProbable: "Desgaste normal por horas de servicio.", alcance: "Bomba de elevación.", trabajoARealizar: "Rectificar la bomba y reemplazar sellos." }, tokens[victor.email]);
  await cotizar({ id: hijaHidr.id }, { proveedorNombre: "HIDRÁULICA INDUSTRIAL LIMA S.A.C.", proveedorRuc: "20456789014", numeroCotizacion: "COT-2026-0436", monto: 1960, moneda: "PEN", plazoOfrecidoDias: 8 });
  await iniciar({ id: hijaHidr.id }, victor);
  await declarar({ id: hijaHidr.id }, "Bomba rectificada y sellos nuevos. Presión de elevación restituida a 180 bar.", tokens[victor.email]);
  await aprobar({ id: hijaHidr.id });
  await api(`/ot/${hijaHidr.id}/cerrar`, { method: "POST", body: { adminRevisado: true, observacionPendiente: "Sin SOLPED: el gasto se imputó al contrato marco del taller externo." } });
  paso(`${padre.numero_ot} · con dos derivadas (${hijaElec.numero_ot} abierta, ${hijaHidr.numero_ot} cerrada)`);
}

// ── 11 · cancelada ─────────────────────────────────────────────────────────
{
  const s = await solicitud({ titulo: "Cambiar luminarias del pasillo 3", descripcion: "Las luminarias parpadean y algunas ya no encienden.", lugar: "Pasillo 3", area: "MANTTO", prioridad: "baja" });
  const ot = await convertir(s, { prioridad: "baja", tipo: "preventivo" });
  await api(`/ot/${ot.id}/cancelar`, { method: "POST", body: { observacion: "El pasillo entra en el proyecto de recambio a LED de toda la planta; se atiende allí." } });
  paso(`${ot.numero_ot} · cancelada con su motivo`);
}

// ── 12 · reabierta ─────────────────────────────────────────────────────────
{
  const s = await solicitud({ titulo: "Bomba de agua del sistema contra incendios pierde presión", descripcion: "El manómetro del sistema baja durante la noche.", lugar: "Cuarto de bombas", area: "MANTTO", prioridad: "alta" });
  const ot = await convertir(s, { prioridad: "alta", tipo: "correctivo", trabajo: "Bombas y sistemas hidráulicos" });
  await diagnosticar(ot, { diagnostico: "Válvula de retención con asiento marcado; permite retorno.", causaProbable: "Sedimento acumulado en el asiento.", alcance: "Válvula de retención de la bomba principal.", trabajoARealizar: "Desmontar, limpiar el asiento y reemplazar el resorte." }, tokens[marco.email]);
  await cotizar(ot, { proveedorNombre: "SISTEMAS CONTRA INCENDIO S.A.C.", proveedorRuc: "20601234565", numeroCotizacion: "COT-2026-0440", monto: 980, moneda: "PEN", plazoOfrecidoDias: 3 });
  await iniciar(ot, marco);
  await declarar(ot, "Válvula limpia y resorte nuevo. Presión estable en la prueba de dos horas.", tokens[marco.email]);
  await aprobar(ot);
  await api(`/ot/${ot.id}/cerrar`, { method: "POST", body: { adminRevisado: true, observacionPendiente: "Gasto menor imputado a caja chica; sin SOLPED." } });
  await api(`/ot/${ot.id}/reabrir`, { method: "POST", body: { motivoTexto: "La presión volvió a caer a los cuatro días; la fuga no era sólo la retención." } });
  paso(`${ot.numero_ot} · reabierta conservando el cierre anterior`);
}

// ── 13 · la cola de la bandeja ─────────────────────────────────────────────
console.log("\n── cola de solicitudes ───────────────────────────────────────");
const COLA = [
  { titulo: "Vibración en el extractor de la zona de soldadura", descripcion: "El extractor vibra y hace más ruido que de costumbre desde el lunes.", lugar: "Zona de soldadura", prioridad: "media", quien: tokPedro },
  { titulo: "Gotera sobre el estante de repuestos", descripcion: "Cuando llueve cae agua justo encima del estante A del almacén.", lugar: "Almacén central", area: "ALMAC", prioridad: "alta", quien: tokNancy },
  { titulo: "Balanza de recepción descuadra 3 kg", descripcion: "Pesa de más comparada con la balanza patrón; ya nos rechazaron un despacho.", lugar: "Recepción de materiales", area: "ALMAC", prioridad: "alta", quien: tokNancy },
  { titulo: "Aire acondicionado de la sala de control no enfría", descripcion: "La sala está a 31 °C y los tableros se calientan.", lugar: "Sala de control", area: "MANTTO", prioridad: "critica", quien: tokPedro },
  { titulo: "Faja transportadora se desalinea sola", descripcion: "Se corre hacia la derecha y hay que centrarla dos veces por turno.", lugar: "Línea de empaque", prioridad: "media", quien: tokPedro },
];
for (const c of COLA) await solicitud(c);
paso(`${COLA.length} solicitudes esperando revisión`);

{
  const obs = await solicitud({ titulo: "Algo suena raro en el taller", descripcion: "Se escucha un ruido, no sé de dónde viene.", lugar: "Taller 1", area: "MANTTO", quien: tokPedro });
  await api(`/solicitudes/${obs.id}/tomar-revision`, { method: "POST", body: {} });
  await api(`/solicitudes/${obs.id}/decidir`, { method: "POST", body: { tipo: "observar", comentario: "Indique en qué máquina se oye y en qué momento del turno, para poder asignar al técnico correcto." } });
  paso("1 solicitud observada, devuelta al solicitante");

  const rec = await solicitud({ titulo: "Compra de una cafetera para la oficina", descripcion: "La cafetera de la oficina administrativa dejó de funcionar.", lugar: "Oficina administrativa", area: "PROD", quien: tokNancy });
  await api(`/solicitudes/${rec.id}/tomar-revision`, { method: "POST", body: {} });
  await api(`/solicitudes/${rec.id}/decidir`, { method: "POST", body: { tipo: "rechazar", comentario: "No corresponde a mantenimiento industrial; canalícelo con Administración como compra de bien de oficina." } });
  paso("1 solicitud rechazada con su motivo");

  await solicitud({ titulo: "Revisión preventiva del grupo electrógeno", descripcion: "Borrador: falta confirmar la fecha con el proveedor del servicio.", lugar: "Casa de fuerza", area: "MANTTO", quien: tokPedro, enviar: false });
  paso("1 borrador sin enviar");
}

// ── 14 · histórico de costos ───────────────────────────────────────────────
// El histórico se alimenta de lo que de verdad se cotizó. Sin al menos tres
// casos comparables del mismo tipo de trabajo, el sistema NO publica promedio
// (cap. 32.4) — y con la base recién sembrada la pantalla saldría vacía.
console.log("\n── histórico de costos ───────────────────────────────────────");
{
  const todas = await api("/ot?page=1&pageSize=100");
  const porTitulo = (frag) => todas.find((o) => new RegExp(frag, "i").test(o.titulo ?? ""));

  const COSTOS = [
    ["Compresor de planta", "KIT VALVULAS 2DA ETAPA COMPRESOR ATLAS GA75 + MANO DE OBRA", 4850, "repuesto", 1, "kit"],
    ["Puente grúa",         "CONTACTOR LC1D80 + RELE TERMICO LRD35 INSTALADO",             2140, "repuesto", 2, "und"],
    ["prensa hidráulica",   "JUEGO DE RETENES CILINDRO 160MM + FILTRO RETORNO",            3290, "repuesto", 1, "juego"],
    ["ventilador de extracción", "RODAMIENTOS 6312 C3 (PAR) + BALANCEO DINAMICO ROTOR",    2850, "repuesto", 2, "und"],
    ["rectificado de la bomba", "RECTIFICADO BOMBA ENGRANAJES + SELLOS",                    1960, "servicio", 1, "servicio"],
    ["contra incendios",    "VALVULA RETENCION 4\" BRONCE + RESORTE",                      980, "repuesto", 1, "und"],
    ["Portón del almacén",  "SENSOR FIN DE CARRERA OMRON + ENDEREZADO DE GUIA",            1180, "servicio", 1, "servicio"],
    ["Banco de pruebas",    "CELDA DE CARGA 5KN CON CERTIFICADO DE CALIBRACION",           7800, "repuesto", 1, "und"],
  ];

  let n = 0;
  for (const [frag, texto, monto, concepto, cantidad, unidad] of COSTOS) {
    const ot = porTitulo(frag);
    if (!ot) continue;
    // El costo cuelga de su cotización: de ahí saca el proveedor y la fecha de
    // referencia, en vez de repetir el dato a mano.
    const ficha = await api(`/ot/${ot.id}`);
    const cot = (ficha.cotizaciones ?? []).find((c) => c.vigente);
    await api(`/ot/${ot.id}/costos`, { method: "POST", body: {
      textoOriginal: texto, montoTotal: monto, fuente: "cotizacion",
      concepto, cantidad, unidad, moneda: "PEN",
      ...(cot ? { cotizacionId: cot.id } : {}) } });
    n++;
  }
  paso(`${n} costos registrados con su texto original de documento`);
}

// ── resumen ─────────────────────────────────────────────────────────────────
const lista = await fetch(`${BASE}/ot?page=1&pageSize=100`, { headers: { Authorization: `Bearer ${T}` } }).then((r) => r.json());
const sols = await fetch(`${BASE}/solicitudes?page=1&pageSize=100`, { headers: { Authorization: `Bearer ${T}` } }).then((r) => r.json());
const porEstado = (lista.data ?? []).reduce((a, o) => ((a[o.estado] = (a[o.estado] ?? 0) + 1), a), {});

console.log("\n══════════════════════════════════════════════════════════════");
console.log(`órdenes de trabajo: ${lista.meta?.total ?? 0}`);
Object.entries(porEstado).sort().forEach(([e, n]) => console.log(`   ${e.padEnd(20)} ${n}`));
console.log(`solicitudes: ${sols.meta?.total ?? 0}`);
console.log(`personas: ${PERSONAS.length + 1} (incluye el super admin)`);
console.log(`\nAcceso de demostración: cualquiera de los correos @demoindustrial.pe con "${CLAVE_DEMO}"`);
console.log(`Coordinadora: ${rosa.email}`);
console.log(`Técnico:      ${marco.email}`);
console.log(`Solicitante:  ${pedro.email}`);
