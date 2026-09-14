import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import { filtrosArg } from "../../infrastructure/database/sp-args";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class ReportesRepository {
  constructor(private readonly sp: SpExecutorService) {}
  ot(ctx: SpContext, f: Record<string, unknown>, limite = 5000): Promise<{ data: unknown[]; meta?: Record<string, unknown> }> {
    return this.sp.callCtxPaginado<unknown>("app.fn_reporte_ot", ctx, [filtrosArg(f), limite]);
  }
}
