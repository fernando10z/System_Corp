import { Controller, Get, Query } from "@nestjs/common";
import { DashboardsService } from "./dashboards.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";

@Controller("dashboard")
export class DashboardsController {
  constructor(private readonly dashboards: DashboardsService) {}

  /** Bandeja accionable del cap. 35.1: cada bloque habilita una acción concreta. */
  @Get("coordinador")
  async coordinador(@CurrentUser() u: JwtPayload) {
    return { ok: true, data: await this.dashboards.coordinador(u) };
  }

  @Get("solicitante")
  async solicitante(@CurrentUser() u: JwtPayload) {
    return { ok: true, data: await this.dashboards.solicitante(u) };
  }

  @Get("kpis")
  async kpis(
    @CurrentUser() u: JwtPayload,
    @Query("desde") desde?: string,
    @Query("hasta") hasta?: string,
    @Query("sucursalId") sucursalId?: string,
    @Query("empresaRucId") empresaRucId?: string,
    @Query("areaId") areaId?: string,
  ) {
    return { ok: true, data: await this.dashboards.kpis(u, { desde, hasta, sucursalId, empresaRucId, areaId }) };
  }
}
