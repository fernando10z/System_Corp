import { Injectable } from "@nestjs/common";
import { RolesRepository } from "./roles.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class RolesService {
  constructor(private readonly repo: RolesRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  listarRoles(u: JwtPayload) {
    return this.repo.listarRoles(this.ctx(u));
  }
  listarPermisos(u: JwtPayload) {
    return this.repo.listarPermisos(this.ctx(u));
  }
  asignarPermisos(u: JwtPayload, rolId: string, codigos: string[]) {
    return this.repo.asignarPermisos(this.ctx(u), rolId, codigos);
  }
}
