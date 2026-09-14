import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import { filtrosArg, jsonbArg } from "../../infrastructure/database/sp-args";
import type { SpContext } from "../../common/types/sp-result.type";
import type { CrearOtDto } from "./dto/crear-ot.dto";
import type { CrearDerivadaDto } from "./dto/crear-derivada.dto";
import type { ActualizarOtDto } from "./dto/actualizar-ot.dto";

/**
 * El ÚNICO sitio del módulo donde aparecen nombres de stored procedures.
 * Un método = un SP, con los argumentos en el orden que espera la base.
 */
@Injectable()
export class OtRepository {
  constructor(private readonly sp: SpExecutorService) {}

  listar(ctx: SpContext, filtros: Record<string, unknown>, page: number, pageSize: number): Promise<{ data: unknown[]; meta?: Record<string, unknown> }> {
    return this.sp.callCtxPaginado<unknown>("app.fn_ot_listar", ctx, [filtrosArg(filtros), page, pageSize]);
  }

  /** Devuelve el árbol de trazabilidad completo, ya podado según permisos. */
  obtener(ctx: SpContext, otId: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.fn_ot_obtener", ctx, [otId]);
  }

  trazabilidad(ctx: SpContext, otId: string, profundidad = 10) {
    return this.sp.callCtx<Record<string, unknown>>("app.fn_ot_trazabilidad", ctx, [otId, profundidad]);
  }

  jerarquia(ctx: SpContext, otId: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.fn_ot_arbol_jerarquia", ctx, [otId]);
  }

  consolidado(ctx: SpContext, otId: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.fn_ot_consolidado", ctx, [otId]);
  }

  lineaTiempo(ctx: SpContext, otId: string) {
    return this.sp.callCtx<unknown[]>("app.fn_ot_linea_tiempo", ctx, [otId]);
  }

  historial(ctx: SpContext, otId: string) {
    return this.sp.callCtx<unknown[]>("app.fn_ot_historial", ctx, [otId]);
  }

  crearDesdeSolicitud(ctx: SpContext, d: CrearOtDto) {
    return this.sp.callCtx<{ id: string; numero_ot: string; estado: string }>(
      "app.sp_ot_crear_desde_solicitud",
      ctx,
      [
        d.solicitudId, d.sucursalId, d.empresaRucId, d.areaId,
        d.tipoMantenimientoId, d.prioridadTecnica, d.coordinadorId,
        d.esEmergencia ?? false, d.emergenciaJustificacion ?? null,
        d.tipoTrabajoId ?? null, d.cecosId ?? null,
      ],
    );
  }

  crearDerivada(ctx: SpContext, otPadreId: string, d: CrearDerivadaDto) {
    return this.sp.callCtx<{ id: string; numero_ot: string; nivel: number }>(
      "app.sp_ot_crear_derivada",
      ctx,
      [
        otPadreId, d.motivoDerivacion,
        d.tipoMantenimientoId ?? null, d.tipoTrabajoId ?? null,
        d.prioridadTecnica ?? null, d.coordinadorId ?? null,
        d.sucursalId ?? null, d.empresaRucId ?? null, d.areaId ?? null,
        d.esBloqueante ?? true, d.motivoDerivacionId ?? null,
      ],
    );
  }

  cambiarEstado(ctx: SpContext, otId: string, estado: string, motivo?: string, motivoId?: string) {
    return this.sp.callCtx<{ estado: string; estado_anterior: string }>(
      "app.sp_ot_cambiar_estado", ctx, [otId, estado, motivo ?? null, motivoId ?? null],
    );
  }

  /**
   * Cancelar puede devolver ok:false con la lista de derivadas activas cuando el
   * tratamiento es "bloquear". Por eso se usa callCtxRaw: ese "error" es en
   * realidad una respuesta que la interfaz necesita mostrar.
   */
  cancelar(ctx: SpContext, otId: string, motivoId: string | null, observacion: string, tratamiento: string) {
    return this.sp.callCtxRaw<Record<string, unknown>>("app.sp_ot_cancelar", ctx, [
      otId, motivoId, observacion, tratamiento,
    ]);
  }

  cambiarPrioridad(ctx: SpContext, otId: string, prioridad: string, motivo?: string) {
    return this.sp.callCtx<Record<string, unknown>>("app.sp_ot_cambiar_prioridad", ctx, [
      otId, prioridad, motivo ?? null,
    ]);
  }

  actualizar(ctx: SpContext, otId: string, d: ActualizarOtDto) {
    // El SP recibe un parche JSONB con las claves en snake_case.
    const payload: Record<string, unknown> = {};
    if (d.sucursalId) payload.sucursal_id = d.sucursalId;
    if (d.empresaRucId) payload.empresa_ruc_id = d.empresaRucId;
    if (d.areaId) payload.area_id = d.areaId;
    if (d.cecosId) payload.cecos_id = d.cecosId;
    if (d.tipoMantenimientoId) payload.tipo_mantenimiento_id = d.tipoMantenimientoId;
    if (d.tipoTrabajoId) payload.tipo_trabajo_id = d.tipoTrabajoId;
    if (d.coordinadorId) payload.coordinador_id = d.coordinadorId;
    if (d.ejecutorId) payload.ejecutor_id = d.ejecutorId;
    return this.sp.callCtx<Record<string, unknown>>("app.sp_ot_actualizar", ctx, [otId, jsonbArg(payload)]);
  }

  refrescarTrazabilidad(otId: string) {
    return this.sp.call<Record<string, unknown>>("app.sp_ot_trazabilidad_refrescar", [otId, true]);
  }

  verificarTrazabilidad(ctx: SpContext, limite = 50) {
    return this.sp.callCtx<Record<string, unknown>>("app.fn_trazabilidad_verificar", ctx, [limite]);
  }

  buscarEnTrazabilidad(ctx: SpContext, criterio: Record<string, unknown>, limite = 50) {
    return this.sp.callCtx<unknown[]>("app.fn_trazabilidad_buscar", ctx, [jsonbArg(criterio), limite]);
  }
}
