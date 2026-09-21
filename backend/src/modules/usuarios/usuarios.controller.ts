import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post, Query } from "@nestjs/common";
import { UsuariosService } from "./usuarios.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import {
  ActualizarUsuarioDto,
  CrearUsuarioDto,
  InactivarUsuarioDto,
  RestablecerPasswordDto,
} from "./dto/usuarios.dto";

@Controller("usuarios")
export class UsuariosController {
  constructor(private readonly usuarios: UsuariosService) {}

  @Get()
  async listar(
    @CurrentUser() u: JwtPayload,
    @Query("buscar") buscar?: string,
    @Query("estado") estado?: string,
    @Query("rol") rol?: string,
    @Query("desde") desde?: string,
    @Query("hasta") hasta?: string,
    @Query("page") page?: string,
    @Query("pageSize") pageSize?: string,
  ) {
    const r = await this.usuarios.listar(
      u,
      { buscar, estado, rol, desde, hasta },
      page ? Number(page) : 1,
      pageSize ? Number(pageSize) : 20,
    );
    return { ok: true, data: r?.data ?? [], meta: r?.meta };
  }

  /**
   * Personas a las que se puede asignar trabajo. Va ANTES de cualquier ruta con
   * parámetro para que "asignables" no se interprete como un id.
   */
  @Get("asignables")
  async asignables(@CurrentUser() u: JwtPayload, @Query("rol") rol?: string) {
    return { ok: true, data: await this.usuarios.asignables(u, rol) };
  }

  @Roles("administrador")
  @Post()
  async crear(@CurrentUser() u: JwtPayload, @Body() dto: CrearUsuarioDto) {
    return { ok: true, data: await this.usuarios.crear(u, dto) };
  }

  @Roles("administrador")
  @Patch(":id")
  async actualizar(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: ActualizarUsuarioDto,
  ) {
    return { ok: true, data: await this.usuarios.actualizar(u, id, dto) };
  }

  /**
   * Restablecer la contraseña de otro usuario. No pide la anterior —quien la
   * olvidó no la sabe— y por eso se audita como acción de administración.
   */
  @Roles("administrador")
  @Post(":id/password")
  async restablecerPassword(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() dto: RestablecerPasswordDto,
  ) {
    return { ok: true, data: await this.usuarios.restablecerPassword(u, id, dto.passwordNueva) };
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
