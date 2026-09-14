import { Body, Controller, Get, Param, ParseUUIDPipe, Post } from "@nestjs/common";
import { CotizacionesService } from "./cotizaciones.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import { CargarCotizacionDto } from "./dto/cargar-cotizacion.dto";

@Controller()
export class CotizacionesController {
  constructor(private readonly cotizaciones: CotizacionesService) {}

  @Get("ot/:otId/cotizaciones")
  async listar(@CurrentUser() u: JwtPayload, @Param("otId", ParseUUIDPipe) otId: string) {
    return { ok: true, data: await this.cotizaciones.listar(u, otId) };
  }

  @Roles("coordinador", "abastecimiento", "administrador")
  @Post("ot/:otId/cotizaciones")
  async cargar(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: CargarCotizacionDto,
  ) {
    return { ok: true, data: await this.cotizaciones.cargar(u, otId, dto) };
  }

  @Roles("coordinador", "abastecimiento", "administrador")
  @Post("cotizaciones/:id/invalidar")
  async invalidar(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() body: { motivo: string },
  ) {
    return { ok: true, data: await this.cotizaciones.invalidar(u, id, body.motivo) };
  }
}
