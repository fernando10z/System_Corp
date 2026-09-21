/**
 * Los 30 criterios de aceptación del Anexo del documento funcional, hechos
 * ejecutables y llamados por su número.
 *
 * Existe para que el cliente pueda pedir "demuéstrame QA-16" y se le responda
 * con una ejecución, no con una explicación. Cada bloque cita lo que exige el
 * documento antes de comprobarlo.
 */
import { execFileSync } from "node:child_process";

import { conEsperaSi429 } from "./lib/login.mjs";
const BASE = process.env.API_BASE_URL ?? "http://localhost:3200/api";
const CONTENEDOR = process.env.DB_CONTAINER ?? "mip_postgres_dev";
const CLAVE = "ClaveDePrueba2026";
const sello = Date.now().toString().slice(-7);

let T = null;
const fallos = [];
const omitidos = [];
let ok = 0;

async function api(path, { method = "GET", body, token = T, raw } = {}) {
  const res = await fetch(BASE + path, {
    method,
    headers: {
      ...(body && !raw ? { "Content-Type": "application/json" } : {}),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(raw?.headers ?? {}),
    },
    body: raw ? raw.body : body ? JSON.stringify(body) : undefined,
  });
  return { status: res.status, payload: await res.json().catch(() => null) };
}

const datos = (r) => {
  if (r.status >= 400 || r.payload?.ok === false) {
    throw new Error(`HTTP ${r.status} ${JSON.stringify(r.payload?.error ?? r.payload).slice(0, 200)}`);
  }
  return r.payload.data;
};

/**
 * SQL directo. Hace falta para montar un segundo tenant (QA-25) y para
 * comprobar el trigger anti-ciclo (QA-15), que por HTTP es inalcanzable.
 *
 * En local la base vive en un contenedor; en CI es un servicio con psql en el
 * PATH. Se resuelve con MIP_SQL_DIRECTO en vez de duplicar la suite.
 */
const SQL_DIRECTO = process.env.MIP_SQL_DIRECTO === "1";

function sql(consulta) {
  const entorno = { ...process.env, PGPASSWORD: process.env.DB_PASSWORD ?? "postgres" };
  const argsPsql = ["-U", process.env.DB_USER ?? "postgres", "-d", process.env.DB_NAME ?? "mip_dev", "-tAq", "-c", consulta];
  const [cmd, args] = SQL_DIRECTO
    ? ["psql", ["-h", process.env.DB_HOST ?? "localhost", "-p", process.env.DB_PORT ?? "5436", ...argsPsql]]
    : ["docker", ["exec", "-i", "-e", `PGPASSWORD=${entorno.PGPASSWORD}`, CONTENEDOR, "psql", ...argsPsql]];
  return execFileSync(cmd, args, { encoding: "utf8", env: entorno }).trim();
}

async function qa(id, exige, fn) {
  try {
    const r = await fn();
    if (r === "omitido") { omitidos.push(`${id} · ${exige}`); console.log(`  ~ ${id}  ${exige}`); return; }
    ok++;
    console.log(`  ✓ ${id}  ${exige}`);
  } catch (e) {
    fallos.push(`${id} · ${exige} → ${e.message}`);
    console.log(`  ✗ ${id}  ${exige}\n        ${e.message}`);
  }
}

function exigir(cond, msg) { if (!cond) throw new Error(msg); }

/** Debe fallar: si pasa, la regla no se está aplicando. */
async function rechaza(fn, msg) {
  const r = await fn();
  exigir(r.status >= 400 || r.payload?.ok === false, `${msg} — se permitió (HTTP ${r.status})`);
  return r;
}

// ── preparación ──────────────────────────────────────────────────────────────
console.log("\n── preparación ───────────────────────────────────────────────");
T = datos(await conEsperaSi429(() => api("/auth/login", { method: "POST", body: { email: "admin@mip.local", password: "CambiarEnDeploy2026" } }))).accessToken;
const admin = datos(await api("/auth/perfil"));

const arbol = datos(await api("/organizacion/arbol"));
const suc = arbol.find((s) => (s.empresas ?? []).some((e) => (e.areas ?? []).length));
const emp = suc.empresas.find((e) => (e.areas ?? []).length);
const area = emp.areas[0];
const tipos = datos(await api("/catalogos?tipo=tipo_mantenimiento")).tipo_mantenimiento;

const cuentas = {};
for (const rol of ["solicitante", "tecnico", "coordinador"]) {
  const email = `qa.${rol}.${sello}@mip.local`;
  await api("/usuarios", { method: "POST", body: { nombres: "QA", apellidos: rol, email, password: CLAVE, rolCodigos: [rol] } });
  cuentas[rol] = datos(await conEsperaSi429(() => api("/auth/login", { method: "POST", body: { email, password: CLAVE } }))).accessToken;
}
console.log("  · admin + solicitante + técnico + coordinador listos");

