import { Body, Controller, Get, Param, ParseUUIDPipe, Put } from "@nestjs/common";
import { RolesService } from "./roles.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";

@Controller()
export class RolesController {
  constructor(private readonly roles: RolesService) {}

  @Get("roles")
  async listar(@CurrentUser() u: JwtPayload) {
    return { ok: true, data: await this.roles.listarRoles(u) };
  }

  @Get("permisos")
  async permisos(@CurrentUser() u: JwtPayload) {
    return { ok: true, data: await this.roles.listarPermisos(u) };
  }

  /**
   * Reemplaza el set completo de permisos del rol. La matriz del Anexo B es una
   * base funcional, no la política final de cada organización: por eso se puede
   * reasignar, siempre con rastro en la auditoría.
   */
  @Roles("administrador")
  @Put("roles/:id/permisos")
  async asignar(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() body: { permisos: string[] },
  ) {
    return { ok: true, data: await this.roles.asignarPermisos(u, id, body.permisos ?? []) };
  }
}
