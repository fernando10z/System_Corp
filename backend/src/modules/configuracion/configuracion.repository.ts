import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import { jsonbArg } from "../../infrastructure/database/sp-args";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class ConfiguracionRepository {
  constructor(private readonly sp: SpExecutorService) {}
  obtener(ctx: SpContext) {
    return this.sp.callCtx<Record<string, unknown>>("app.fn_configuracion_obtener", ctx, []);
  }
  guardar(ctx: SpContext, clave: string, valor: unknown, descripcion?: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_configuracion_guardar", ctx, [
      clave, jsonbArg(valor), descripcion ?? null,
    ]);
  }
}