/** Crea una OT llevada hasta el estado pedido. */
async function nuevaOt({ titulo = "OT de verificación QA", emergencia = false, hasta = "creada", empresaId = emp.id } = {}) {
  const s = datos(await api("/solicitudes", { method: "POST", body: { titulo, descripcion: "Caso construido por la suite de criterios de aceptación.", lugar: "Taller QA", areaId: area.id, enviar: true } }));
  await api(`/solicitudes/${s.id}/tomar-revision`, { method: "POST", body: {} });
  const ot = datos(await api("/ot", { method: "POST", body: {
    solicitudId: s.id, areaId: area.id, sucursalId: suc.id, empresaRucId: empresaId,
    tipoMantenimientoId: tipos[0].id, prioridadTecnica: emergencia ? "critica" : "media",
    coordinadorId: admin.id, esEmergencia: emergencia,
    emergenciaJustificacion: emergencia ? "Línea parada sin equipo de respaldo." : undefined } }));
  if (hasta === "creada") return { s, ot };

  await api(`/ot/${ot.id}/diagnosticos`, { method: "POST", body: { diagnostico: "Desgaste avanzado en el conjunto motriz.", causaProbable: "Horas de servicio por encima del plan.", alcance: "Conjunto motriz.", trabajoARealizar: "Reemplazar componentes y alinear." } });
  if (hasta === "en_diagnostico") return { s, ot };

  await api(`/ot/${ot.id}/cotizaciones`, { method: "POST", body: { proveedorNombre: "PROVEEDOR QA S.A.C.", monto: 1500, moneda: "PEN" } });
  if (hasta === "en_cotizacion") return { s, ot };

  await api(`/ot/${ot.id}/iniciar`, { method: "POST", body: { responsableId: admin.id } });
  if (hasta === "en_trabajo") return { s, ot };

  await api(`/ot/${ot.id}/trabajo-realizado`, { method: "POST", body: { descripcion: "Trabajo ejecutado y probado conforme al alcance." } });
  if (hasta === "trabajo_realizado") return { s, ot };

  await api(`/ot/${ot.id}/revisar`, { method: "POST", body: { resultado: "aprobado", observacion: "" } });
  return { s, ot };
}

console.log("\n── Anexo QA · criterios de aceptación ────────────────────────");

await qa("QA-01", "Solicitud sin activo; el coordinador la recibe", async () => {
  const s = datos(await api("/solicitudes", { method: "POST", token: cuentas.solicitante, body: { titulo: "Ruido en el compresor", descripcion: "Suena distinto desde el lunes y vibra.", lugar: "Sala de compresores", areaId: area.id, enviar: true } }));
  exigir(s.numero, "la solicitud no devolvió número");
  const bandeja = datos(await api("/dashboard/coordinador"));
  const items = bandeja.solicitudes_nuevas?.items ?? [];
  exigir(items.some((i) => i.numero === s.numero), "la solicitud no aparece en la bandeja del coordinador");
});

await qa("QA-02", "Solicitud observada no crea OT y el solicitante ve el comentario", async () => {
  const s = datos(await api("/solicitudes", { method: "POST", token: cuentas.solicitante, body: { titulo: "Reporte incompleto a propósito", descripcion: "Falta detalle para poder decidir.", lugar: "Patio", areaId: area.id, enviar: true } }));
  await api(`/solicitudes/${s.id}/tomar-revision`, { method: "POST", body: {} });
  datos(await api(`/solicitudes/${s.id}/decidir`, { method: "POST", body: { tipo: "observar", comentario: "Indique desde cuándo ocurre y si detiene la línea." } }));
  const d = datos(await api(`/solicitudes/${s.id}`, { token: cuentas.solicitante }));
  exigir(d.estado === "observada", `estado ${d.estado}, se esperaba observada`);
  exigir(!d.ot, "se creó una OT pese a estar observada");
  const txt = JSON.stringify(d.decisiones ?? []);
  exigir(/desde cuándo ocurre/i.test(txt), "el solicitante no puede ver el comentario de la observación");
});

await qa("QA-03", "Aceptar genera UNA sola OT y conserva el texto original", async () => {
  const original = "Charco de aceite bajo la prensa; el operador lo reportó así.";
  const s = datos(await api("/solicitudes", { method: "POST", token: cuentas.solicitante, body: { titulo: "Fuga en prensa", descripcion: original, lugar: "Prensa 3", areaId: area.id, enviar: true } }));
  await api(`/solicitudes/${s.id}/tomar-revision`, { method: "POST", body: {} });
  const ot = datos(await api("/ot", { method: "POST", body: { solicitudId: s.id, areaId: area.id, sucursalId: suc.id, empresaRucId: emp.id, tipoMantenimientoId: tipos[0].id, prioridadTecnica: "alta", coordinadorId: admin.id } }));
  // Una segunda conversión debe rechazarse.
  await rechaza(() => api("/ot", { method: "POST", body: { solicitudId: s.id, areaId: area.id, sucursalId: suc.id, empresaRucId: emp.id, tipoMantenimientoId: tipos[0].id, prioridadTecnica: "alta", coordinadorId: admin.id } }), "se creó una segunda OT desde la misma solicitud");
  const t = datos(await api(`/ot/${ot.id}`));
  exigir(t.origen?.solicitud?.descripcion_original === original, "el texto original del solicitante no se conserva intacto");
});

