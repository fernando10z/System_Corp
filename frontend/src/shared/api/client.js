import { ACCESS_TOKEN_KEY, API_BASE_URL, REFRESH_TOKEN_KEY, USER_KEY } from "../config/api.config.js";

const getAccess = () => localStorage.getItem(ACCESS_TOKEN_KEY);
const getRefresh = () => localStorage.getItem(REFRESH_TOKEN_KEY);

export function setTokens(accessToken, refreshToken) {
  if (accessToken) localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
  if (refreshToken) localStorage.setItem(REFRESH_TOKEN_KEY, refreshToken);
}
export function clearTokens() {
  localStorage.removeItem(ACCESS_TOKEN_KEY);
  localStorage.removeItem(REFRESH_TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

// Un solo refresh en vuelo: si tres peticiones caducan a la vez, no deben
// disparar tres refreshes y invalidarse entre sí.
let refrescoEnCurso = null;

async function intentarRefrescar() {
  const refreshToken = getRefresh();
  if (!refreshToken) return null;

  refrescoEnCurso ??= (async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/auth/refresh`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ refreshToken }),
      });
      const payload = await res.json().catch(() => null);
      if (!res.ok || !payload?.ok) return null;
      setTokens(payload.data.accessToken, payload.data.refreshToken);
      localStorage.setItem(USER_KEY, JSON.stringify(payload.data.usuario));
      return payload.data.accessToken;
    } catch {
      return null;
    } finally {
      // Se libera en el siguiente tick para que las peticiones que ya estaban
      // esperando lean el resultado antes de que se limpie.
      setTimeout(() => (refrescoEnCurso = null), 0);
    }
  })();

  return refrescoEnCurso;
}

/**
 * Cliente HTTP de MIP.
 *
 * Devuelve el SOBRE COMPLETO {ok, data, meta}, no sólo `data`. Es deliberado:
 * algunos endpoints usan `ok:false` como parte del flujo, no como error —
 * cerrar una OT con pendiente administrativo devuelve ok:false junto con los
 * datos que la interfaz necesita para pedir la confirmación.
 *
 * Los errores reales sí se lanzan, con `code` y `message` ya en español.
 */
export async function apiFetch(path, { method = "GET", body, headers = {}, _reintento = false, esperarNoOk = false } = {}) {
  const url = path.startsWith("http") ? path : `${API_BASE_URL}${path}`;
  const token = getAccess();
  const esFormData = body instanceof FormData;

  const res = await fetch(url, {
    method,
    headers: {
      ...(body && !esFormData ? { "Content-Type": "application/json" } : {}),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...headers,
    },
    body: esFormData ? body : body ? JSON.stringify(body) : undefined,
  });

  if (res.status === 401 && !_reintento) {
    const nuevo = await intentarRefrescar();
    if (nuevo) return apiFetch(path, { method, body, headers, _reintento: true, esperarNoOk });
    clearTokens();
    if (!window.location.pathname.endsWith("/login")) window.location.href = "/login";
    throw Object.assign(new Error("Su sesión expiró. Vuelva a entrar."), { code: "UNAUTHORIZED" });
  }

  const payload = await res.json().catch(() => null);

  // `esperarNoOk` deja pasar el sobre para que quien llama lo interprete.
  if (esperarNoOk && payload) return payload;

  if (!res.ok || payload?.ok === false) {
    throw Object.assign(new Error(payload?.error?.message ?? `Error ${res.status}`), {
      code: payload?.error?.code,
      field: payload?.error?.field,
      status: res.status,
      detail: payload?.error?.detail,
    });
  }

  return payload;
}

/** Arma un query string ignorando valores vacíos, para no ensuciar la URL. */
export function qs(params = {}) {
  const p = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) {
    if (v === undefined || v === null || v === "") continue;
    p.append(k, String(v));
  }
  const s = p.toString();
  return s ? `?${s}` : "";
}

/** Recorre todas las páginas de un listado; los SP topan pageSize en 100. */
export async function traerTodo(listar, params = {}, { pageSize = 100, tope = 20 } = {}) {
  const filas = [];
  for (let page = 1; page <= tope; page++) {
    const r = await listar({ ...params, page, pageSize });
    const lote = r?.data ?? [];
    filas.push(...lote);
    if (lote.length < pageSize) break;
  }
  return filas;
}
