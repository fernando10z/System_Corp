import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import type { SpContext } from "../../common/types/sp-result.type";
import type { RegistrarDiagnosticoDto } from "./dto/registrar-diagnostico.dto";

@Injectable()
export class DiagnosticosRepository {
  constructor(private readonly sp: SpExecutorService) {}

  listar(ctx: SpContext, otId: string) {
    return this.sp.callCtx<unknown[]>("app.fn_diagnostico_listar", ctx, [otId]);
  }
  registrar(ctx: SpContext, otId: string, d: RegistrarDiagnosticoDto) {
    return this.sp.callCtx<{ id: string; version: number }>("app.sp_diagnostico_registrar", ctx, [
      otId, d.diagnostico, d.causaProbable, d.alcance, d.trabajoARealizar,
      d.observaciones ?? null, d.lecturasInstrumentos ?? null, d.motivoCambio ?? null,
    ]);
  }
  aprobar(ctx: SpContext, diagnosticoId: string, observacion?: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_diagnostico_aprobar", ctx, [
      diagnosticoId, observacion ?? null,
    ]);
  }
}
