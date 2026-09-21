import { Body, Controller, Get, Post, Query } from "@nestjs/common";
import { NotificacionesService } from "./notificaciones.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";

@Controller("notificaciones")
export class NotificacionesController {
  constructor(private readonly notificaciones: NotificacionesService) {}

  @Get()
  async listar(
    @CurrentUser() u: JwtPayload,
    @Query("soloNoLeidas") soloNoLeidas?: string,
    @Query("limite") limite?: string,
  ) {
    const r = await this.notificaciones.listar(
      u,
      soloNoLeidas === "true",
      limite ? Number(limite) : 50,
    );
    return { ok: true, data: r?.data ?? [], meta: r?.meta };
  }

  /** Sin id marca todas: es el "marcar todo como leído" de la campana. */
  @Post("marcar-leida")
  async marcarLeida(@CurrentUser() u: JwtPayload, @Body() body: { id?: string }) {
    return { ok: true, data: await this.notificaciones.marcarLeida(u, body?.id) };
  }

  @Get("sla")
  async sla(@CurrentUser() u: JwtPayload) {
    const r = await this.notificaciones.sla(u);
    return { ok: true, data: r?.data ?? [], meta: r?.meta };
  }
}
