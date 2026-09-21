import { Body, Controller, Get, Param, ParseUUIDPipe, Post, Query } from "@nestjs/common";
import { OrganizacionService } from "./organizacion.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import {
  CrearAreaDto,
  CrearEmpresaRucDto,
  CrearSucursalDto,
  InactivarDto,
} from "./dto/organizacion.dto";

@Controller("organizacion")
export class OrganizacionController {
  constructor(private readonly org: OrganizacionService) {}

  /** Sucursal -> Empresa/RUC -> Área, tal como lo define el cap. 5. */
  @Get("arbol")
  async arbol(@CurrentUser() u: JwtPayload) {
    return { ok: true, data: await this.org.arbol(u) };
  }

  @Get("areas")
  async areas(@CurrentUser() u: JwtPayload, @Query("empresaRucId") empresaRucId?: string) {
    return { ok: true, data: await this.org.listarAreas(u, { empresaRucId }) };
  }

  @Roles("administrador")
  @Post("sucursales")
  async crearSucursal(@CurrentUser() u: JwtPayload, @Body() dto: CrearSucursalDto) {
    return {
      ok: true,
      data: await this.org.crearSucursal(u, dto.codigo, dto.nombre, dto.direccion),
    };
  }

  @Roles("administrador")
  @Post("empresas")
  async crearEmpresa(@CurrentUser() u: JwtPayload, @Body() dto: CrearEmpresaRucDto) {
    return {
      ok: true,
      data: await this.org.crearEmpresaRuc(
        u,
        dto.ruc,
        dto.razonSocial,
        dto.nombreCorto,
        dto.sucursalIds,
      ),
    };
  }

  @Roles("administrador")
  @Post("empresas/:id/inactivar")
  async inactivarEmpresa(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: InactivarDto,
  ) {
    return { ok: true, data: await this.org.inactivarEmpresaRuc(u, id, dto.motivo) };
  }

  @Roles("administrador")
  @Post("areas")
  async crearArea(@CurrentUser() u: JwtPayload, @Body() dto: CrearAreaDto) {
    return {
      ok: true,
      data: await this.org.crearArea(u, dto.empresaRucId, dto.codigo, dto.nombre),
    };
  }
}
