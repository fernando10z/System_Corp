import { apiFetch, qs } from "../../../shared/api/client.js";

export const solicitudesApi = {
  listar: (p = {}) => apiFetch(`/solicitudes${qs(p)}`),
  obtener: (id) => apiFetch(`/solicitudes/${id}`),
  crear: (body) => apiFetch("/solicitudes", { method: "POST", body }),
  enviar: (id) => apiFetch(`/solicitudes/${id}/enviar`, { method: "POST", body: {} }),
  tomarRevision: (id) => apiFetch(`/solicitudes/${id}/tomar-revision`, { method: "POST", body: {} }),
  decidir: (id, body) => apiFetch(`/solicitudes/${id}/decidir`, { method: "POST", body }),
};
