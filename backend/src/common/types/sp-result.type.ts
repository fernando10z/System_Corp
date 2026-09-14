/**
 * El contrato único entre la base de datos y el resto del sistema.
 *
 * Todos los SP y FN del schema `app` devuelven JSONB con esta forma, y el sobre
 * viaja intacto hasta la vista: SP -> Nest -> apiFetch -> componente. No hay
 * ninguna capa que lo traduzca a otra cosa por el camino.
 */
export interface SpError {
  /** Código semántico: VALIDATION, NOT_FOUND, FORBIDDEN, CONFLICT, BUSINESS_RULE… */
  code: string;
  message: string;
  /** Campo del formulario al que apunta el error, cuando aplica. */
  field?: string;
  /** SQLSTATE crudo. Sólo para diagnóstico; no se muestra al usuario. */
  sqlstate?: string;
  detail?: unknown;
}

export interface SpResult<T = unknown> {
  ok: boolean;
  data?: T;
  error?: SpError;
  meta?: Record<string, unknown>;
}

/**
 * Los tres primeros parámetros de TODO SP del schema `app`.
 *
 * No es una convención estética: la base no confía en el backend. Cada SP
 * vuelve a validar el tenant, el permiso y el alcance organizacional a partir de
 * estos tres valores antes de devolver o modificar nada.
 */
export interface SpContext {
  userId: string;
  tenantId: string | null;
  isSuperAdmin: boolean;
}
