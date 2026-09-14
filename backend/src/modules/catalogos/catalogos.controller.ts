import { Body, Controller, Get, Post, Query } from "@nestjs/common";
import { CatalogosService } from "./catalogos.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import { CrearItemCatalogoDto, CrearProveedorDto, CrearTipoTrabajoDto } from "./dto/catalogos.dto";

@Controller()
export class CatalogosController {
  constructor(private readonly catalogos: CatalogosService) {}

  @Get("catalogos")
  async listar(@CurrentUser() u: JwtPayload, @Query("tipo") tipo?: string) {
    return { ok: true, data: await this.catalogos.listar(u, tipo) };
  }

  @Roles("administrador")
  @Post("catalogos")
  async crearItem(@CurrentUser() u: JwtPayload, @Body() dto: CrearItemCatalogoDto) {
    return { ok: true, data: await this.catalogos.crearItem(u, dto) };
  }

  @Get("tipos-trabajo")
  async tiposTrabajo(@CurrentUser() u: JwtPayload) {
    return { ok: true, data: await this.catalogos.tiposTrabajo(u) };
  }

  @Roles("administrador", "coordinador")
  @Post("tipos-trabajo")
  async crearTipoTrabajo(@CurrentUser() u: JwtPayload, @Body() dto: CrearTipoTrabajoDto) {
    return { ok: true, data: await this.catalogos.crearTipoTrabajo(u, dto.codigo, dto.nombre, dto.padreId, dto.descripcion) };
  }

  @Get("proveedores")
  async proveedores(
    @CurrentUser() u: JwtPayload,
    @Query("buscar") buscar?: string,
    @Query("page") page?: string,
    @Query("pageSize") pageSize?: string,
  ) {
    const r = await this.catalogos.proveedores(
      u, { buscar }, page ? Number(page) : 1, pageSize ? Number(pageSize) : 20,
    );
    return { ok: true, data: r?.data ?? [], meta: r?.meta };
  }

  @Roles("administrador", "coordinador", "abastecimiento")
  @Post("proveedores")
  async crearProveedor(@CurrentUser() u: JwtPayload, @Body() dto: CrearProveedorDto) {
    return { ok: true, data: await this.catalogos.crearProveedor(u, dto) };
  }
}
