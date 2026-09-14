import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import { filtrosArg, jsonbArg } from "../../infrastructure/database/sp-args";
import type { SpContext } from "../../common/types/sp-result.type";
import type { CrearUsuarioDto } from "./dto/usuarios.dto";

@Injectable()
export class UsuariosRepository {
  constructor(private readonly sp: SpExecutorService) {}

  listar(ctx: SpContext, f: Record<string, unknown>, page: number, pageSize: number): Promise<{ data: unknown[]; meta?: Record<string, unknown> }> {
    return this.sp.callCtxPaginado<unknown>("app.fn_usuario_listar", ctx, [filtrosArg(f), page, pageSize]);
  }
  crear(ctx: SpContext, d: CrearUsuarioDto) {
    // El alcance viaja como jsonb; el resto de arrays son text[] nativos.
    const alcance = (d.alcance ?? []).map((a) => ({
      sucursal_id: a.sucursalId ?? null,
      empresa_ruc_id: a.empresaRucId ?? null,
      area_id: a.areaId ?? null,
    }));
    return this.sp.callCtx<Record<string, unknown>>("app.sp_usuario_crear", ctx, [
      d.email, d.nombres, d.apellidos, d.password,
      d.rolCodigos ?? null, d.cargo ?? null, d.documento ?? null, d.telefono ?? null,
      jsonbArg(alcance),
    ]);
  }
  inactivar(ctx: SpContext, usuarioId: string, motivo: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_usuario_inactivar", ctx, [usuarioId, motivo]);
  }
}
