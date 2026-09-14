import { Body, Controller, Get, Put } from "@nestjs/common";
import { ConfiguracionService } from "./configuracion.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import { GuardarConfiguracionDto } from "./dto/configuracion.dto";

@Controller("configuracion")
export class ConfiguracionController {
  constructor(private readonly config: ConfiguracionService) {}

  /**
   * Devuelve también la lista de lo que NO es configurable, para que la interfaz
   * no ofrezca cambiar lo que el cap. 17 declara parte del flujo base.
   */
  @Get()
  async obtener(@CurrentUser() u: JwtPayload) {
    return { ok: true, data: await this.config.obtener(u) };
  }

  @Roles("administrador")
  @Put()
  async guardar(@CurrentUser() u: JwtPayload, @Body() dto: GuardarConfiguracionDto) {
    return { ok: true, data: await this.config.guardar(u, dto.clave, dto.valor, dto.descripcion) };
  }
}
