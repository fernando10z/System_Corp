import { Body, Controller, Get, Param, ParseUUIDPipe, Post, Query } from "@nestjs/common";
import { CostosService } from "./costos.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import { CalificarCostoDto, RegistrarCostoDto } from "./dto/costos.dto";

@Controller()
export class CostosController {
  constructor(private readonly costos: CostosService) {}

  /**
   * El histórico devuelve SIEMPRE el contexto: número de casos, umbral, moneda y
   * filtros usados. Sin eso, un promedio es un número que engaña (cap. 32.4).
   */
  @Get("costos/historico")
  async historico(
    @CurrentUser() u: JwtPayload,
    @Query("tipoTrabajoId") tipoTrabajoId?: string,
    @Query("empresaRucId") empresaRucId?: string,
    @Query("sucursalId") sucursalId?: string,
    @Query("areaId") areaId?: string,
    @Query("proveedorId") proveedorId?: string,
    @Query("moneda") moneda?: string,
    @Query("desde") desde?: string,
    @Query("hasta") hasta?: string,
    @Query("incluirOutliers") incluirOutliers?: string,
  ) {
    return {
      ok: true,
      data: await this.costos.historico(u, {
        tipoTrabajoId, empresaRucId, sucursalId, areaId, proveedorId,
        moneda: moneda ?? "PEN", desde, hasta,
        incluirOutliers: incluirOutliers === "true" ? true : undefined,
      }),
    };
  }

  @Roles("coordinador", "administrador")
  @Post("ot/:otId/costos")
  async registrar(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: RegistrarCostoDto,
  ) {
    return { ok: true, data: await this.costos.registrar(u, otId, dto) };
  }

  @Roles("coordinador", "administrador")
  @Post("costos/:id/calificar")
  async calificar(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: CalificarCostoDto,
  ) {
    return { ok: true, data: await this.costos.calificar(u, id, dto) };
  }
}
