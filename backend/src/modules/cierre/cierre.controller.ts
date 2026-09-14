import { Body, Controller, Param, ParseUUIDPipe, Post } from "@nestjs/common";
import { CierreService } from "./cierre.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import { CerrarOtDto, ConformidadDto, ReabrirOtDto, RevisarTrabajoDto } from "./dto/cierre.dto";

@Controller("ot/:otId")
export class CierreController {
  constructor(private readonly cierre: CierreService) {}

  @Roles("coordinador", "administrador")
  @Post("revisar")
  async revisar(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: RevisarTrabajoDto,
  ) {
    return { ok: true, data: await this.cierre.revisar(u, otId, dto) };
  }

  /** La conformidad del solicitante es opcional y no bloquea el cierre. */
  @Post("conformidad")
  async conformidad(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: ConformidadDto,
  ) {
    return { ok: true, data: await this.cierre.conformidad(u, otId, dto) };
  }

  /**
   * Se devuelve el sobre tal cual: cuando falta la confirmación del pendiente
   * administrativo, la base responde ok:false CON los datos que la interfaz
   * necesita para pedirla. No es un error del cliente, es un paso del flujo.
   */
  @Roles("coordinador", "administrador")
  @Post("cerrar")
  async cerrar(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: CerrarOtDto,
  ) {
    return this.cierre.cerrar(u, otId, dto);
  }

  @Roles("coordinador", "administrador")
  @Post("reabrir")
  async reabrir(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: ReabrirOtDto,
  ) {
    return { ok: true, data: await this.cierre.reabrir(u, otId, dto) };
  }
}