await qa("QA-04", "La prioridad técnica cambia sin alterar la percibida", async () => {
  const s = datos(await api("/solicitudes", { method: "POST", token: cuentas.solicitante, body: { titulo: "Percepción vs técnica", descripcion: "El solicitante lo percibe como crítico.", lugar: "Línea 1", areaId: area.id, prioridadPercibida: "critica", enviar: true } }));
  await api(`/solicitudes/${s.id}/tomar-revision`, { method: "POST", body: {} });
  const ot = datos(await api("/ot", { method: "POST", body: { solicitudId: s.id, areaId: area.id, sucursalId: suc.id, empresaRucId: emp.id, tipoMantenimientoId: tipos[0].id, prioridadTecnica: "baja", coordinadorId: admin.id } }));
  datos(await api(`/ot/${ot.id}/prioridad`, { method: "PATCH", body: { prioridad: "media", motivo: "Reevaluada tras la inspección inicial." } }));
  const t = datos(await api(`/ot/${ot.id}`));
  exigir(t.ot.prioridad_tecnica === "media", `prioridad técnica ${t.ot.prioridad_tecnica}`);
  exigir(t.origen.solicitud.prioridad_percibida === "critica", "la prioridad percibida cambió, y no debe");
});

await qa("QA-05", "El técnico diagnostica y el coordinador aprueba, conservando versión", async () => {
  const { ot } = await nuevaOt({ titulo: "Diagnóstico por técnico" });
  datos(await api(`/ot/${ot.id}/diagnosticos`, { method: "POST", token: cuentas.tecnico, body: { diagnostico: "Rodamiento con juego axial medible.", causaProbable: "Desalineación acumulada.", alcance: "Conjunto motriz.", trabajoARealizar: "Reemplazar rodamientos y alinear." } }));
  let t = datos(await api(`/ot/${ot.id}`));
  const vig = t.diagnosticos.find((d) => d.vigente);
  datos(await api(`/diagnosticos/${vig.id}/aprobar`, { method: "POST", token: cuentas.coordinador, body: { observacion: "Conforme." } }));
  t = datos(await api(`/ot/${ot.id}`));
  const ap = t.diagnosticos.find((d) => d.id === vig.id);
  exigir(ap.aprobado_at, "el diagnóstico no quedó marcado como aprobado");
  exigir(ap.version === 1, "se perdió la versión del diagnóstico");
});

await qa("QA-06", "Nueva versión mantiene la anterior y explica el motivo", async () => {
  const { ot } = await nuevaOt({ hasta: "en_diagnostico" });
  await rechaza(() => api(`/ot/${ot.id}/diagnosticos`, { method: "POST", body: { diagnostico: "Segunda lectura del problema.", causaProbable: "Otra causa.", alcance: "Otro alcance.", trabajoARealizar: "Otro trabajo." } }), "aceptó una segunda versión sin motivo");
  datos(await api(`/ot/${ot.id}/diagnosticos`, { method: "POST", body: { diagnostico: "Segunda lectura del problema.", causaProbable: "Fatiga del eje.", alcance: "Se amplía al eje.", trabajoARealizar: "Rectificar el eje.", motivoCambio: "El desmontaje descartó la causa inicial." } }));
  const t = datos(await api(`/ot/${ot.id}`));
  exigir(t.diagnosticos.length === 2, `hay ${t.diagnosticos.length} versiones, se esperaban 2`);
  const v1 = t.diagnosticos.find((d) => d.version === 1);
  const v2 = t.diagnosticos.find((d) => d.version === 2);
  exigir(v1 && !v1.vigente, "la v1 desapareció o sigue vigente");
  exigir(v1.diagnostico, "la v1 perdió su contenido");
  exigir(/desmontaje/i.test(v2.motivo_cambio ?? ""), "la v2 no conserva el motivo del cambio");
});

await qa("QA-07", "No se pasa a EN COTIZACIÓN sin diagnóstico completo", async () => {
  const { ot } = await nuevaOt();
  await rechaza(() => api(`/ot/${ot.id}/cotizaciones`, { method: "POST", body: { proveedorNombre: "X S.A.C.", monto: 100, moneda: "PEN" } }), "cargó cotización con la OT sin diagnóstico");
  await rechaza(() => api(`/ot/${ot.id}/estado`, { method: "PATCH", body: { estado: "en_cotizacion" } }), "permitió pasar a cotización sin diagnóstico");
});

await qa("QA-08", "La cotización admite su PDF de respaldo y habilita el inicio", async () => {
  const { ot } = await nuevaOt({ hasta: "en_cotizacion" });
  const t = datos(await api(`/ot/${ot.id}`));
  const cot = t.cotizaciones.find((c) => c.vigente);
  exigir(cot, "no hay cotización vigente");

  const pdf = Buffer.from("%PDF-1.4\n1 0 obj<</Type/Catalog>>endobj\ntrailer<</Root 1 0 R>>\n%%EOF\n");
  const lim = "----mip" + sello;
  const cuerpo = Buffer.concat([
    Buffer.from(`--${lim}\r\nContent-Disposition: form-data; name="entidadTipo"\r\n\r\ncotizacion\r\n`),
    Buffer.from(`--${lim}\r\nContent-Disposition: form-data; name="entidadId"\r\n\r\n${cot.id}\r\n`),
    Buffer.from(`--${lim}\r\nContent-Disposition: form-data; name="etapa"\r\n\r\ncotizacion\r\n`),
    Buffer.from(`--${lim}\r\nContent-Disposition: form-data; name="archivo"; filename="cotizacion.pdf"\r\nContent-Type: application/pdf\r\n\r\n`),
    pdf, Buffer.from(`\r\n--${lim}--\r\n`),
  ]);
  const sub = await api("/adjuntos", { method: "POST", raw: { body: cuerpo, headers: { "Content-Type": `multipart/form-data; boundary=${lim}` } } });
  datos(sub);

  const lista = datos(await api(`/adjuntos?entidadTipo=cotizacion&entidadId=${cot.id}`));
  exigir(lista.length > 0, "el PDF subido no aparece asociado a la cotización");
  // Y con cotización vigente el inicio normal queda habilitado.
  datos(await api(`/ot/${ot.id}/iniciar`, { method: "POST", body: { responsableId: admin.id } }));
});

