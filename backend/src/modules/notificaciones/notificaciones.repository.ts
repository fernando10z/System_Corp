import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class NotificacionesRepository {
  constructor(private readonly sp: SpExecutorService) {}

  listar(
    ctx: SpContext,
    soloNoLeidas: boolean,
    limite: number,
  ): Promise<{ data: unknown[]; meta?: Record<string, unknown> }> {
    return this.sp.callCtxPaginado<unknown>("app.fn_notificacion_listar", ctx, [
      soloNoLeidas,
      limite,
    ]);
  }
  marcarLeida(ctx: SpContext, id?: string) {
    return this.sp.callCtx<{ marcadas: number }>("app.sp_notificacion_marcar_leida", ctx, [
      id ?? null,
    ]);
  }
  pendientesCorreo(ctx: SpContext, limite: number) {
    return this.sp.callCtx<Array<Record<string, unknown>>>(
      "app.fn_notificacion_pendientes_correo",
      ctx,
      [limite],
    );
  }
  marcarEnviada(ctx: SpContext, id: string, exito: boolean, error?: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_notificacion_marcar_enviada", ctx, [
      id,
      exito,
      error ?? null,
    ]);
  }
  sla(ctx: SpContext) {
    return this.sp.callCtxPaginado<unknown>("app.fn_sla_solicitudes", ctx, []);
  }
}
