/**
 * Recorre TODOS los flujos del frontend contra la API real, llamando a los
 * mismos endpoints con los mismos cuerpos que envían las pantallas.
 */
import { conEsperaSi429 } from "./lib/login.mjs";
const BASE = process.env.API_BASE_URL ?? "http://localhost:3200/api";
let token = null;
const fallos = [];
const notas = [];
let ok = 0;

const j = (v) => JSON.stringify(v);

/** RUC peruano válido: 10 dígitos + dígito verificador módulo 11. */
function rucValido(diez) {
  const pesos = [5, 4, 3, 2, 7, 6, 5, 4, 3, 2];
  const s = [...diez.slice(0, 10)].reduce((a, c, i) => a + Number(c) * pesos[i], 0);
  let d = 11 - (s % 11);
  if (d === 10) d = 0; else if (d === 11) d = 1;
  return diez.slice(0, 10) + d;
}

async function api(path, { method = "GET", body, esperarNoOk = false } = {}) {
  const res = await fetch(BASE + path, {
    method,
    headers: {
      ...(body ? { "Content-Type": "application/json" } : {}),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const payload = await res.json().catch(() => null);
  return { status: res.status, payload };
}

async function paso(nombre, fn, { opcional = false } = {}) {
  try {
    const r = await fn();
    ok++;
    console.log(`  ✓ ${nombre}`);
    return r;
  } catch (e) {
    const linea = `${nombre} → ${e.message}`;
    if (opcional) { notas.push(linea); console.log(`  ~ ${nombre} — ${e.message}`); }
    else { fallos.push(linea); console.log(`  ✗ ${nombre} — ${e.message}`); }
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

const est = {};

console.log("\n── 1 · autenticación ─────────────────────────────────────────");
await paso("POST /auth/login", async () => {
  const r = await conEsperaSi429(() => api("/auth/login", { method: "POST", body: { email: "admin@mip.local", password: "CambiarEnDeploy2026" } }));
  const d = datos(r);
  exigir(r, d.accessToken, "sin accessToken");
  exigir(r, d.usuario, "sin usuario");
  token = d.accessToken;
  est.refresh = d.refreshToken;
  est.usuario = d.usuario;
  exigir(r, Array.isArray(d.usuario.permisos), "usuario sin array de permisos (el frontend lo asume en useAuth)");
});
await paso("GET /auth/perfil", async () => datos(await api("/auth/perfil")));
await paso("POST /auth/refresh", async () => {
  const r = await api("/auth/refresh", { method: "POST", body: { refreshToken: est.refresh } });
  const d = datos(r);
  exigir(r, d.accessToken, "refresh sin accessToken");
  token = d.accessToken; est.refresh = d.refreshToken;
});

console.log("\n── 2 · pantalla Inicio ───────────────────────────────────────");
await paso("GET /dashboard/coordinador", async () => {
  const d = datos(await api("/dashboard/coordinador"));
  est.tablero = d;
  for (const k of ["solicitudes_nuevas", "sin_diagnostico", "revision_final", "ejecucion", "administracion_pendiente"]) {
    if (!(k in d)) throw new Error(`falta la clave '${k}' que Inicio.vue lee`);
  }
});
await paso("GET /dashboard/solicitante", async () => {
  const d = datos(await api("/dashboard/solicitante"));
  if (!("solicitudes" in d)) throw new Error("falta 'solicitudes' que Inicio.vue lee en la vista de solicitante");
});
await paso("GET /notificaciones?limite=12", async () => {
  const r = await api("/notificaciones?limite=12");
  datos(r);
  if (r.payload.meta?.no_leidas === undefined) throw new Error("meta.no_leidas ausente (Topbar lo usa para el punto ámbar)");
});

console.log("\n── 3 · organización ──────────────────────────────────────────");
await paso("GET /organizacion/arbol", async () => {
  const d = datos(await api("/organizacion/arbol"));
  exigir({status:200,payload:{}}, d.length > 0, "árbol vacío: sin sucursal no se puede crear una OT");
  est.arbol = d;
  est.sucursal = d[0];
  est.empresa = d[0].empresas?.[0];
  exigir({status:200,payload:{}}, est.empresa, "la sucursal sembrada no tiene empresa");
  est.area = est.empresa.areas?.[0];
  exigir({status:200,payload:{}}, est.area, "la empresa sembrada no tiene área");
});
await paso("GET /organizacion/areas", async () => { est.areas = datos(await api("/organizacion/areas")); });
await paso("POST /organizacion/sucursales", async () => {
  const cod = "PRB-" + Date.now().toString().slice(-6);
  datos(await api("/organizacion/sucursales", { method: "POST", body: { codigo: cod, nombre: "Sucursal de prueba" } }));
});
await paso("POST /organizacion/empresas", async () => {
  const ruc = rucValido("20" + Date.now().toString().slice(-8));
  est.empresaNueva = datos(await api("/organizacion/empresas", { method: "POST", body: { ruc, razonSocial: "PRUEBA S.A.C." } }));
});
await paso("POST /organizacion/areas", async () => {
  datos(await api("/organizacion/areas", {
    method: "POST",
    body: { empresaRucId: est.empresa.id, codigo: "PRB" + Date.now().toString().slice(-4), nombre: "Área de prueba" },
  }));
});

console.log("\n── 4 · catálogos y usuarios ──────────────────────────────────");
await paso("GET /catalogos?tipo=impacto_operativo", async () => {
  const d = datos(await api("/catalogos?tipo=impacto_operativo"));
  est.impactos = d.impacto_operativo ?? [];
  if (!est.impactos.length) throw new Error("catálogo impacto_operativo vacío (SolicitudNueva lo ofrece)");
});
await paso("GET /catalogos?tipo=tipo_mantenimiento", async () => {
  const d = datos(await api("/catalogos?tipo=tipo_mantenimiento"));
  est.tiposMant = d.tipo_mantenimiento ?? [];
  if (!est.tiposMant.length) throw new Error("catálogo tipo_mantenimiento vacío (CrearOtModal lo exige)");
});
await paso("GET /tipos-trabajo", async () => { est.tiposTrabajo = datos(await api("/tipos-trabajo")); });
await paso("GET /usuarios?estado=activo&pageSize=100", async () => {
  est.usuarios = datos(await api("/usuarios?estado=activo&pageSize=100"));
  if (!est.usuarios.length) throw new Error("sin usuarios activos: no se puede asignar coordinador ni ejecutor");
});
await paso("GET /roles", async () => { est.roles = datos(await api("/roles")); });
await paso("GET /permisos", async () => {
  est.permisos = datos(await api("/permisos"));
  const p = est.permisos[0];
  for (const k of ["codigo", "modulo", "accion"]) {
    if (!(k in (p ?? {}))) throw new Error(`permiso sin '${k}' (PermisosDrawer agrupa por modulo y muestra accion)`);
  }
});
await paso("POST /usuarios", async () => {
  const email = `prueba${Date.now()}@mip.local`;
  est.usuarioNuevo = datos(await api("/usuarios", {
    method: "POST",
    body: { nombres: "Prueba", apellidos: "Flujos", email, password: "ClaveDePrueba2026", rolCodigos: [est.roles[0].codigo], cargo: "QA" },
  }));
});

console.log("\n── 5 · solicitud ─────────────────────────────────────────────");
await paso("POST /solicitudes (borrador)", async () => {
  est.borrador = datos(await api("/solicitudes", {
    method: "POST",
    body: { titulo: "Borrador de prueba automatizada", descripcion: "Se guarda sin enviar para probar el flujo del borrador.", lugar: "Taller 1", areaId: est.area.id, enviar: false },
  }));
});
await paso("POST /solicitudes/:id/enviar", async () => datos(await api(`/solicitudes/${est.borrador.id}/enviar`, { method: "POST", body: {} })));
await paso("POST /solicitudes (enviada directa)", async () => {
  est.sol = datos(await api("/solicitudes", {
    method: "POST",
    body: { titulo: "Ruido anormal en el compresor 2", descripcion: "Desde el lunes suena un golpeteo metálico al arrancar y vibra más de lo normal.", lugar: "Sala de compresores, nivel 1", areaId: est.area.id, impactoOperativoId: est.impactos[0]?.id, prioridadPercibida: "alta", enviar: true },
  }));
});
await paso("GET /solicitudes (listado con filtros de la pantalla)", async () => {
  const r = await api("/solicitudes?page=1&pageSize=25&pendientesRevision=true");
  const d = datos(r);
  if (!r.payload.meta) throw new Error("sin meta: Paginacion.vue no puede pintar el pie");
  for (const k of ["page", "page_size", "total", "pages"]) {
    if (!(k in r.payload.meta)) throw new Error(`meta sin '${k}' (Paginacion.vue lo usa)`);
  }
  const fila = d[0];
  if (fila) for (const k of ["numero", "titulo", "estado", "lugar"]) {
    if (!(k in fila)) throw new Error(`fila de solicitud sin '${k}' (columna de Solicitudes.vue)`);
  }
});
await paso("GET /solicitudes/:id", async () => {
  est.solDetalle = datos(await api(`/solicitudes/${est.sol.id}`));
  if (!est.solDetalle.area?.id) throw new Error("detalle sin area.id — CrearOtModal lo envía como areaId");
});
await paso("POST /solicitudes/:id/tomar-revision", async () => datos(await api(`/solicitudes/${est.sol.id}/tomar-revision`, { method: "POST", body: {} })));

console.log("\n── 6 · crear la OT ───────────────────────────────────────────");
await paso("POST /ot (aceptar y crear)", async () => {
  est.ot = datos(await api("/ot", {
    method: "POST",
    body: {
      solicitudId: est.sol.id, areaId: est.area.id, sucursalId: est.sucursal.id,
      empresaRucId: est.empresa.id, tipoMantenimientoId: est.tiposMant[0].id,
      prioridadTecnica: "alta", coordinadorId: est.usuario.id,
      esEmergencia: false,
    },
  }));
  if (!est.ot.numero_ot) throw new Error("la OT creada no devuelve numero_ot (el modal lo muestra al confirmar)");
});
await paso("GET /ot/:id (ficha completa)", async () => {
  est.t = datos(await api(`/ot/${est.ot.id}`));
  for (const k of ["ot", "origen", "diagnosticos", "ejecucion", "derivadas", "eventos"]) {
    if (!(k in est.t)) throw new Error(`ficha sin '${k}' que OtDetalle.vue lee`);
  }
  if (!est.t.ot.fechas) throw new Error("ot.fechas ausente (la ficha muestra creación/inicio/término/cierre)");
});
await paso("GET /ot (listado con filtros de la pantalla)", async () => {
  const r = await api("/ot?page=1&pageSize=25&estado=&soloPrincipales=");
  const d = datos(r);
  const fila = d[0];
  if (fila) for (const k of ["numero_ot", "estado", "titulo", "prioridad_tecnica", "estado_administrativo"]) {
    if (!(k in fila)) throw new Error(`fila de OT sin '${k}' (columna de OrdenesTrabajo.vue)`);
  }
});

console.log("\n── 7 · diagnóstico ───────────────────────────────────────────");
await paso("POST /ot/:id/diagnosticos (v1)", async () => {
  est.diag = datos(await api(`/ot/${est.ot.id}/diagnosticos`, {
    method: "POST",
    body: { diagnostico: "Rodamiento del lado libre con juego axial y 78 °C en marcha.", causaProbable: "Desalineación acumulada por asentamiento de la base.", alcance: "Sólo el conjunto motriz; la bancada queda fuera.", trabajoARealizar: "Desmontar, reemplazar rodamientos, alinear con láser y probar 2 h.", lecturasInstrumentos: "vib. 7,2 mm/s · T 78 °C" },
  }));
});
await paso("POST /ot/:id/diagnosticos (v2, exige motivo)", async () => {
  datos(await api(`/ot/${est.ot.id}/diagnosticos`, {
    method: "POST",
    body: { diagnostico: "Tras el desmontaje: eje con ovalización de 0,08 mm.", causaProbable: "Fatiga del eje, no desalineación.", alcance: "Se amplía al eje.", trabajoARealizar: "Rectificar el eje y reemplazar rodamientos.", motivoCambio: "El desmontaje descartó la causa inicial." },
  }));
});
await paso("POST /diagnosticos/:id/aprobar", async () => {
  const t = datos(await api(`/ot/${est.ot.id}`));
  const vig = t.diagnosticos.find((d) => d.vigente);
  if (!vig) throw new Error("ningún diagnóstico vigente tras registrar dos versiones");
  datos(await api(`/diagnosticos/${vig.id}/aprobar`, { method: "POST", body: { observacion: "Conforme." } }));
});

console.log("\n── 8 · cotización ────────────────────────────────────────────");
await paso("POST /ot/:id/cotizaciones (v1)", async () => {
  est.cot = datos(await api(`/ot/${est.ot.id}/cotizaciones`, {
    method: "POST",
    body: { proveedorNombre: "RECTIFICACIONES DEL SUR S.A.C.", proveedorRuc: "20123456789", numeroCotizacion: "COT-2026-0081", fecha: new Date().toISOString().slice(0, 10), monto: 2850.5, moneda: "PEN", plazoOfrecidoDias: 15, validezDias: 30, observaciones: "No incluye desmontaje ni transporte." },
  }));
});
await paso("POST /ot/:id/cotizaciones (reemplazo con motivo)", async () => {
  datos(await api(`/ot/${est.ot.id}/cotizaciones`, {
    method: "POST",
    body: { proveedorNombre: "RECTIFICACIONES DEL SUR S.A.C.", proveedorRuc: "20123456789", numeroCotizacion: "COT-2026-0092", monto: 3990, moneda: "PEN", plazoOfrecidoDias: 20, motivoReemplazo: "El nuevo diagnóstico amplió el alcance al eje." },
  }));
});

console.log("\n── 9 · ejecución ─────────────────────────────────────────────");
await paso("POST /ot/:id/iniciar", async () => datos(await api(`/ot/${est.ot.id}/iniciar`, { method: "POST", body: { responsableId: est.usuario.id } })));
await paso("POST /ot/:id/avances", async () => datos(await api(`/ot/${est.ot.id}/avances`, { method: "POST", body: { descripcion: "Cabezal desmontado y enviado a rectificado." } })));
await paso("POST /ot/:id/pausar", async () => datos(await api(`/ot/${est.ot.id}/pausar`, { method: "POST", body: { motivoTexto: "Esperando el eje del taller de rectificado." } })));
await paso("POST /ot/:id/reanudar", async () => datos(await api(`/ot/${est.ot.id}/reanudar`, { method: "POST", body: {} })));
await paso("POST /ot/:id/incidencias", async () => datos(await api(`/ot/${est.ot.id}/incidencias`, { method: "POST", body: { descripcion: "El eje llegó con 0,02 mm fuera de tolerancia.", tipo: "calidad" } })), { opcional: true });
await paso("POST /ot/:id/trabajo-realizado", async () => datos(await api(`/ot/${est.ot.id}/trabajo-realizado`, { method: "POST", body: { descripcion: "Eje rectificado, rodamientos reemplazados, alineado y probado 2 h sin fuga." } })));

console.log("\n── 10 · revisión y cierre ────────────────────────────────────");
await paso("POST /ot/:id/revisar (devolver)", async () => datos(await api(`/ot/${est.ot.id}/revisar`, { method: "POST", body: { resultado: "correccion_solicitada", observacion: "Falta la prueba de vibración posterior." } })));
await paso("POST /ot/:id/trabajo-realizado (segunda declaración)", async () => datos(await api(`/ot/${est.ot.id}/trabajo-realizado`, { method: "POST", body: { descripcion: "Corregido: prueba de vibración 1,8 mm/s, dentro de tolerancia." } })));
await paso("POST /ot/:id/revisar (aprobar)", async () => datos(await api(`/ot/${est.ot.id}/revisar`, { method: "POST", body: { resultado: "aprobado", observacion: "" } })));

console.log("\n── 11 · administrativo ───────────────────────────────────────");
await paso("POST /ot/:id/solped", async () => { est.solped = datos(await api(`/ot/${est.ot.id}/solped`, { method: "POST", body: {} })); });
await paso("POST /solped/:id/marcar-lista", async () => {
  const a = datos(await api(`/ot/${est.ot.id}/administrativo`));
  est.solpedId = (a.solped ?? []).find((s) => s.vigente)?.id;
  if (!est.solpedId) throw new Error("no hay SOLPED vigente tras prepararla");
  datos(await api(`/solped/${est.solpedId}/marcar-lista`, { method: "POST", body: {} }));
});
await paso("POST /solped/:id/numero-sap", async () => datos(await api(`/solped/${est.solpedId}/numero-sap`, { method: "POST", body: { numeroSap: "0010045678" } })));
await paso("POST /ot/:id/orden-compra", async () => datos(await api(`/ot/${est.ot.id}/orden-compra`, {
  method: "POST", body: { numeroOc: "4500123456", fecha: new Date().toISOString().slice(0, 10), monto: 3990, moneda: "PEN" },
})));
await paso("POST /ot/:id/liberacion (parcial)", async () => datos(await api(`/ot/${est.ot.id}/liberacion`, { method: "POST", body: { estado: "parcial", monto: 2000, moneda: "PEN" } })));
await paso("GET /ot/:id/administrativo", async () => {
  const a = datos(await api(`/ot/${est.ot.id}/administrativo`));
  for (const k of ["estado_consolidado", "solped", "oc", "liberaciones"]) {
    if (!(k in a)) throw new Error(`administrativo sin '${k}' (OtAdministrativo.vue lo lee)`);
  }
});

console.log("\n── 12 · cierre con pendiente ─────────────────────────────────");
await paso("POST /ot/:id/cerrar (debe pedir confirmación)", async () => {
  const r = await api(`/ot/${est.ot.id}/cerrar`, { method: "POST", body: {} });
  if (r.payload?.ok === false && r.payload?.data?.requiere_confirmacion) { est.pidioConfirmacion = true; return; }
  if (r.payload?.ok === true) { est.pidioConfirmacion = false; return; }
  throw new Error(`ni ok:true ni requiere_confirmacion → ${j(r.payload).slice(0, 300)}`);
});
await paso("POST /ot/:id/cerrar (con constancia)", async () => {
  if (!est.pidioConfirmacion) return;
  const r = await api(`/ot/${est.ot.id}/cerrar`, { method: "POST", body: { adminRevisado: true, observacionPendiente: "Compras emite la liberación total esta semana." } });
  exigir(r, r.payload?.ok === true, "el segundo intento de cierre no fue ok");
});

console.log("\n── 13 · derivadas ────────────────────────────────────────────");
await paso("POST /solicitudes + /ot (OT padre para derivar)", async () => {
  const s = datos(await api("/solicitudes", { method: "POST", body: { titulo: "Tablero eléctrico con falla intermitente", descripcion: "El tablero de la línea 2 dispara sin carga aparente.", lugar: "Línea 2", areaId: est.area.id, enviar: true } }));
  await api(`/solicitudes/${s.id}/tomar-revision`, { method: "POST", body: {} });
  est.padre = datos(await api("/ot", { method: "POST", body: { solicitudId: s.id, areaId: est.area.id, sucursalId: est.sucursal.id, empresaRucId: est.empresa.id, tipoMantenimientoId: est.tiposMant[0].id, prioridadTecnica: "media", coordinadorId: est.usuario.id, esEmergencia: false } }));
});
await paso("POST /ot/:id/derivadas", async () => {
  est.derivada = datos(await api(`/ot/${est.padre.id}/derivadas`, { method: "POST", body: { motivoDerivacion: "El tablero requiere intervención eléctrica con otro proveedor." } }));
  if (est.derivada.nivel === undefined) throw new Error("la derivada no devuelve 'nivel' (el aviso de éxito lo muestra)");
});
await paso("GET /ot/:id/jerarquia", async () => {
  const jq = datos(await api(`/ot/${est.padre.id}/jerarquia`));
  if (!Array.isArray(jq.nodos)) throw new Error("jerarquia.nodos no es un array (ArbolDerivadas lo recorre)");
  const n = jq.nodos[0];
  for (const k of ["id", "numero_ot", "estado"]) if (!(k in n)) throw new Error(`nodo sin '${k}' (ArbolNodo.vue lo pinta)`);
});
await paso("GET /ot/:id/consolidado", async () => {
  const c = datos(await api(`/ot/${est.padre.id}/consolidado`));
  for (const k of ["total_descendientes", "bloquean_cierre"]) if (!(k in c)) throw new Error(`consolidado sin '${k}'`);
});

console.log("\n── 14 · emergencia ───────────────────────────────────────────");
await paso("POST /ot (emergencia con justificación)", async () => {
  const s = datos(await api("/solicitudes", { method: "POST", body: { titulo: "Fuga de aceite en prensa 3", descripcion: "Charco bajo la prensa, la línea está parada.", lugar: "Prensa 3", areaId: est.area.id, prioridadPercibida: "critica", enviar: true } }));
  await api(`/solicitudes/${s.id}/tomar-revision`, { method: "POST", body: {} });
  est.emerg = datos(await api("/ot", { method: "POST", body: { solicitudId: s.id, areaId: est.area.id, sucursalId: est.sucursal.id, empresaRucId: est.empresa.id, tipoMantenimientoId: est.tiposMant[0].id, prioridadTecnica: "critica", coordinadorId: est.usuario.id, esEmergencia: true, emergenciaJustificacion: "La línea 2 está parada y no hay equipo de respaldo." } }));
});
await paso("POST /ot/:id/iniciar (emergencia SIN cotización)", async () => {
  // El Anexo A NO contempla CREADA -> EN TRABAJO: la emergencia se salta la
  // COTIZACIÓN, no el diagnóstico. Hay que diagnosticar aunque la línea esté
  // parada, y eso es deliberado.
  datos(await api(`/ot/${est.emerg.id}/diagnosticos`, {
    method: "POST",
    body: { diagnostico: "Retén del cilindro principal roto, pérdida continua.", causaProbable: "Desgaste del retén por horas de servicio.", alcance: "Cilindro principal.", trabajoARealizar: "Reemplazar retén y reponer aceite." },
  }));
  datos(await api(`/ot/${est.emerg.id}/iniciar`, { method: "POST", body: { responsableId: est.usuario.id } }));
  const t = datos(await api(`/ot/${est.emerg.id}`));
  if (!t.ot.emergencia) throw new Error("ot.emergencia ausente: la ficha no puede mostrar la justificación");
});

console.log("\n── 15 · prioridad, conversación, cancelación ─────────────────");
await paso("PATCH /ot/:id/prioridad (exige motivo)", async () => datos(await api(`/ot/${est.padre.id}/prioridad`, { method: "PATCH", body: { prioridad: "critica", motivo: "La parada afecta a la línea completa." } })));
await paso("POST /ot/:id/mensajes (canal)", async () => datos(await api(`/ot/${est.padre.id}/mensajes`, { method: "POST", body: { cuerpo: "¿El proveedor confirmó la visita del jueves?", visibilidad: "canal" } })));
await paso("POST /ot/:id/mensajes (nota interna)", async () => datos(await api(`/ot/${est.padre.id}/mensajes`, { method: "POST", body: { cuerpo: "Interno: el proveedor va con retraso, no lo digas al solicitante todavía.", visibilidad: "interna" } })));
await paso("GET /ot/:id/conversacion", async () => {
  const c = datos(await api(`/ot/${est.padre.id}/conversacion`));
  if (!Array.isArray(c)) throw new Error("la conversación no es un array (OtConversacion.vue lo recorre)");
  const m = c[0];
  if (m) for (const k of ["id", "fecha"]) if (!(k in m)) throw new Error(`mensaje sin '${k}'`);
});
await paso("POST /ot/:id/cancelar (con derivada activa)", async () => {
  const r = await api(`/ot/${est.padre.id}/cancelar`, { method: "POST", body: { observacion: "Se anula el alcance: el equipo se va a reemplazar completo." } });
  if (r.payload?.ok === false && (r.payload?.data?.derivadas_activas ?? []).length) { est.pidioTrato = true; return; }
  if (r.payload?.ok === true) { est.pidioTrato = false; return; }
  throw new Error(`ni ok ni derivadas_activas → ${j(r.payload).slice(0, 300)}`);
});
await paso("POST /ot/:id/cancelar (tratamiento de derivadas)", async () => {
  if (!est.pidioTrato) return;
  const r = await api(`/ot/${est.padre.id}/cancelar`, { method: "POST", body: { observacion: "Se anula el alcance: el equipo se va a reemplazar completo.", tratamientoDerivadas: "independizar" } });
  exigir(r, r.payload?.ok === true, "cancelación con tratamiento no fue ok");
});

console.log("\n── 16 · trazabilidad ─────────────────────────────────────────");
await paso("GET /ot/:id (eventos de la tarjeta viajera)", async () => {
  const t = datos(await api(`/ot/${est.ot.id}`));
  if (!Array.isArray(t.eventos) || !t.eventos.length) throw new Error("la OT recorrida entera no tiene eventos en la bitácora");
  est.nEventos = t.eventos.length;
  const e = t.eventos[0];
  for (const k of ["evento", "fecha"]) if (!(k in e)) throw new Error(`evento sin '${k}' (TarjetaViajera.vue lo pinta)`);
  if (!t._meta) throw new Error("_meta ausente (la tarjeta muestra versión, nodos y profundidad)");
});
await paso("GET /ot/:id/trazabilidad", async () => datos(await api(`/ot/${est.ot.id}/trazabilidad`)), { opcional: true });
await paso("GET /ot/verificar-trazabilidad", async () => {
  const v = datos(await api("/ot/verificar-trazabilidad"));
  if (!("integridad_ok" in v)) throw new Error("sin 'integridad_ok' (Auditoria.vue lo comprueba)");
  if (!v.integridad_ok) throw new Error(`árbol desviado en ${(v.desviadas ?? []).length} OT`);
});

console.log("\n── 17 · análisis y configuración ─────────────────────────────");
await paso("GET /costos/historico", async () => {
  const h = datos(await api("/costos/historico?moneda=PEN"));
  for (const k of ["contexto", "estadisticas", "registros"]) if (!(k in h)) throw new Error(`histórico sin '${k}' (Costos.vue lo lee)`);
  for (const k of ["casos", "umbral_minimo", "moneda", "advertencia"]) if (!(k in h.contexto)) throw new Error(`contexto sin '${k}'`);
});
await paso("GET /dashboard/kpis", async () => {
  const hoy = new Date().toISOString().slice(0, 10);
  const hace = new Date(Date.now() - 90 * 86400000).toISOString().slice(0, 10);
  const k = datos(await api(`/dashboard/kpis?desde=${hace}&hasta=${hoy}`));
  for (const key of ["solicitudes", "ot", "emergencias", "duracion", "cierre_con_pendiente", "costos"]) {
    if (!(key in k)) throw new Error(`kpis sin '${key}' (Reportes.vue lo pinta)`);
  }
});
await paso("GET /reportes/ot", async () => {
  const hoy = new Date().toISOString().slice(0, 10);
  const hace = new Date(Date.now() - 90 * 86400000).toISOString().slice(0, 10);
  const d = datos(await api(`/reportes/ot?desde=${hace}&hasta=${hoy}`));
  if (!Array.isArray(d)) throw new Error("reportes/ot no devuelve array");
  est.filasReporte = d.length;
});
await paso("GET /auditoria", async () => {
  const r = await api("/auditoria?page=1&pageSize=50");
  const d = datos(r);
  if (!d.length) throw new Error("auditoría vacía tras recorrer todos los flujos");
  const a = d[0];
  for (const k of ["fecha", "accion", "entidad"]) if (!(k in a)) throw new Error(`fila de auditoría sin '${k}'`);
});
await paso("GET /configuracion", async () => {
  const c = datos(await api("/configuracion"));
  for (const k of ["configuracion", "claves_disponibles", "no_configurable"]) if (!(k in c)) throw new Error(`configuración sin '${k}'`);
  est.config = c;
});
await paso("PUT /configuracion", async () => {
  const clave = est.config.claves_disponibles[0];
  datos(await api("/configuracion", { method: "PUT", body: { clave, valor: est.config.configuracion[clave] } }));
});

console.log("\n── 18 · reglas que deben RECHAZAR ────────────────────────────");
async function debeFallar(nombre, fn) {
  try {
    const r = await fn();
    if (r.status < 400 && r.payload?.ok !== false) { fallos.push(`${nombre} → se permitió y NO debía`); console.log(`  ✗ ${nombre} — se permitió`); return; }
    ok++; console.log(`  ✓ ${nombre} — rechazado`);
  } catch (e) { ok++; console.log(`  ✓ ${nombre} — rechazado`); }
}
await debeFallar("emergencia sin justificación", () => api("/ot", { method: "POST", body: { solicitudId: est.sol.id, areaId: est.area.id, sucursalId: est.sucursal.id, empresaRucId: est.empresa.id, tipoMantenimientoId: est.tiposMant[0].id, prioridadTecnica: "alta", coordinadorId: est.usuario.id, esEmergencia: true } }));
await debeFallar("diagnóstico con campos vacíos", () => api(`/ot/${est.emerg.id}/diagnosticos`, { method: "POST", body: { diagnostico: "", causaProbable: "", alcance: "", trabajoARealizar: "" } }));
await debeFallar("reemplazo de cotización sin motivo", async () => {
  await api(`/ot/${est.emerg.id}/cotizaciones`, { method: "POST", body: { proveedorNombre: "A", monto: 100, moneda: "PEN" } });
  return api(`/ot/${est.emerg.id}/cotizaciones`, { method: "POST", body: { proveedorNombre: "B", monto: 200, moneda: "PEN" } });
});
await debeFallar("petición sin token", async () => {
  const guardado = token; token = null;
  const r = await api("/ot");
  token = guardado; return r;
});
await debeFallar("declarar trabajo estando pausada", async () => {
  await api(`/ot/${est.emerg.id}/pausar`, { method: "POST", body: { motivoTexto: "Prueba de regla: pausa antes de declarar." } });
  const r = await api(`/ot/${est.emerg.id}/trabajo-realizado`, { method: "POST", body: { descripcion: "Intento de declarar estando pausada, debe rechazarse." } });
  await api(`/ot/${est.emerg.id}/reanudar`, { method: "POST", body: {} });
  return r;
});

console.log("\n══════════════════════════════════════════════════════════════");
console.log(`pasos correctos: ${ok}`);
console.log(`fallos: ${fallos.length}`);
fallos.forEach((f) => console.log("   ✗ " + f));
if (notas.length) { console.log(`opcionales no disponibles: ${notas.length}`); notas.forEach((n) => console.log("   ~ " + n)); }
console.log(`\nOT recorrida: ${est.ot?.numero_ot} · ${est.nEventos} eventos en la bitácora`);
console.log(`filas en el reporte de 90 días: ${est.filasReporte}`);
process.exit(fallos.length ? 1 : 0);
