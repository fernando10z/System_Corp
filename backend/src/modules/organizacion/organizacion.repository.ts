import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import { filtrosArg } from "../../infrastructure/database/sp-args";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class OrganizacionRepository {
  constructor(private readonly sp: SpExecutorService) {}

  arbol(ctx: SpContext) {
    return this.sp.callCtx<unknown[]>("app.fn_organizacion_arbol", ctx, []);
  }
  crearSucursal(ctx: SpContext, codigo: string, nombre: string, direccion?: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_sucursal_crear", ctx, [
      codigo, nombre, direccion ?? null,
    ]);
  }
  crearEmpresaRuc(ctx: SpContext, ruc: string, razonSocial: string, nombreCorto?: string, sucursalIds?: string[]) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_empresa_ruc_crear", ctx, [
      ruc, razonSocial, nombreCorto ?? null, sucursalIds ?? null,
    ]);
  }
  /** Devuelve una alerta si quedan OT abiertas bajo esa RUC (Anexo C, QA-24). */
  inactivarEmpresaRuc(ctx: SpContext, id: string, motivo: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_empresa_ruc_inactivar", ctx, [id, motivo]);
  }
  crearArea(ctx: SpContext, empresaRucId: string, codigo: string, nombre: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_area_crear", ctx, [empresaRucId, codigo, nombre]);
  }
  listarAreas(ctx: SpContext, filtros: Record<string, unknown>) {
    return this.sp.callCtx<unknown[]>("app.fn_area_listar", ctx, [filtrosArg(filtros)]);
  }
}
