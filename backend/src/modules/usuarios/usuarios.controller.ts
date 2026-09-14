import { Body, Controller, Get, Param, ParseUUIDPipe, Post, Query } from "@nestjs/common";
import { UsuariosService } from "./usuarios.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import { CrearUsuarioDto, InactivarUsuarioDto } from "./dto/usuarios.dto";

@Controller("usuarios")
export class UsuariosController {
  constructor(private readonly usuarios: UsuariosService) {}

  @Get()
  async listar(
    @CurrentUser() u: JwtPayload,
    @Query("buscar") buscar?: string,
    @Query("estado") estado?: string,
    @Query("rol") rol?: string,
    @Query("page") page?: string,
    @Query("pageSize") pageSize?: string,
  ) {
    const r = await this.usuarios.listar(
      u, { buscar, estado, rol }, page ? Number(page) : 1, pageSize ? Number(pageSize) : 20,
    );
    return { ok: true, data: r?.data ?? [], meta: r?.meta };
  }

  @Roles("administrador")
  @Post()
  async crear(@CurrentUser() u: JwtPayload, @Body() dto: CrearUsuarioDto) {
    return { ok: true, data: await this.usuarios.crear(u, dto) };
  }

  /** Inactivar, nunca borrar: la historia conserva al autor (Anexo C, QA-23). */
  @Roles("administrador")
  @Post(":id/inactivar")
  async inactivar(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: InactivarUsuarioDto,
  ) {
    return { ok: true, data: await this.usuarios.inactivar(u, id, dto.motivo) };
  }
}
