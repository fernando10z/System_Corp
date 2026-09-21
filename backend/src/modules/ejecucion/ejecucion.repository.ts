import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import type { SpContext } from "../../common/types/sp-result.type";
import type {
  DeclararTrabajoDto,
  IniciarEjecucionDto,
  PausarDto,
  RegistrarAvanceDto,
  RegistrarIncidenciaDto,
} from "./dto/ejecucion.dto";

@Injectable()
export class EjecucionRepository {
  constructor(private readonly sp: SpExecutorService) {}

  iniciar(ctx: SpContext, otId: string, d: IniciarEjecucionDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_ejecucion_iniciar", ctx, [
      otId,
      d.responsableId,
      d.inicioReal ?? null,
      d.observaciones ?? null,
    ]);
  }
  avance(ctx: SpContext, otId: string, d: RegistrarAvanceDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_avance_registrar", ctx, [
      otId,
      d.descripcion,
      d.porcentaje ?? null,
    ]);
  }
  incidencia(ctx: SpContext, otId: string, d: RegistrarIncidenciaDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_incidencia_registrar", ctx, [
      otId,
      d.descripcion,
      d.tipoId ?? null,
    ]);
  }
  pausar(ctx: SpContext, otId: string, d: PausarDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_pausa_registrar", ctx, [
      otId,
      d.motivoTexto,
      d.motivoId ?? null,
    ]);
  }
  reanudar(ctx: SpContext, otId: string, observacion?: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_pausa_reanudar", ctx, [
      otId,
      observacion ?? null,
    ]);
  }
  declararTrabajo(ctx: SpContext, otId: string, d: DeclararTrabajoDto) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_trabajo_realizado_declarar", ctx, [
      otId,
      d.descripcion,
      d.fechaTermino ?? null,
      d.resultadoId ?? null,
      d.resultadoTexto ?? null,
      d.observaciones ?? null,
    ]);
  }
}
