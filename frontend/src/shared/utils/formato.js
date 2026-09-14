/**
 * Formateo compartido.
 *
 * Nota sobre fechas: la API devuelve TIMESTAMPTZ en ISO. Se muestra en la zona
 * del navegador, que en la práctica coincide con la del tenant. La regla 23.1
 * del documento pide mostrar en la zona configurada del tenant; cuando haya
 * tenants en husos distintos, este es el único sitio que hay que tocar.
 */
const ZONA = Intl.DateTimeFormat().resolvedOptions().timeZone;

export function fecha(v) {
  if (!v) return "—";
  return new Date(v).toLocaleDateString("es-PE", { day: "2-digit", month: "short", year: "numeric", timeZone: ZONA });
}

export function fechaHora(v) {
  if (!v) return "—";
  return new Date(v).toLocaleString("es-PE", {
    day: "2-digit", month: "short", year: "numeric", hour: "2-digit", minute: "2-digit", timeZone: ZONA,
  });
}

/** "hace 3 h" · para las bandejas, donde importa la antigüedad, no la fecha. */
export function desde(v) {
  if (!v) return "—";
  const ms = Date.now() - new Date(v).getTime();
  const min = Math.round(ms / 60000);
  if (min < 1) return "recién";
  if (min < 60) return `hace ${min} min`;
  const h = Math.round(min / 60);
  if (h < 24) return `hace ${h} h`;
  const d = Math.round(h / 24);
  if (d < 30) return `hace ${d} d`;
  return fecha(v);
}

export function monto(v, moneda = "PEN") {
  if (v === null || v === undefined || v === "") return "—";
  const simbolo = { PEN: "S/", USD: "$", EUR: "€" }[moneda] ?? "";
  return `${simbolo} ${Number(v).toLocaleString("es-PE", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

export function numero(v, decimales = 0) {
  if (v === null || v === undefined || v === "") return "—";
  return Number(v).toLocaleString("es-PE", { minimumFractionDigits: decimales, maximumFractionDigits: decimales });
}

/** 'en_diagnostico' -> 'En diagnóstico'. Los enums llegan en snake_case. */
const ETIQUETAS = {
  creada: "Creada",
  en_diagnostico: "En diagnóstico",
  en_cotizacion: "En cotización",
  en_trabajo: "En trabajo",
  trabajo_realizado: "Trabajo realizado",
  cerrada: "Cerrada",
  cancelada: "Cancelada",
  borrador: "Borrador",
  enviada: "Enviada",
  en_revision: "En revisión",
  observada: "Observada",
  aceptada: "Aceptada",
  rechazada: "Rechazada",
  derivada: "Derivada",
  duplicada: "Duplicada",
  convertida_en_ot: "Convertida en OT",
  sin_solped: "Sin SOLPED",
  solped_pendiente: "SOLPED pendiente",
  solped_creada: "SOLPED creada",
  oc_pendiente: "OC pendiente",
  oc_registrada: "OC registrada",
  liberacion_pendiente: "Liberación pendiente",
  liberacion_parcial: "Liberación parcial",
  liberacion_total: "Liberación total",
  administracion_completa: "Administración completa",
  critica: "Crítica", alta: "Alta", media: "Media", baja: "Baja",
  activa: "Activa", pausada: "Pausada",
  aprobado: "Aprobado",
  correccion_solicitada: "Corrección solicitada",
  derivada_creada: "Derivada creada",
  conforme: "Conforme", no_conforme: "No conforme", sin_pronunciarse: "Sin pronunciarse",
};

export function etiqueta(v) {
  if (!v) return "—";
  return ETIQUETAS[v] ?? String(v).replace(/_/g, " ").replace(/^./, (c) => c.toUpperCase());
}

export function iniciales(nombre) {
  if (!nombre) return "··";
  return nombre.split(/\s+/).filter(Boolean).slice(0, 2).map((p) => p[0]).join("").toUpperCase();
}

/** Nombres de eventos de la bitácora, en lenguaje de negocio (cap. 33). */
const EVENTOS = {
  ot_creada: "OT creada",
  estado_cambiado: "Cambio de estado",
  prioridad_cambiada: "Cambio de prioridad",
  derivada_creada: "Creada como derivada",
  derivada_generada: "Generó una OT derivada",
  independizada_de_padre: "Independizada de su OT superior",
  ot_cancelada: "OT cancelada",
  ot_cerrada: "OT cerrada",
  ot_reabierta: "OT reabierta",
  diagnostico_creado: "Diagnóstico registrado",
  diagnostico_reemplazado: "Diagnóstico reemplazado",
  diagnostico_aprobado: "Diagnóstico aprobado",
  cotizacion_cargada: "Cotización cargada",
  cotizacion_reemplazada: "Cotización reemplazada",
  cotizacion_invalidada: "Cotización invalidada",
  ejecucion_iniciada: "Ejecución iniciada",
  avance_registrado: "Avance registrado",
  incidencia_registrada: "Incidencia registrada",
  pausa_registrada: "Trabajo pausado",
  pausa_reanudada: "Trabajo reanudado",
  trabajo_declarado: "Trabajo declarado",
  trabajo_revisado: "Trabajo revisado",
  conformidad_registrada: "Conformidad del solicitante",
  solped_preparada: "SOLPED preparada",
  solped_lista: "SOLPED lista para enviar",
  solped_numero_sap: "Número SAP registrado",
  solped_anulada: "SOLPED anulada",
  oc_registrada: "Orden de compra registrada",
  liberacion_actualizada: "Liberación actualizada",
  adjunto_cargado: "Adjunto cargado",
  costo_registrado: "Costo registrado",
};

export function nombreEvento(e) {
  return EVENTOS[e] ?? etiqueta(e);
}

/** Clase visual del sello según lo que ocurrió, no según su dominio técnico. */
export function claseSello(evento) {
  if (["ot_creada", "estado_cambiado", "derivada_creada", "derivada_generada"].includes(evento)) return "hito";
  if (["ot_cerrada", "diagnostico_aprobado", "trabajo_revisado"].includes(evento)) return "cierre";
  if (["ot_cancelada", "ot_reabierta", "incidencia_registrada", "solped_anulada", "cotizacion_invalidada"].includes(evento)) return "alerta";
  if (["pausa_registrada", "trabajo_declarado", "solped_lista"].includes(evento)) return "espera";
  return "";
}
