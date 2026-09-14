import { Controller, Get, Query } from "@nestjs/common";
import { ReportesService } from "./reportes.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";

@Controller("reportes")
export class ReportesController {
  constructor(private readonly reportes: ReportesService) {}

  /**
   * Filtros del cap. 20.3. El reporte omite las columnas de costo si el usuario
   * no tiene el permiso: la poda la hace el SP, no el frontend.
   */
  @Get("ot")
  async ot(
    @CurrentUser() u: JwtPayload,
    @Query("desde") desde?: string,
    @Query("hasta") hasta?: string,
    @Query("sucursalId") sucursalId?: string,
    @Query("empresaRucId") empresaRucId?: string,
    @Query("areaId") areaId?: string,
    @Query("estado") estado?: string,
    @Query("prioridadTecnica") prioridadTecnica?: string,
    @Query("tipoTrabajoId") tipoTrabajoId?: string,
    @Query("responsableId") responsableId?: string,
    @Query("emergencia") emergencia?: string,
    @Query("limite") limite?: string,
  ) {
    const r = await this.reportes.ot(
      u,
      {
        desde, hasta, sucursalId, empresaRucId, areaId, estado,
        prioridadTecnica, tipoTrabajoId, responsableId,
        emergencia: emergencia === undefined ? undefined : emergencia === "true",
      },
      limite ? Number(limite) : 5000,
    );
    return { ok: true, data: r?.data ?? [], meta: r?.meta };
  }
}
