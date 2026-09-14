import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import type { SpContext } from "../../common/types/sp-result.type";
import type { CargarCotizacionDto } from "./dto/cargar-cotizacion.dto";

@Injectable()
export class CotizacionesRepository {
  constructor(private readonly sp: SpExecutorService) {}

  listar(ctx: SpContext, otId: string) {
    return this.sp.callCtx<unknown[]>("app.fn_cotizacion_listar", ctx, [otId]);
  }
  cargar(ctx: SpContext, otId: string, d: CargarCotizacionDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_cotizacion_cargar", ctx, [
      otId, d.proveedorId ?? null, d.proveedorNombre ?? null, d.proveedorRuc ?? null,
      d.numeroCotizacion ?? null, d.fechaCotizacion ?? null, d.monto ?? null,
      d.moneda ?? "PEN", d.plazoOfrecidoDias ?? null, d.observaciones ?? null,
      d.motivoReemplazo ?? null,
    ]);
  }
  invalidar(ctx: SpContext, cotizacionId: string, motivo: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_cotizacion_invalidar", ctx, [cotizacionId, motivo]);
  }
}
