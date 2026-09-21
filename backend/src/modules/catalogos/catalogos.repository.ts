import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import { filtrosArg } from "../../infrastructure/database/sp-args";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class CatalogosRepository {
  constructor(private readonly sp: SpExecutorService) {}

  /** Todos los catálogos de golpe, agrupados por tipo: una sola llamada al abrir la app. */
  listar(ctx: SpContext, tipo?: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.fn_catalogo_listar", ctx, [tipo ?? null]);
  }
  crearItem(
    ctx: SpContext,
    a: {
      tipo: string;
      codigo: string;
      nombre: string;
      descripcion?: string;
      orden?: number;
      requiereComentario?: boolean;
    },
  ) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_catalogo_item_crear", ctx, [
      a.tipo,
      a.codigo,
      a.nombre,
      a.descripcion ?? null,
      a.orden ?? 0,
      a.requiereComentario ?? false,
    ]);
  }
  tiposTrabajo(ctx: SpContext) {
    return this.sp.callCtx<unknown[]>("app.fn_tipo_trabajo_listar", ctx, []);
  }
  crearTipoTrabajo(
    ctx: SpContext,
    codigo: string,
    nombre: string,
    padreId?: string,
    descripcion?: string,
  ) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_tipo_trabajo_crear", ctx, [
      codigo,
      nombre,
      padreId ?? null,
      descripcion ?? null,
    ]);
  }
  proveedores(
    ctx: SpContext,
    f: Record<string, unknown>,
    page: number,
    pageSize: number,
  ): Promise<{ data: unknown[]; meta?: Record<string, unknown> }> {
    return this.sp.callCtxPaginado<unknown>("app.fn_proveedor_listar", ctx, [
      filtrosArg(f),
      page,
      pageSize,
    ]);
  }
  crearProveedor(
    ctx: SpContext,
    a: {
      razonSocial: string;
      ruc?: string;
      contacto?: string;
      telefono?: string;
      email?: string;
    },
  ) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_proveedor_crear", ctx, [
      a.razonSocial,
      a.ruc ?? null,
      a.contacto ?? null,
      a.telefono ?? null,
      a.email ?? null,
    ]);
  }
}
