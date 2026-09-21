import { Body, Controller, Get, Param, ParseUUIDPipe, Post, Query } from "@nestjs/common";
import { SolicitudesService } from "./solicitudes.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import { CrearSolicitudDto } from "./dto/crear-solicitud.dto";
import { DecidirSolicitudDto } from "./dto/decidir-solicitud.dto";

@Controller("solicitudes")
export class SolicitudesController {
  constructor(private readonly solicitudes: SolicitudesService) {}

  @Get()
  async listar(
    @CurrentUser() u: JwtPayload,
    @Query("buscar") buscar?: string,
    @Query("estado") estado?: string,
    @Query("areaId") areaId?: string,
    @Query("mias") mias?: string,
    @Query("pendientesRevision") pendientesRevision?: string,
    @Query("desde") desde?: string,
    @Query("hasta") hasta?: string,
    @Query("page") page?: string,
    @Query("pageSize") pageSize?: string,
  ) {
    const r = await this.solicitudes.listar(
      u,
      {
        desde,
        hasta,
        buscar,
        estado,
        areaId,
        mias: mias === "true" ? true : undefined,
        pendientesRevision: pendientesRevision === "true" ? true : undefined,
      },
      page ? Number(page) : 1,
      pageSize ? Number(pageSize) : 20,
    );
    return { ok: true, data: r?.data ?? [], meta: r?.meta };
  }

  @Get(":id")
  async obtener(@CurrentUser() u: JwtPayload, @Param("id", ParseUUIDPipe) id: string) {
    return { ok: true, data: await this.solicitudes.obtener(u, id) };
  }

  @Post()
  async crear(@CurrentUser() u: JwtPayload, @Body() dto: CrearSolicitudDto) {
    return { ok: true, data: await this.solicitudes.crear(u, dto) };
  }

  @Post(":id/enviar")
  async enviar(@CurrentUser() u: JwtPayload, @Param("id", ParseUUIDPipe) id: string) {
    return { ok: true, data: await this.solicitudes.enviar(u, id) };
  }

  @Roles("coordinador", "administrador")
  @Post(":id/tomar-revision")
  async tomar(@CurrentUser() u: JwtPayload, @Param("id", ParseUUIDPipe) id: string) {
    return { ok: true, data: await this.solicitudes.tomarRevision(u, id) };
  }

  @Roles("coordinador", "administrador")
  @Post(":id/decidir")
  async decidir(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: DecidirSolicitudDto,
  ) {
    return { ok: true, data: await this.solicitudes.decidir(u, id, dto) };
  }
}
