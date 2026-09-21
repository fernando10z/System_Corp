import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import { filtrosArg } from "../../infrastructure/database/sp-args";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class AuditoriaRepository {
  constructor(private readonly sp: SpExecutorService) {}
  listar(
    ctx: SpContext,
    f: Record<string, unknown>,
    page: number,
    pageSize: number,
  ): Promise<{ data: unknown[]; meta?: Record<string, unknown> }> {
    return this.sp.callCtxPaginado<unknown>("app.fn_auditoria_listar", ctx, [
      filtrosArg(f),
      page,
      pageSize,
    ]);
  }
}