await qa("QA-09", "Reemplazar la cotización no borra la anterior y exige motivo", async () => {
  const { ot } = await nuevaOt({ hasta: "en_cotizacion" });
  await rechaza(() => api(`/ot/${ot.id}/cotizaciones`, { method: "POST", body: { proveedorNombre: "OTRO S.A.C.", monto: 2000, moneda: "PEN" } }), "reemplazó la cotización sin motivo");
  datos(await api(`/ot/${ot.id}/cotizaciones`, { method: "POST", body: { proveedorNombre: "OTRO S.A.C.", monto: 2000, moneda: "PEN", motivoReemplazo: "El alcance creció tras el nuevo diagnóstico." } }));
  const t = datos(await api(`/ot/${ot.id}`));
  exigir(t.cotizaciones.length === 2, "no se conservaron ambas versiones");
  const v1 = t.cotizaciones.find((c) => c.version === 1);
  exigir(v1 && Number(v1.monto) === 1500, "la versión anterior perdió sus datos");
});

await qa("QA-10", "No inicia sin responsable", async () => {
  const { ot } = await nuevaOt({ hasta: "en_cotizacion" });
  await rechaza(() => api(`/ot/${ot.id}/iniciar`, { method: "POST", body: {} }), "inició sin responsable de ejecución");
});

await qa("QA-11", "Emergencia inicia sin cotización, con justificación obligatoria", async () => {
  // Primero: una emergencia SIN justificación debe rechazarse.
  const sSinJust = datos(await api("/solicitudes", { method: "POST", body: { titulo: "Emergencia sin justificar", descripcion: "Prueba de la regla de justificación obligatoria.", lugar: "Línea 2", areaId: area.id, enviar: true } }));
  await api(`/solicitudes/${sSinJust.id}/tomar-revision`, { method: "POST", body: {} });
  await rechaza(
    () => api("/ot", { method: "POST", body: { solicitudId: sSinJust.id, areaId: area.id, sucursalId: suc.id, empresaRucId: emp.id, tipoMantenimientoId: tipos[0].id, prioridadTecnica: "critica", coordinadorId: admin.id, esEmergencia: true } }),
    "creó una emergencia sin justificación",
  );

  const { ot } = await nuevaOt({ titulo: "Emergencia real", emergencia: true, hasta: "en_diagnostico" });
  datos(await api(`/ot/${ot.id}/iniciar`, { method: "POST", body: { responsableId: admin.id } }));
  const t = datos(await api(`/ot/${ot.id}`));
  exigir(t.ot.estado === "en_trabajo", `estado ${t.ot.estado}: la emergencia no arrancó sin cotización`);
  exigir(t.ot.emergencia?.regularizacion_pendiente || t.ejecucion?.inicio_sin_cotizacion, "no quedó marcada la regularización pendiente");
});

await qa("QA-12", "No permite dos pausas activas a la vez", async () => {
  const { ot } = await nuevaOt({ hasta: "en_trabajo" });
  datos(await api(`/ot/${ot.id}/pausar`, { method: "POST", body: { motivoTexto: "Esperando repuesto del proveedor." } }));
  await rechaza(() => api(`/ot/${ot.id}/pausar`, { method: "POST", body: { motivoTexto: "Segunda pausa simultánea, debe rechazarse." } }), "permitió dos pausas abiertas");
});

await qa("QA-13", "No permite declarar trabajo con una pausa activa", async () => {
  const { ot } = await nuevaOt({ hasta: "en_trabajo" });
  datos(await api(`/ot/${ot.id}/pausar`, { method: "POST", body: { motivoTexto: "Pausa para probar la regla de declaración." } }));
  await rechaza(() => api(`/ot/${ot.id}/trabajo-realizado`, { method: "POST", body: { descripcion: "Intento de declarar con la OT pausada." } }), "declaró trabajo con una pausa vigente");
});

await qa("QA-14", "El coordinador devuelve a EN TRABAJO con observación", async () => {
  const { ot } = await nuevaOt({ hasta: "trabajo_realizado" });
  await rechaza(() => api(`/ot/${ot.id}/revisar`, { method: "POST", body: { resultado: "correccion_solicitada" } }), "devolvió sin observación");
  datos(await api(`/ot/${ot.id}/revisar`, { method: "POST", body: { resultado: "correccion_solicitada", observacion: "Falta la prueba de vibración posterior." } }));
  const t = datos(await api(`/ot/${ot.id}`));
  exigir(t.ot.estado === "en_trabajo", `estado ${t.ot.estado}, se esperaba en_trabajo`);
});

