import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import type { SpContext, SpResult } from "../../common/types/sp-result.type";
import type {
  CerrarOtDto,
  ConformidadDto,
  ReabrirOtDto,
  RevisarTrabajoDto,
} from "./dto/cierre.dto";

@Injectable()
export class CierreRepository {
  constructor(private readonly sp: SpExecutorService) {}

  revisar(ctx: SpContext, otId: string, d: RevisarTrabajoDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_trabajo_revisar", ctx, [
      otId,
      d.resultado,
      d.observacion ?? null,
    ]);
  }
  conformidad(ctx: SpContext, otId: string, d: ConformidadDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_conformidad_registrar", ctx, [
      otId,
      d.conformidad,
      d.comentario ?? null,
    ]);
  }
  /**
   * Se usa callCtxRaw porque el "no ok" del cierre es informativo: la base
   * devuelve el estado administrativo y `requiere_confirmacion` para que la
   * interfaz pueda pedir la confirmación explícita en lugar de mostrar un error.
   */
  cerrar(ctx: SpContext, otId: string, d: CerrarOtDto): Promise<SpResult<Record<string, unknown>>> {
    return this.sp.callCtxRaw<Record<string, unknown>>("app.sp_ot_cerrar", ctx, [
      otId,
      d.adminRevisado ?? false,
      d.observacionPendiente ?? null,
    ]);
  }
  reabrir(ctx: SpContext, otId: string, d: ReabrirOtDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_ot_reabrir", ctx, [
      otId,
      d.motivoTexto,
      d.estadoRetorno ?? "en_trabajo",
      d.motivoId ?? null,
    ]);
  }
}
