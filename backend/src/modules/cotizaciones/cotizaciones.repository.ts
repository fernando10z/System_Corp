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
      otId,
      d.proveedorId ?? null,
      d.proveedorNombre ?? null,
      d.proveedorRuc ?? null,
      d.numeroCotizacion ?? null,
      d.fecha ?? null,
      d.monto ?? null,
      d.moneda ?? "PEN",
      d.plazoOfrecidoDias ?? null,
      d.validezDias ?? null,
      d.observaciones ?? null,
      d.motivoReemplazo ?? null,
    ]);
  }
  /**
   * RUC de las empresas del propio cliente. El lector de PDF los usa para
   * descartarlos: en una cotización, el RUC del cliente es el destinatario y el
   * que interesa es el del proveedor que emite.
   */
  async rucsPropios(ctx: SpContext): Promise<string[]> {
    const arbol = (await this.sp.callCtx<unknown[]>("app.fn_organizacion_arbol", ctx, [])) ?? [];
    const rucs = new Set<string>();
    for (const s of arbol as Array<{ empresas?: Array<{ ruc?: string }> }>) {
      for (const e of s.empresas ?? []) if (e.ruc) rucs.add(e.ruc.replace(/\D/g, ""));
    }
    return [...rucs];
  }

  invalidar(ctx: SpContext, cotizacionId: string, motivo: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_cotizacion_invalidar", ctx, [
      cotizacionId,
      motivo,
    ]);
  }
}
