import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post, Query } from "@nestjs/common";
import { OtService } from "./ot.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import { CrearOtDto } from "./dto/crear-ot.dto";
import { CrearDerivadaDto } from "./dto/crear-derivada.dto";
import { CambiarEstadoDto } from "./dto/cambiar-estado.dto";
import { CancelarOtDto } from "./dto/cancelar-ot.dto";
import { CambiarPrioridadDto } from "./dto/cambiar-prioridad.dto";
import { ActualizarOtDto } from "./dto/actualizar-ot.dto";

@Controller("ot")
export class OtController {
  constructor(private readonly ot: OtService) {}

  @Get()
  async listar(
    @CurrentUser() u: JwtPayload,
    @Query("buscar") buscar?: string,
    @Query("estado") estado?: string,
    @Query("estadoAdministrativo") estadoAdministrativo?: string,
    @Query("sucursalId") sucursalId?: string,
    @Query("empresaRucId") empresaRucId?: string,
    @Query("areaId") areaId?: string,
    @Query("prioridadTecnica") prioridadTecnica?: string,
    @Query("tipoTrabajoId") tipoTrabajoId?: string,
    @Query("responsableId") responsableId?: string,
    @Query("desde") desde?: string,
    @Query("hasta") hasta?: string,
    @Query("soloEmergencias") soloEmergencias?: string,
    @Query("soloPrincipales") soloPrincipales?: string,
    @Query("otPadreId") otPadreId?: string,
    @Query("page") page?: string,
    @Query("pageSize") pageSize?: string,
  ) {
    const r = await this.ot.listar(
      u,
      {
        buscar, estado, estadoAdministrativo, sucursalId, empresaRucId, areaId,
        prioridadTecnica, tipoTrabajoId, responsableId, desde, hasta, otPadreId,
        soloEmergencias: soloEmergencias === undefined ? undefined : soloEmergencias === "true",
        soloPrincipales: soloPrincipales === "true" ? true : undefined,
      },
      page ? Number(page) : 1,
      pageSize ? Number(pageSize) : 20,
    );
    return { ok: true, data: r?.data ?? [], meta: r?.meta };
  }

  // Las rutas literales van ANTES de :id, o Nest intentaría interpretarlas como
  // un identificador.
  @Get("verificar-trazabilidad")
  async verificar(@CurrentUser() u: JwtPayload, @Query("limite") limite?: string) {
    return { ok: true, data: await this.ot.verificarTrazabilidad(u, limite ? Number(limite) : 50) };
  }

  @Post("buscar-trazabilidad")
  async buscarTrazabilidad(
    @CurrentUser() u: JwtPayload,
    @Body() body: { criterio: Record<string, unknown>; limite?: number },
  ) {
    return { ok: true, data: await this.ot.buscarEnTrazabilidad(u, body.criterio ?? {}, body.limite) };
  }

  @Get(":id")
  async obtener(@CurrentUser() u: JwtPayload, @Param("id", ParseUUIDPipe) id: string) {
    return { ok: true, data: await this.ot.obtener(u, id) };
  }

  /** El árbol completo de todo lo que generó la OT. */
  @Get(":id/trazabilidad")
  async trazabilidad(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Query("profundidad") profundidad?: string,
  ) {
    return { ok: true, data: await this.ot.trazabilidad(u, id, profundidad ? Number(profundidad) : 10) };
  }

  @Get(":id/jerarquia")
  async jerarquia(@CurrentUser() u: JwtPayload, @Param("id", ParseUUIDPipe) id: string) {
    return { ok: true, data: await this.ot.jerarquia(u, id) };
  }

  @Get(":id/consolidado")
  async consolidado(@CurrentUser() u: JwtPayload, @Param("id", ParseUUIDPipe) id: string) {
    return { ok: true, data: await this.ot.consolidado(u, id) };
  }

  @Get(":id/linea-tiempo")
  async lineaTiempo(@CurrentUser() u: JwtPayload, @Param("id", ParseUUIDPipe) id: string) {
    return { ok: true, data: await this.ot.lineaTiempo(u, id) };
  }

  @Get(":id/historial")
  async historial(@CurrentUser() u: JwtPayload, @Param("id", ParseUUIDPipe) id: string) {
    return { ok: true, data: await this.ot.historial(u, id) };
  }

  @Roles("coordinador", "administrador")
  @Post()
  async crear(@CurrentUser() u: JwtPayload, @Body() dto: CrearOtDto) {
    return { ok: true, data: await this.ot.crearDesdeSolicitud(u, dto) };
  }

  @Roles("coordinador", "administrador")
  @Post(":id/derivadas")
  async crearDerivada(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: CrearDerivadaDto,
  ) {
    return { ok: true, data: await this.ot.crearDerivada(u, id, dto) };
  }

  @Roles("coordinador", "tecnico", "administrador")
  @Patch(":id/estado")
  async cambiarEstado(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: CambiarEstadoDto,
  ) {
    return { ok: true, data: await this.ot.cambiarEstado(u, id, dto.estado, dto.motivo, dto.motivoId) };
  }

  /**
   * Cancelar tiene una respuesta "no ok" legítima: cuando hay derivadas activas
   * y el tratamiento es "bloquear", la base devuelve la lista para que el
   * usuario decida. Se propaga tal cual en lugar de convertirla en un 4xx.
   */
  @Roles("coordinador", "administrador")
  @Post(":id/cancelar")
  async cancelar(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: CancelarOtDto,
  ) {
    return this.ot.cancelar(
      u, id, dto.motivoId ?? null, dto.observacion, dto.tratamientoDerivadas ?? "bloquear",
    );
  }

  @Roles("coordinador", "administrador")
  @Patch(":id/prioridad")
  async cambiarPrioridad(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: CambiarPrioridadDto,
  ) {
    return { ok: true, data: await this.ot.cambiarPrioridad(u, id, dto.prioridad, dto.motivo) };
  }

  @Roles("coordinador", "administrador")
  @Patch(":id")
  async actualizar(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: ActualizarOtDto,
  ) {
    return { ok: true, data: await this.ot.actualizar(u, id, dto) };
  }
}