await qa("QA-15", "La derivada hereda contexto y no permite ciclos", async () => {
  const { ot } = await nuevaOt({ hasta: "en_trabajo" });
  const hija = datos(await api(`/ot/${ot.id}/derivadas`, { method: "POST", body: { motivoDerivacion: "El tablero necesita intervención eléctrica de otro proveedor." } }));
  const th = datos(await api(`/ot/${hija.id}`));
  exigir(th.organizacion?.area?.nombre === area.nombre, "la derivada no heredó el área");
  exigir(th.ot.es_derivada, "la derivada no se marca como tal");
  const nieta = datos(await api(`/ot/${hija.id}/derivadas`, { method: "POST", body: { motivoDerivacion: "Se separa además la parte de instrumentación." } }));
  exigir(nieta.nivel >= 2, `nivel ${nieta.nivel}: la jerarquía no cuenta la profundidad`);
  // Contra el ciclo hay dos barreras. La primera: la API no ofrece ninguna vía
  // para reasignar el padre de una OT —el DTO de actualización ni siquiera
  // acepta el campo—, así que por HTTP el ciclo es inalcanzable.
  await api(`/ot/${ot.id}`, { method: "PATCH", body: { otPadreId: nieta.id } });
  const sigueRaiz = sql(`SELECT coalesce(ot_padre_id::text,'') FROM core.orden_trabajo WHERE id='${ot.id}';`);
  exigir(sigueRaiz === "", "la API dejó reasignar el padre de una OT");

  // La segunda: aunque alguien escribiera en la tabla, el trigger lo rechaza.
  let atajado = false;
  try {
    sql(`UPDATE core.orden_trabajo SET ot_padre_id='${nieta.id}' WHERE id='${ot.id}';`);
  } catch (e) {
    atajado = /ciclo|ancestro|jerarqu/i.test(String(e.stderr ?? e.message ?? ""));
  }
  exigir(atajado, "el trigger anti-ciclo no rechazó un ciclo escrito directamente en la tabla");
});

await qa("QA-16", "La OT padre no cierra con una hija bloqueante abierta", async () => {
  const { ot } = await nuevaOt({ hasta: "aprobado" });
  datos(await api(`/ot/${ot.id}/derivadas`, { method: "POST", body: { motivoDerivacion: "Parte del alcance se ejecuta aparte y bloquea el cierre." } }));
  const r = await api(`/ot/${ot.id}/cerrar`, { method: "POST", body: { adminRevisado: true, observacionPendiente: "Sin pendientes administrativos relevantes." } });
  exigir(r.payload?.ok === false, "el padre cerró con una hija bloqueante viva");
  exigir(/derivada|bloquea|hija/i.test(JSON.stringify(r.payload.error ?? r.payload.data ?? "")), `el motivo del rechazo no menciona las derivadas: ${JSON.stringify(r.payload).slice(0, 160)}`);
});

await qa("QA-17", "Cancelar con hijas exige decisión y motivo", async () => {
  const { ot } = await nuevaOt({ hasta: "en_trabajo" });
  datos(await api(`/ot/${ot.id}/derivadas`, { method: "POST", body: { motivoDerivacion: "Se separa el alcance eléctrico." } }));
  await rechaza(() => api(`/ot/${ot.id}/cancelar`, { method: "POST", body: {} }), "canceló sin motivo");
  const r = await api(`/ot/${ot.id}/cancelar`, { method: "POST", body: { observacion: "El equipo se reemplaza completo, el alcance ya no aplica." } });
  exigir(r.payload?.ok === false && (r.payload?.data?.derivadas_activas ?? []).length, "no pidió decidir qué pasa con las derivadas activas");
  const r2 = await api(`/ot/${ot.id}/cancelar`, { method: "POST", body: { observacion: "El equipo se reemplaza completo, el alcance ya no aplica.", tratamientoDerivadas: "independizar" } });
  exigir(r2.payload?.ok === true, "no aceptó la cancelación con la decisión tomada");
});

await qa("QA-18", "El solicitante no ve cotizaciones ni notas internas", async () => {
  const { s, ot } = await nuevaOt({ hasta: "en_cotizacion" });
  await api(`/ot/${ot.id}/mensajes`, { method: "POST", body: { cuerpo: "Nota interna: el margen con este proveedor es ajustado.", visibilidad: "interna" } });
  const r = await api(`/ot/${ot.id}`, { token: cuentas.solicitante });
  if (r.status >= 400 || r.payload?.ok === false) return; // no ve la ficha en absoluto: cumple de sobra
  const txt = JSON.stringify(r.payload.data);
  exigir(!/margen con este proveedor/i.test(txt), "el solicitante puede leer una nota interna");
  exigir(!/PROVEEDOR QA/i.test(txt), "el solicitante puede ver los datos de la cotización");
});

