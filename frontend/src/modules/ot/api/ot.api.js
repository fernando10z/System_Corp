import { apiFetch, qs } from "../../../shared/api/client.js";

export const otApi = {
  listar: (p = {}) => apiFetch(`/ot${qs(p)}`),
  obtener: (id) => apiFetch(`/ot/${id}`),

  /** El árbol completo de todo lo que la OT generó. */
  trazabilidad: (id, profundidad) => apiFetch(`/ot/${id}/trazabilidad${qs({ profundidad })}`),
  jerarquia: (id) => apiFetch(`/ot/${id}/jerarquia`),
  consolidado: (id) => apiFetch(`/ot/${id}/consolidado`),
  lineaTiempo: (id) => apiFetch(`/ot/${id}/linea-tiempo`),
  historial: (id) => apiFetch(`/ot/${id}/historial`),
  verificarTrazabilidad: () => apiFetch("/ot/verificar-trazabilidad"),

  crear: (body) => apiFetch("/ot", { method: "POST", body }),
  crearDerivada: (id, body) => apiFetch(`/ot/${id}/derivadas`, { method: "POST", body }),
  actualizar: (id, body) => apiFetch(`/ot/${id}`, { method: "PATCH", body }),
  cambiarEstado: (id, body) => apiFetch(`/ot/${id}/estado`, { method: "PATCH", body }),
  cambiarPrioridad: (id, body) => apiFetch(`/ot/${id}/prioridad`, { method: "PATCH", body }),

  /**
   * Cancelar puede responder ok:false CON la lista de derivadas activas cuando
   * el tratamiento es "bloquear". Eso es parte del flujo, no un error, así que
   * se pide el sobre completo.
   */
  cancelar: (id, body) => apiFetch(`/ot/${id}/cancelar`, { method: "POST", body, esperarNoOk: true }),

  // Diagnóstico
  diagnosticos: (id) => apiFetch(`/ot/${id}/diagnosticos`),
  registrarDiagnostico: (id, body) => apiFetch(`/ot/${id}/diagnosticos`, { method: "POST", body }),
  aprobarDiagnostico: (dId, observacion) =>
    apiFetch(`/diagnosticos/${dId}/aprobar`, { method: "POST", body: { observacion } }),

  // Cotización
  cotizaciones: (id) => apiFetch(`/ot/${id}/cotizaciones`),
  cargarCotizacion: (id, body) => apiFetch(`/ot/${id}/cotizaciones`, { method: "POST", body }),
  invalidarCotizacion: (cId, motivo) =>
    apiFetch(`/cotizaciones/${cId}/invalidar`, { method: "POST", body: { motivo } }),

  // Ejecución
  iniciar: (id, body) => apiFetch(`/ot/${id}/iniciar`, { method: "POST", body }),
  avance: (id, body) => apiFetch(`/ot/${id}/avances`, { method: "POST", body }),
  incidencia: (id, body) => apiFetch(`/ot/${id}/incidencias`, { method: "POST", body }),
  pausar: (id, body) => apiFetch(`/ot/${id}/pausar`, { method: "POST", body }),
  reanudar: (id, body) => apiFetch(`/ot/${id}/reanudar`, { method: "POST", body }),
  declararTrabajo: (id, body) => apiFetch(`/ot/${id}/trabajo-realizado`, { method: "POST", body }),

  // Cierre
  revisar: (id, body) => apiFetch(`/ot/${id}/revisar`, { method: "POST", body }),
  conformidad: (id, body) => apiFetch(`/ot/${id}/conformidad`, { method: "POST", body }),
  /** Devuelve ok:false con `requiere_confirmacion` si falta confirmar el pendiente. */
  cerrar: (id, body) => apiFetch(`/ot/${id}/cerrar`, { method: "POST", body, esperarNoOk: true }),
  reabrir: (id, body) => apiFetch(`/ot/${id}/reabrir`, { method: "POST", body }),

  // Administrativo
  administrativo: (id) => apiFetch(`/ot/${id}/administrativo`),
  prepararSolped: (id, body) => apiFetch(`/ot/${id}/solped`, { method: "POST", body }),
  solpedLista: (sId) => apiFetch(`/solped/${sId}/marcar-lista`, { method: "POST", body: {} }),
  solpedNumeroSap: (sId, body) => apiFetch(`/solped/${sId}/numero-sap`, { method: "POST", body }),
  solpedAnular: (sId, motivo) => apiFetch(`/solped/${sId}/anular`, { method: "POST", body: { motivo } }),
  registrarOc: (id, body) => apiFetch(`/ot/${id}/orden-compra`, { method: "POST", body }),
  registrarLiberacion: (id, body) => apiFetch(`/ot/${id}/liberacion`, { method: "POST", body }),

  // Conversación
  conversacion: (id) => apiFetch(`/ot/${id}/conversacion`),
  publicarMensaje: (id, body) => apiFetch(`/ot/${id}/mensajes`, { method: "POST", body }),
  invitar: (id, body) => apiFetch(`/ot/${id}/participantes`, { method: "POST", body }),

  // Costos
  registrarCosto: (id, body) => apiFetch(`/ot/${id}/costos`, { method: "POST", body }),
};
