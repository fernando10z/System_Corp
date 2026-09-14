import { computed, reactive } from "vue";
import { apiFetch, clearTokens, setTokens } from "../api/client.js";
import { USER_KEY } from "../config/api.config.js";

// Singleton a nivel de módulo: no hace falta Pinia para un objeto de sesión.
const estado = reactive({
  autenticado: false,
  usuario: null,
  permisos: [],
  roles: [],
});

function hidratar() {
  try {
    const guardado = JSON.parse(localStorage.getItem(USER_KEY) ?? "null");
    if (guardado) aplicar(guardado);
  } catch {
    clearTokens();
  }
}

function aplicar(usuario) {
  estado.usuario = decorar(usuario);
  estado.permisos = usuario.permisos ?? [];
  estado.roles = usuario.roles ?? [];
  estado.autenticado = true;
  localStorage.setItem(USER_KEY, JSON.stringify(usuario));
}

function decorar(u) {
  const nombre = u.nombre ?? `${u.nombres ?? ""} ${u.apellidos ?? ""}`.trim();
  return {
    ...u,
    nombre,
    iniciales: nombre.split(/\s+/).filter(Boolean).slice(0, 2).map((p) => p[0]).join("").toUpperCase(),
  };
}

hidratar();

export function useAuth() {
  async function login(email, password) {
    const r = await apiFetch("/auth/login", { method: "POST", body: { email, password } });
    setTokens(r.data.accessToken, r.data.refreshToken);
    aplicar(r.data.usuario);
    return estado.usuario;
  }

  async function logout() {
    await apiFetch("/auth/logout", { method: "POST" }).catch(() => undefined);
    clearTokens();
    estado.autenticado = false;
    estado.usuario = null;
    estado.permisos = [];
    estado.roles = [];
  }

  async function refrescarPerfil() {
    const r = await apiFetch("/auth/perfil");
    aplicar(r.data);
    return estado.usuario;
  }

  /**
   * El super admin puede todo. Para el resto, el permiso decide.
   *
   * Esto sólo controla lo que se MUESTRA. Quien de verdad autoriza es el stored
   * procedure: aunque alguien fuerce un botón, la operación se rechaza abajo.
   */
  function puede(permiso) {
    if (!permiso) return true;
    if (estado.usuario?.is_super_admin) return true;
    return estado.permisos.includes(permiso);
  }
  function puedeAlguno(...permisos) {
    return permisos.some((p) => puede(p));
  }
  function tieneRol(...roles) {
    if (estado.usuario?.is_super_admin) return true;
    return roles.some((r) => estado.roles.includes(r));
  }

  return {
    estado,
    autenticado: computed(() => estado.autenticado),
    usuario: computed(() => estado.usuario),
    esSuperAdmin: computed(() => !!estado.usuario?.is_super_admin),
    login, logout, refrescarPerfil, puede, puedeAlguno, tieneRol,
  };
}
