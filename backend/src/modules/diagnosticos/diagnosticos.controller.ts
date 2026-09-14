import { Body, Controller, Get, Param, ParseUUIDPipe, Post } from "@nestjs/common";
import { DiagnosticosService } from "./diagnosticos.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import { RegistrarDiagnosticoDto } from "./dto/registrar-diagnostico.dto";

@Controller()
export class DiagnosticosController {
  constructor(private readonly diagnosticos: DiagnosticosService) {}

  @Get("ot/:otId/diagnosticos")
  async listar(@CurrentUser() u: JwtPayload, @Param("otId", ParseUUIDPipe) otId: string) {
    return { ok: true, data: await this.diagnosticos.listar(u, otId) };
  }

  @Roles("tecnico", "coordinador", "administrador")
  @Post("ot/:otId/diagnosticos")
  async registrar(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: RegistrarDiagnosticoDto,
  ) {
    return { ok: true, data: await this.diagnosticos.registrar(u, otId, dto) };
  }

  @Roles("coordinador", "administrador")
  @Post("diagnosticos/:id/aprobar")
  async aprobar(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() body: { observacion?: string },
  ) {
    return { ok: true, data: await this.diagnosticos.aprobar(u, id, body?.observacion) };
  }
}
