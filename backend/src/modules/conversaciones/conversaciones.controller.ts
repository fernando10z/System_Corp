import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post } from "@nestjs/common";
import { ConversacionesService } from "./conversaciones.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import {
  EditarMensajeDto,
  InvitarParticipanteDto,
  PublicarMensajeDto,
} from "./dto/conversaciones.dto";

@Controller()
export class ConversacionesController {
  constructor(private readonly conv: ConversacionesService) {}

  @Get("ot/:otId/conversacion")
  async lineaTiempo(@CurrentUser() u: JwtPayload, @Param("otId", ParseUUIDPipe) otId: string) {
    return { ok: true, data: await this.conv.lineaTiempo(u, otId) };
  }

  @Post("ot/:otId/mensajes")
  async publicar(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: PublicarMensajeDto,
  ) {
    return { ok: true, data: await this.conv.publicar(u, otId, dto) };
  }

  @Patch("mensajes/:id")
  async editar(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: EditarMensajeDto,
  ) {
    return { ok: true, data: await this.conv.editar(u, id, dto) };
  }

  @Post("mensajes/:id/retirar")
  async retirar(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() body: { motivo?: string },
  ) {
    return { ok: true, data: await this.conv.retirar(u, id, body?.motivo) };
  }

  @Roles("coordinador", "administrador")
  @Post("ot/:otId/participantes")
  async invitar(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: InvitarParticipanteDto,
  ) {
    return { ok: true, data: await this.conv.invitar(u, otId, dto) };
  }
}
