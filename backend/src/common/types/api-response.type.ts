/** Espejo del sobre de la base de datos, para tipar lo que sale por HTTP. */
export interface ApiOk<T = unknown> {
  ok: true;
  data: T;
  meta?: Record<string, unknown>;
}

export interface ApiFail {
  ok: false;
  error: { code: string; message: string; field?: string; detail?: unknown };
}

export type ApiResponse<T = unknown> = ApiOk<T> | ApiFail;
