import { Body, Controller, Param, ParseUUIDPipe, Post } from "@nestjs/common";
import { EjecucionService } from "./ejecucion.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import {
  DeclararTrabajoDto, IniciarEjecucionDto, PausarDto, ReanudarDto,
  RegistrarAvanceDto, RegistrarIncidenciaDto,
} from "./dto/ejecucion.dto";

@Controller("ot/:otId")
export class EjecucionController {
  constructor(private readonly ejecucion: EjecucionService) {}

  @Roles("coordinador", "administrador")
  @Post("iniciar")
  async iniciar(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: IniciarEjecucionDto,
  ) {
    return { ok: true, data: await this.ejecucion.iniciar(u, otId, dto) };
  }

  @Roles("tecnico", "coordinador", "administrador")
  @Post("avances")
  async avance(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: RegistrarAvanceDto,
  ) {
    return { ok: true, data: await this.ejecucion.avance(u, otId, dto) };
  }

  @Roles("tecnico", "coordinador", "administrador")
  @Post("incidencias")
  async incidencia(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: RegistrarIncidenciaDto,
  ) {
    return { ok: true, data: await this.ejecucion.incidencia(u, otId, dto) };
  }

  @Roles("tecnico", "coordinador", "administrador")
  @Post("pausar")
  async pausar(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: PausarDto,
  ) {
    return { ok: true, data: await this.ejecucion.pausar(u, otId, dto) };
  }

  @Roles("tecnico", "coordinador", "administrador")
  @Post("reanudar")
  async reanudar(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: ReanudarDto,
  ) {
    return { ok: true, data: await this.ejecucion.reanudar(u, otId, dto?.observacion) };
  }

  @Roles("tecnico", "coordinador", "administrador")
  @Post("trabajo-realizado")
  async declarar(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: DeclararTrabajoDto,
  ) {
    return { ok: true, data: await this.ejecucion.declararTrabajo(u, otId, dto) };
  }
}
