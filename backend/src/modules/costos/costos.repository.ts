import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import { filtrosArg } from "../../infrastructure/database/sp-args";
import type { SpContext } from "../../common/types/sp-result.type";
import type { CalificarCostoDto, RegistrarCostoDto } from "./dto/costos.dto";

@Injectable()
export class CostosRepository {
  constructor(private readonly sp: SpExecutorService) {}

  registrar(ctx: SpContext, otId: string, d: RegistrarCostoDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_costo_registrar", ctx, [
      otId, d.textoOriginal, d.montoTotal, d.fuente ?? "cotizacion", d.concepto ?? null,
      d.cantidad ?? null, d.unidad ?? null, d.moneda ?? "PEN",
      d.cotizacionId ?? null, d.descripcionNormalizadaId ?? null,
    ]);
  }
  calificar(ctx: SpContext, costoId: string, d: CalificarCostoDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_costo_calificar", ctx, [
      costoId, d.esComparable, d.esOutlier ?? false, d.justificacion ?? null,
    ]);
  }
  historico(ctx: SpContext, filtros: Record<string, unknown>) {
    return this.sp.callCtx<Record<string, unknown>>("app.fn_costo_historico", ctx, [filtrosArg(filtros)]);
  }
}
