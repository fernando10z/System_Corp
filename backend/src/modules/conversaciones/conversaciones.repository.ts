import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import type { SpContext } from "../../common/types/sp-result.type";
import type { EditarMensajeDto, InvitarParticipanteDto, PublicarMensajeDto } from "./dto/conversaciones.dto";

@Injectable()
export class ConversacionesRepository {
  constructor(private readonly sp: SpExecutorService) {}

  publicar(ctx: SpContext, otId: string, d: PublicarMensajeDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_mensaje_publicar", ctx, [
      otId, d.cuerpo, d.visibilidad ?? "canal", d.respondeA ?? null, d.menciones ?? [],
    ]);
  }
  editar(ctx: SpContext, mensajeId: string, d: EditarMensajeDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_mensaje_editar", ctx, [mensajeId, d.cuerpo]);
  }
  retirar(ctx: SpContext, mensajeId: string, motivo?: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_mensaje_retirar", ctx, [mensajeId, motivo ?? null]);
  }
  invitar(ctx: SpContext, otId: string, d: InvitarParticipanteDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_conversacion_invitar", ctx, [
      otId, d.usuarioId, d.puedeEscribir ?? true, d.veNotasInternas ?? false,
    ]);
  }
  lineaTiempo(ctx: SpContext, otId: string) {
    return this.sp.callCtx<unknown[]>("app.fn_ot_linea_tiempo", ctx, [otId]);
  }
}