await qa("QA-19", "Cierra con OC pendiente sólo tras confirmación y observación", async () => {
  const { ot } = await nuevaOt({ hasta: "aprobado" });
  datos(await api(`/ot/${ot.id}/solped`, { method: "POST", body: {} }));
  const r = await api(`/ot/${ot.id}/cerrar`, { method: "POST", body: {} });
  exigir(r.payload?.ok === false && r.payload?.data?.requiere_confirmacion, "cerró sin pedir confirmación pese al pendiente administrativo");
  await rechaza(() => api(`/ot/${ot.id}/cerrar`, { method: "POST", body: { adminRevisado: true } }), "cerró con confirmación pero sin observación");
  const r2 = await api(`/ot/${ot.id}/cerrar`, { method: "POST", body: { adminRevisado: true, observacionPendiente: "Compras emite la OC esta semana." } });
  exigir(r2.payload?.ok === true, "no cerró con confirmación y observación");
  return (globalThis.__otCerrada = ot.id);
});

await qa("QA-20", "Registrar la OC después del cierre no reabre la OT", async () => {
  const id = globalThis.__otCerrada;
  exigir(id, "no hay OT cerrada del criterio anterior");
  datos(await api(`/ot/${id}/orden-compra`, { method: "POST", body: { numeroOc: "4500" + sello, monto: 1500, moneda: "PEN" } }));
  const t = datos(await api(`/ot/${id}`));
  exigir(t.ot.estado === "cerrada", `la OT quedó en ${t.ot.estado}: registrar la OC la reabrió`);
});

await qa("QA-21", "La liberación parcial deja historial anterior y nuevo", async () => {
  const id = globalThis.__otCerrada;
  datos(await api(`/ot/${id}/liberacion`, { method: "POST", body: { estado: "parcial", monto: 500, moneda: "PEN" } }));
  datos(await api(`/ot/${id}/liberacion`, { method: "POST", body: { estado: "parcial", monto: 900, moneda: "PEN" } }));
  const a = datos(await api(`/ot/${id}/administrativo`));
  exigir((a.liberaciones ?? []).length >= 2, "no se conservó el historial de liberaciones");
  const ultima = a.liberaciones[a.liberaciones.length - 1];
  exigir(ultima.monto_anterior !== null && ultima.monto_anterior !== undefined, "la liberación no guarda el monto anterior");
  exigir(Number(ultima.monto_nuevo) === 900, `monto nuevo ${ultima.monto_nuevo}`);
});

await qa("QA-22", "La reapertura exige motivo y conserva el cierre anterior", async () => {
  const id = globalThis.__otCerrada;
  await rechaza(() => api(`/ot/${id}/reabrir`, { method: "POST", body: {} }), "reabrió sin motivo");
  datos(await api(`/ot/${id}/reabrir`, { method: "POST", body: { motivoTexto: "La fuga reapareció a los tres días de la entrega." } }));
  const t = datos(await api(`/ot/${id}`));
  exigir(t.ot.estado !== "cerrada", "la OT sigue cerrada tras reabrir");
  exigir((t.cierre?.cierres ?? []).length >= 1, "se perdió el registro del cierre anterior");
  exigir((t.cierre?.reaperturas ?? []).some((r) => /fuga reapareció/i.test(r.motivo_texto ?? "")), "no se guardó el motivo de la reapertura");
});

await qa("QA-23", "Inactivar un usuario conserva su autoría en el historial", async () => {
  const email = `qa.baja.${sello}@mip.local`;
  const u = datos(await api("/usuarios", { method: "POST", body: { nombres: "Autor", apellidos: "Historico", email, password: CLAVE, rolCodigos: ["tecnico"] } }));
  const tok = datos(await conEsperaSi429(() => api("/auth/login", { method: "POST", body: { email, password: CLAVE } }))).accessToken;
  const { ot } = await nuevaOt({ titulo: "OT con autor que se dará de baja" });
  datos(await api(`/ot/${ot.id}/diagnosticos`, { method: "POST", token: tok, body: { diagnostico: "Diagnóstico firmado por quien luego deja la empresa.", causaProbable: "Desgaste normal.", alcance: "Equipo completo.", trabajoARealizar: "Mantenimiento correctivo." } }));
  datos(await api(`/usuarios/${u.id}/inactivar`, { method: "POST", body: { motivo: "Terminó su vínculo con la empresa." } }));
  const t = datos(await api(`/ot/${ot.id}`));
  const d = t.diagnosticos.find((x) => x.vigente);
  exigir(/Autor Historico/i.test(d.autor ?? ""), `la autoría se perdió: "${d.autor}"`);
  const r = await conEsperaSi429(() => api("/auth/login", { method: "POST", body: { email, password: CLAVE } }));
  exigir(r.payload?.ok === false, "el usuario inactivado todavía puede entrar");
});

