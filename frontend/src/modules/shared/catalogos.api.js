import { apiFetch, qs } from "../../shared/api/client.js";

export const catalogosApi = {
  todos: (tipo) => apiFetch(`/catalogos${qs({ tipo })}`),
  tiposTrabajo: () => apiFetch("/tipos-trabajo"),
  proveedores: (p = {}) => apiFetch(`/proveedores${qs(p)}`),
  crearProveedor: (body) => apiFetch("/proveedores", { method: "POST", body }),
  crearItem: (body) => apiFetch("/catalogos", { method: "POST", body }),
  crearTipoTrabajo: (body) => apiFetch("/tipos-trabajo", { method: "POST", body }),
};

export const organizacionApi = {
  arbol: () => apiFetch("/organizacion/arbol"),
  areas: (empresaRucId) => apiFetch(`/organizacion/areas${qs({ empresaRucId })}`),
  crearSucursal: (body) => apiFetch("/organizacion/sucursales", { method: "POST", body }),
  crearEmpresa: (body) => apiFetch("/organizacion/empresas", { method: "POST", body }),
  inactivarEmpresa: (id, motivo) =>
    apiFetch(`/organizacion/empresas/${id}/inactivar`, { method: "POST", body: { motivo } }),
  crearArea: (body) => apiFetch("/organizacion/areas", { method: "POST", body }),
};

export const usuariosApi = {
  listar: (p = {}) => apiFetch(`/usuarios${qs(p)}`),
  crear: (body) => apiFetch("/usuarios", { method: "POST", body }),
  inactivar: (id, motivo) => apiFetch(`/usuarios/${id}/inactivar`, { method: "POST", body: { motivo } }),
};

export const rolesApi = {
  listar: () => apiFetch("/roles"),
  permisos: () => apiFetch("/permisos"),
  asignarPermisos: (id, permisos) => apiFetch(`/roles/${id}/permisos`, { method: "PUT", body: { permisos } }),
};

export const dashboardApi = {
  coordinador: () => apiFetch("/dashboard/coordinador"),
  solicitante: () => apiFetch("/dashboard/solicitante"),
  kpis: (p = {}) => apiFetch(`/dashboard/kpis${qs(p)}`),
  sla: () => apiFetch("/notificaciones/sla"),
};

export const costosApi = {
  historico: (p = {}) => apiFetch(`/costos/historico${qs(p)}`),
};

export const reportesApi = {
  ot: (p = {}) => apiFetch(`/reportes/ot${qs(p)}`),
};

export const auditoriaApi = {
  listar: (p = {}) => apiFetch(`/auditoria${qs(p)}`),
};

export const configuracionApi = {
  obtener: () => apiFetch("/configuracion"),
  guardar: (body) => apiFetch("/configuracion", { method: "PUT", body }),
};
