import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import { jsonbArg } from "../../infrastructure/database/sp-args";
import type { SpContext } from "../../common/types/sp-result.type";
import type {
  AnularSolpedDto,
  NumeroSapDto,
  PrepararSolpedDto,
  RegistrarLiberacionDto,
  RegistrarOcDto,
} from "./dto/administrativo.dto";

@Injectable()
export class AdministrativoRepository {
  constructor(private readonly sp: SpExecutorService) {}

  obtener(ctx: SpContext, otId: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.fn_administrativo_obtener", ctx, [otId]);
  }
  prepararSolped(ctx: SpContext, otId: string, d: PrepararSolpedDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_solped_preparar", ctx, [
      otId,
      jsonbArg(d.formulario ?? {}),
      d.cotizacionId ?? null,
      d.numeroInterno ?? null,
    ]);
  }
  marcarLista(ctx: SpContext, solpedId: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_solped_marcar_lista", ctx, [solpedId]);
  }
  registrarNumeroSap(ctx: SpContext, solpedId: string, d: NumeroSapDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_solped_registrar_numero_sap", ctx, [
      solpedId,
      d.numeroSap,
      d.observacion ?? null,
    ]);
  }
  anularSolped(ctx: SpContext, solpedId: string, d: AnularSolpedDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_solped_anular", ctx, [
      solpedId,
      d.motivo,
    ]);
  }
  registrarOc(ctx: SpContext, otId: string, d: RegistrarOcDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_orden_compra_registrar", ctx, [
      otId,
      d.numeroOc,
      d.fechaOc ?? null,
      d.monto ?? null,
      d.moneda ?? "PEN",
      d.observacion ?? null,
      d.solpedId ?? null,
    ]);
  }
  registrarLiberacion(ctx: SpContext, otId: string, d: RegistrarLiberacionDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_liberacion_registrar", ctx, [
      otId,
      d.estado,
      d.monto,
      d.observacion ?? null,
      d.ordenCompraId ?? null,
    ]);
  }
}
