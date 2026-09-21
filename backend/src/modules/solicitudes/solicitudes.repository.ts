import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import { filtrosArg } from "../../infrastructure/database/sp-args";
import type { SpContext } from "../../common/types/sp-result.type";
import type { CrearSolicitudDto } from "./dto/crear-solicitud.dto";
import type { DecidirSolicitudDto } from "./dto/decidir-solicitud.dto";

@Injectable()
export class SolicitudesRepository {
  constructor(private readonly sp: SpExecutorService) {}

  listar(
    ctx: SpContext,
    filtros: Record<string, unknown>,
    page: number,
    pageSize: number,
  ): Promise<{ data: unknown[]; meta?: Record<string, unknown> }> {
    return this.sp.callCtxPaginado<unknown>("app.fn_solicitud_listar", ctx, [
      filtrosArg(filtros),
      page,
      pageSize,
    ]);
  }
  obtener(ctx: SpContext, id: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.fn_solicitud_obtener", ctx, [id]);
  }
  crear(ctx: SpContext, d: CrearSolicitudDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_solicitud_crear", ctx, [
      d.titulo,
      d.descripcion,
      d.lugar,
      d.areaId,
      d.impactoOperativoId ?? null,
      d.impactoComentario ?? null,
      d.prioridadPercibida ?? null,
      d.enviar ?? true,
    ]);
  }
  enviar(ctx: SpContext, id: string) {
    return this.sp.callCtx<{ estado: string }>("app.sp_solicitud_enviar", ctx, [id]);
  }
  tomarRevision(ctx: SpContext, id: string) {
    return this.sp.callCtx<{ estado: string }>("app.sp_solicitud_tomar_revision", ctx, [id]);
  }
  decidir(ctx: SpContext, id: string, d: DecidirSolicitudDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_solicitud_decidir", ctx, [
      id,
      d.tipo,
      d.comentario ?? null,
      d.motivoId ?? null,
      d.destinatarioId ?? null,
      d.solicitudPrincipalId ?? null,
    ]);
  }
}
