import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import { filtrosArg } from "../../infrastructure/database/sp-args";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class DashboardsRepository {
  constructor(private readonly sp: SpExecutorService) {}
  coordinador(ctx: SpContext) { return this.sp.callCtx<Record<string, unknown>>("app.fn_dashboard_coordinador", ctx, []); }
  solicitante(ctx: SpContext) { return this.sp.callCtx<Record<string, unknown>>("app.fn_dashboard_solicitante", ctx, []); }
  kpis(ctx: SpContext, f: Record<string, unknown>) {
    return this.sp.callCtx<Record<string, unknown>>("app.fn_kpis", ctx, [filtrosArg(f)]);
  }
}
