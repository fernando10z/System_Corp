import { Injectable } from "@nestjs/common";
import { UsuariosRepository } from "./usuarios.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";
import type { ActualizarUsuarioDto, CrearUsuarioDto } from "./dto/usuarios.dto";

@Injectable()
export class UsuariosService {
  constructor(private readonly repo: UsuariosRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  listar(u: JwtPayload, f: Record<string, unknown>, p: number, s: number) {
    return this.repo.listar(this.ctx(u), f, p, s);
  }

  asignables(u: JwtPayload, rol?: string) {
    return this.repo.asignables(this.ctx(u), rol);
  }
  crear(u: JwtPayload, d: CrearUsuarioDto) {
    return this.repo.crear(this.ctx(u), d);
  }
  actualizar(u: JwtPayload, id: string, d: ActualizarUsuarioDto) {
    return this.repo.actualizar(this.ctx(u), id, d);
  }
  restablecerPassword(u: JwtPayload, id: string, passwordNueva: string) {
    return this.repo.restablecerPassword(this.ctx(u), id, passwordNueva);
  }
  inactivar(u: JwtPayload, id: string, motivo: string) {
    return this.repo.inactivar(this.ctx(u), id, motivo);
  }
}
