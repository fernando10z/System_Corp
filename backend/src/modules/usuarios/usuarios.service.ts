import { Injectable } from "@nestjs/common";
import { UsuariosRepository } from "./usuarios.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";
import type { CrearUsuarioDto } from "./dto/usuarios.dto";

@Injectable()
export class UsuariosService {
  constructor(private readonly repo: UsuariosRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  listar(u: JwtPayload, f: Record<string, unknown>, p: number, s: number) { return this.repo.listar(this.ctx(u), f, p, s); }
  crear(u: JwtPayload, d: CrearUsuarioDto) { return this.repo.crear(this.ctx(u), d); }
  inactivar(u: JwtPayload, id: string, motivo: string) { return this.repo.inactivar(this.ctx(u), id, motivo); }
}