await qa("QA-24", "No se crea OT bajo una RUC inactiva; las existentes persisten", async () => {
  const ruc = (() => { const base = "20" + sello + "0".repeat(Math.max(0, 8 - sello.length)); const d10 = base.slice(0, 10); const pesos = [5,4,3,2,7,6,5,4,3,2]; let s = 0; for (let i = 0; i < 10; i++) s += Number(d10[i]) * pesos[i]; let dv = 11 - (s % 11); if (dv === 10) dv = 0; else if (dv === 11) dv = 1; return d10 + dv; })();
  const nueva = datos(await api("/organizacion/empresas", { method: "POST", body: { ruc, razonSocial: `QA INACTIVA ${sello} S.A.C.` } }));
  const a = datos(await api("/organizacion/areas", { method: "POST", body: { empresaRucId: nueva.id, codigo: "QA" + sello.slice(-3), nombre: "Área QA" } }));
  const { ot: previa } = await nuevaOt({ titulo: "OT previa a la baja de la RUC", empresaId: nueva.id });
  datos(await api(`/organizacion/empresas/${nueva.id}/inactivar`, { method: "POST", body: { motivo: "Fusión societaria, deja de operar." } }));
  const s2 = datos(await api("/solicitudes", { method: "POST", body: { titulo: "Intento bajo RUC inactiva", descripcion: "Debe rechazarse al convertir.", lugar: "Nave 4", areaId: a.id ?? area.id, enviar: true } }));
  await api(`/solicitudes/${s2.id}/tomar-revision`, { method: "POST", body: {} });
  await rechaza(() => api("/ot", { method: "POST", body: { solicitudId: s2.id, areaId: a.id ?? area.id, sucursalId: suc.id, empresaRucId: nueva.id, tipoMantenimientoId: tipos[0].id, prioridadTecnica: "media", coordinadorId: admin.id } }), "creó una OT bajo una RUC inactiva");
  const t = datos(await api(`/ot/${previa.id}`));
  exigir(t.ot.numero, "la OT anterior a la baja dejó de ser consultable");
});

await qa("QA-25", "Un usuario de otro tenant no consulta la OT por identificador", async () => {
  const { ot } = await nuevaOt({ titulo: "OT del tenant principal", hasta: "en_diagnostico" });
  const email = `qa.ajeno.${sello}@mip.local`;
  // Segundo tenant, creado por SQL: la API no expone alta de tenants.
  sql(`INSERT INTO core.tenant (codigo, nombre, zona_horaria, moneda_base, estado)
       VALUES ('QA${sello}', 'Tenant QA ${sello}', 'America/Lima', 'PEN', 'activo')
       ON CONFLICT DO NOTHING;`);
  const otroTenant = sql(`SELECT id FROM core.tenant WHERE nombre = 'Tenant QA ${sello}';`);
  exigir(otroTenant, "no se pudo crear el segundo tenant");
  sql(`INSERT INTO core.usuario (tenant_id, email, password_hash, nombres, apellidos, estado)
       VALUES ('${otroTenant}', '${email}', crypt('${CLAVE}', gen_salt('bf',12)), 'Ajeno','QA','activo')
       ON CONFLICT (email) DO NOTHING;`);
  sql(`INSERT INTO core.usuario_rol (usuario_id, rol_id)
       SELECT u.id, r.id FROM core.usuario u, core.rol r
        WHERE u.email='${email}' AND r.codigo='coordinador' ON CONFLICT DO NOTHING;`);

  const login = await conEsperaSi429(() => api("/auth/login", { method: "POST", body: { email, password: CLAVE } }));
  exigir(login.payload?.ok, `el usuario del otro tenant no pudo entrar: ${JSON.stringify(login.payload).slice(0, 140)}`);
  const ajeno = login.payload.data.accessToken;
  // Leer.
  const r = await api(`/ot/${ot.id}`, { token: ajeno });
  exigir(r.status >= 400 || r.payload?.ok === false, `LEYÓ la OT de otro tenant (HTTP ${r.status})`);

  // Listar: tampoco debe asomar.
  const lista = await api("/ot", { token: ajeno });
  exigir(!(lista.payload?.data ?? []).some((o) => o.id === ot.id), "la OT ajena aparece en su listado");

  // Y sobre todo: ESCRIBIR. Un aislamiento que sólo tapa la lectura no sirve.
  const escrituras = [
    ["diagnosticar", () => api(`/ot/${ot.id}/diagnosticos`, { method: "POST", token: ajeno, body: { diagnostico: "Intento de escritura cruzada entre clientes.", causaProbable: "Prueba.", alcance: "Prueba.", trabajoARealizar: "Prueba." } })],
    ["cotizar", () => api(`/ot/${ot.id}/cotizaciones`, { method: "POST", token: ajeno, body: { proveedorNombre: "AJENO S.A.C.", monto: 1, moneda: "PEN" } })],
    ["derivar", () => api(`/ot/${ot.id}/derivadas`, { method: "POST", token: ajeno, body: { motivoDerivacion: "Intento de derivar una OT de otro cliente." } })],
    ["cancelar", () => api(`/ot/${ot.id}/cancelar`, { method: "POST", token: ajeno, body: { observacion: "Intento de cancelar una OT de otro cliente." } })],
    ["mensajear", () => api(`/ot/${ot.id}/mensajes`, { method: "POST", token: ajeno, body: { cuerpo: "Intento de escribir en la conversación de otro cliente." } })],
    ["preparar SOLPED", () => api(`/ot/${ot.id}/solped`, { method: "POST", token: ajeno, body: {} })],
  ];
  for (const [nombre, fn] of escrituras) {
    const w = await fn();
    exigir(w.status >= 400 || w.payload?.ok === false, `pudo ${nombre} sobre una OT de otro tenant (HTTP ${w.status})`);
  }

  // Y por el id de una entidad hija, que es el otro camino.
  const t0 = datos(await api(`/ot/${ot.id}`));
  if ((t0.diagnosticos ?? []).length) {
    const d = t0.diagnosticos[0];
    const w = await api(`/diagnosticos/${d.id}/aprobar`, { method: "POST", token: ajeno, body: { observacion: "Intento cruzado." } });
    exigir(w.status >= 400 || w.payload?.ok === false, "aprobó un diagnóstico de otro tenant por su id");
  }
});

