import { HttpException, HttpStatus, Inject, Injectable, Logger } from "@nestjs/common";
import { Pool } from "pg";
import { PG_POOL } from "./database.constants";
import type { SpContext, SpResult } from "../../common/types/sp-result.type";

/**
 * Traducción de los códigos semánticos que devuelve la base a estados HTTP.
 * La base decide QUÉ pasó; aquí sólo se decide cómo contarlo por HTTP.
 */
const ESTADO_POR_CODIGO: Record<string, HttpStatus> = {
  VALIDATION: HttpStatus.BAD_REQUEST,
  NOT_FOUND: HttpStatus.NOT_FOUND,
  FORBIDDEN: HttpStatus.FORBIDDEN,
  UNAUTHORIZED: HttpStatus.UNAUTHORIZED,
  CONFLICT: HttpStatus.CONFLICT,
  BUSINESS_RULE: HttpStatus.UNPROCESSABLE_ENTITY,
  INTERNAL_ERROR: HttpStatus.INTERNAL_SERVER_ERROR,
};

/**
 * El único punto del backend que habla con PostgreSQL.
 *
 * Toda llamada es `SELECT app.fn_x($1,$2,…) AS result`. No se abren
 * transacciones desde aquí: un SP es una operación de negocio atómica, y
 * repartir la atomicidad entre dos capas es la forma más segura de acabar con
 * media operación aplicada.
 */
@Injectable()
export class SpExecutorService {
  private readonly logger = new Logger(SpExecutorService.name);

  constructor(@Inject(PG_POOL) private readonly pool: Pool) {}

  /** Ejecuta el SP y devuelve `data` ya desempaquetado; lanza si `ok` es false. */
  async call<T = unknown>(fnName: string, params: unknown[]): Promise<T> {
    const row = await this.ejecutar<T>(fnName, params);

    if (!row.ok) {
      const code = row.error?.code ?? "BUSINESS_RULE";
      throw new HttpException(
        {
          code,
          message: row.error?.message ?? "Operación rechazada",
          field: row.error?.field,
          detail: row.error?.detail,
        },
        ESTADO_POR_CODIGO[code] ?? HttpStatus.UNPROCESSABLE_ENTITY,
      );
    }

    return (row.data as T) ?? (row as unknown as T);
  }

  /**
   * Devuelve el sobre completo sin desempaquetar. Se usa cuando el endpoint
   * necesita propagar `meta` (paginación), que se perdería con `call`.
   */
  async callRaw<T = unknown>(fnName: string, params: unknown[]): Promise<SpResult<T>> {
    return this.ejecutar<T>(fnName, params);
  }

  /** Antepone el contexto (userId, tenantId, isSuperAdmin) que esperan todos los SP. */
  callCtx<T = unknown>(fnName: string, ctx: SpContext, args: unknown[] = []): Promise<T> {
    return this.call<T>(fnName, [ctx.userId, ctx.tenantId, ctx.isSuperAdmin, ...args]);
  }

  /**
   * Igual que callCtx pero conservando `meta`.
   *
   * OJO: devuelve el sobre TAL CUAL, incluido `ok:false`. Úsese sólo cuando el
   * endpoint necesita interpretar ese "no ok" (cerrar una OT con pendiente,
   * cancelar con derivadas activas). Para listados use `callCtxPaginado`.
   */
  callCtxRaw<T = unknown>(fnName: string, ctx: SpContext, args: unknown[] = []): Promise<SpResult<T>> {
    return this.callRaw<T>(fnName, [ctx.userId, ctx.tenantId, ctx.isSuperAdmin, ...args]);
  }

  /**
   * Listados paginados: devuelve `data` y `meta`, y LANZA si `ok` es false.
   *
   * Existe para cerrar una clase entera de errores: con callCtxRaw, un
   * `r?.data ?? []` en el controlador convierte un fallo del SP en una lista
   * vacía, y el usuario ve "no hay resultados" en lugar del problema real.
   */
  async callCtxPaginado<T = unknown>(
    fnName: string,
    ctx: SpContext,
    args: unknown[] = [],
  ): Promise<{ data: T[]; meta?: Record<string, unknown> }> {
    const row = await this.callRaw<T[]>(fnName, [ctx.userId, ctx.tenantId, ctx.isSuperAdmin, ...args]);

    if (!row.ok) {
      const code = row.error?.code ?? "BUSINESS_RULE";
      throw new HttpException(
        { code, message: row.error?.message ?? "Consulta rechazada", field: row.error?.field },
        ESTADO_POR_CODIGO[code] ?? HttpStatus.UNPROCESSABLE_ENTITY,
      );
    }

    return { data: (row.data as T[]) ?? [], meta: row.meta };
  }

  private async ejecutar<T>(fnName: string, params: unknown[]): Promise<SpResult<T>> {
    const marcadores = params.map((_, i) => `$${i + 1}`).join(", ");
    const sql = `SELECT ${fnName}(${marcadores}) AS result`;

    let row: SpResult<T> | undefined;
    try {
      const res = await this.pool.query<{ result: SpResult<T> }>(sql, params as never[]);
      row = res.rows[0]?.result;
    } catch (err) {
      const e = err as Error & { code?: string };
      this.logger.error(`Error ejecutando ${fnName}: ${e.message}`, e.stack);
      throw new HttpException(
        { code: "DATABASE_ERROR", message: e.message ?? "Error de base de datos" },
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }

    if (!row || typeof row !== "object") {
      throw new HttpException(
        { code: "DATABASE_ERROR", message: `Respuesta inválida de ${fnName}` },
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }

    return row;
  }
}
