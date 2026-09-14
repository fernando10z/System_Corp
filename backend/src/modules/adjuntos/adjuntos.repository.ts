import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import type { SpContext } from "../../common/types/sp-result.type";

export interface RegistrarAdjuntoArgs {
  entidadTipo: string;
  entidadId: string;
  etapa: string;
  tipo: string;
  nombre: string;
  storageKey: string;
  mimeType?: string;
  tamanoBytes?: number;
  otId?: string | null;
  visibilidad?: string;
  checksum?: string;
}

@Injectable()
export class AdjuntosRepository {
  constructor(private readonly sp: SpExecutorService) {}

  registrar(ctx: SpContext, a: RegistrarAdjuntoArgs) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_adjunto_registrar", ctx, [
      a.entidadTipo, a.entidadId, a.etapa, a.tipo, a.nombre, a.storageKey,
      a.mimeType ?? null, a.tamanoBytes ?? null, a.otId ?? null,
      a.visibilidad ?? "canal", a.checksum ?? null,
    ]);
  }
  listar(ctx: SpContext, entidadTipo?: string, entidadId?: string, otId?: string) {
    return this.sp.callCtx<unknown[]>("app.fn_adjunto_listar", ctx, [
      entidadTipo ?? null, entidadId ?? null, otId ?? null,
    ]);
  }
  retirar(ctx: SpContext, adjuntoId: string, motivo: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_adjunto_retirar", ctx, [adjuntoId, motivo]);
  }
}
