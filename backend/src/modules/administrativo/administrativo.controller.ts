import { Body, Controller, Get, Param, ParseUUIDPipe, Post } from "@nestjs/common";
import { AdministrativoService } from "./administrativo.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import {
  AnularSolpedDto, NumeroSapDto, PrepararSolpedDto, RegistrarLiberacionDto, RegistrarOcDto,
} from "./dto/administrativo.dto";

@Controller()
export class AdministrativoController {
  constructor(private readonly admin: AdministrativoService) {}

  @Get("ot/:otId/administrativo")
  async obtener(@CurrentUser() u: JwtPayload, @Param("otId", ParseUUIDPipe) otId: string) {
    return { ok: true, data: await this.admin.obtener(u, otId) };
  }

  /** El botón "Crear SOLPED" del cap. 22.2: prepara el registro interno. */
  @Roles("coordinador", "abastecimiento", "administrador")
  @Post("ot/:otId/solped")
  async prepararSolped(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: PrepararSolpedDto,
  ) {
    return { ok: true, data: await this.admin.prepararSolped(u, otId, dto) };
  }

  /**
   * Marca la SOLPED lista. NO la envía a SAP: no hay conector definido
   * (cap. 22.4). La respuesta lo dice explícitamente en vez de fingirlo.
   */
  @Roles("coordinador", "abastecimiento", "administrador")
  @Post("solped/:id/marcar-lista")
  async marcarLista(@CurrentUser() u: JwtPayload, @Param("id", ParseUUIDPipe) id: string) {
    return { ok: true, data: await this.admin.marcarLista(u, id) };
  }

  /** Captura manual del número oficial devuelto por SAP. */
  @Roles("coordinador", "abastecimiento", "administrador")
  @Post("solped/:id/numero-sap")
  async numeroSap(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: NumeroSapDto,
  ) {
    return { ok: true, data: await this.admin.registrarNumeroSap(u, id, dto) };
  }

  /** "Eliminar SOLPED" en la interfaz; internamente es anulación lógica. */
  @Roles("coordinador", "abastecimiento", "administrador")
  @Post("solped/:id/anular")
  async anular(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: AnularSolpedDto,
  ) {
    return { ok: true, data: await this.admin.anularSolped(u, id, dto) };
  }

  /** Registrar la OC después del cierre NO reabre la OT (QA-20). */
  @Roles("coordinador", "abastecimiento", "administrador")
  @Post("ot/:otId/orden-compra")
  async oc(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: RegistrarOcDto,
  ) {
    return { ok: true, data: await this.admin.registrarOc(u, otId, dto) };
  }

  @Roles("coordinador", "abastecimiento", "administrador")
  @Post("ot/:otId/liberacion")
  async liberacion(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: RegistrarLiberacionDto,
  ) {
    return { ok: true, data: await this.admin.registrarLiberacion(u, otId, dto) };
  }
}
