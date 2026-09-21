import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class RolesRepository {
  constructor(private readonly sp: SpExecutorService) {}
  listarRoles(ctx: SpContext) {
    return this.sp.callCtx<unknown[]>("app.fn_rol_listar", ctx, []);
  }
  listarPermisos(ctx: SpContext) {
    return this.sp.callCtx<unknown[]>("app.fn_permiso_listar", ctx, []);
  }
  asignarPermisos(ctx: SpContext, rolId: string, codigos: string[]) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_rol_asignar_permisos", ctx, [
      rolId,
      codigos,
    ]);
  }
}