await qa("QA-26", "El costo conserva texto original, normalizado, origen y moneda", async () => {
  const h = datos(await api("/costos/historico?moneda=PEN"));
  const r = (h.registros ?? [])[0];
  if (!r) return "omitido";
  for (const k of ["texto_original", "monto", "moneda"]) exigir(k in r, `el registro de costo no trae '${k}'`);
  exigir("ot" in r || "ot_id" in r, "el registro de costo no dice de qué OT viene");
});

await qa("QA-27", "El promedio muestra número de casos y filtros aplicados", async () => {
  const h = datos(await api("/costos/historico?moneda=PEN"));
  for (const k of ["casos", "umbral_minimo", "moneda", "advertencia"]) exigir(k in h.contexto, `el contexto no trae '${k}'`);
  if (!h.estadisticas.promedio) exigir(h.estadisticas.motivo_sin_promedio, "sin promedio y sin explicar por qué");
});

await qa("QA-28", "Cierra con SOLPED pendiente si el coordinador deja constancia", async () => {
  const { ot } = await nuevaOt({ hasta: "aprobado" });
  datos(await api(`/ot/${ot.id}/solped`, { method: "POST", body: {} }));
  const r = await api(`/ot/${ot.id}/cerrar`, { method: "POST", body: { adminRevisado: true, observacionPendiente: "SOLPED en trámite; Compras confirma el número la próxima semana." } });
  exigir(r.payload?.ok === true, `no cerró con la constancia: ${JSON.stringify(r.payload).slice(0, 180)}`);
  const t = datos(await api(`/ot/${ot.id}`));
  const c = (t.cierre?.cierres ?? []).find((x) => x.vigente);
  exigir(/SOLPED en trámite/i.test(c?.observacion_pendiente ?? ""), "no se guardó la constancia del pendiente");
});

await qa("QA-29", "El número SAP se almacena y no hay borrado físico de la SOLPED", async () => {
  const { ot } = await nuevaOt({ hasta: "en_cotizacion" });
  datos(await api(`/ot/${ot.id}/solped`, { method: "POST", body: {} }));
  let a = datos(await api(`/ot/${ot.id}/administrativo`));
  const sp = a.solped.find((s) => s.vigente);
  datos(await api(`/solped/${sp.id}/marcar-lista`, { method: "POST", body: {} }));
  datos(await api(`/solped/${sp.id}/numero-sap`, { method: "POST", body: { numeroSap: "0010" + sello } }));
  a = datos(await api(`/ot/${ot.id}/administrativo`));
  exigir(a.solped.find((s) => s.id === sp.id)?.numero_sap === "0010" + sello, "el número SAP no quedó almacenado");
  // No debe existir ninguna vía de borrado físico.
  const del = await fetch(`${BASE}/solped/${sp.id}`, { method: "DELETE", headers: { Authorization: `Bearer ${T}` } });
  exigir(del.status === 404 || del.status === 405, `existe un DELETE de SOLPED (HTTP ${del.status})`);
  const filas = sql(`SELECT count(*) FROM core.solped WHERE id = '${sp.id}';`);
  exigir(filas === "1", "la SOLPED desapareció de la base");
  return (globalThis.__solped = { otId: ot.id, id: sp.id });
});

await qa("QA-30", "La SOLPED anulada conserva motivo y permite crear otra", async () => {
  const ctx = globalThis.__solped;
  exigir(ctx, "no hay SOLPED del criterio anterior");
  await rechaza(() => api(`/solped/${ctx.id}/anular`, { method: "POST", body: { motivo: "" } }), "anuló sin motivo");
  datos(await api(`/solped/${ctx.id}/anular`, { method: "POST", body: { motivo: "Se anula por corrección del alcance cotizado." } }));
  let a = datos(await api(`/ot/${ctx.otId}/administrativo`));
  const anulada = a.solped.find((s) => s.id === ctx.id);
  exigir(anulada, "la SOLPED anulada desapareció");
  exigir(/corrección del alcance/i.test(anulada.motivo_anulacion ?? ""), "no conserva el motivo de la anulación");
  datos(await api(`/ot/${ctx.otId}/solped`, { method: "POST", body: {} }));
  a = datos(await api(`/ot/${ctx.otId}/administrativo`));
  exigir(a.solped.length >= 2, "no permitió crear una SOLPED nueva tras la anulación");
});

console.log("\n══════════════════════════════════════════════════════════════");
console.log(`criterios verificados: ${ok}/30`);
console.log(`incumplidos: ${fallos.length}`);
fallos.forEach((f) => console.log("   ✗ " + f));
if (omitidos.length) { console.log(`sin datos para evaluar: ${omitidos.length}`); omitidos.forEach((o) => console.log("   ~ " + o)); }
process.exit(fallos.length ? 1 : 0);
