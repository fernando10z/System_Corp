import { Injectable } from "@nestjs/common";
import { OrganizacionRepository } from "./organizacion.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class OrganizacionService {
  constructor(private readonly repo: OrganizacionRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  arbol(u: JwtPayload) { return this.repo.arbol(this.ctx(u)); }
  crearSucursal(u: JwtPayload, c: string, n: string, d?: string) { return this.repo.crearSucursal(this.ctx(u), c, n, d); }
  crearEmpresaRuc(u: JwtPayload, ruc: string, rs: string, nc?: string, s?: string[]) {
    return this.repo.crearEmpresaRuc(this.ctx(u), ruc, rs, nc, s);
  }
  inactivarEmpresaRuc(u: JwtPayload, id: string, motivo: string) {
    return this.repo.inactivarEmpresaRuc(this.ctx(u), id, motivo);
  }
  crearArea(u: JwtPayload, e: string, c: string, n: string) { return this.repo.crearArea(this.ctx(u), e, c, n); }
  listarAreas(u: JwtPayload, f: Record<string, unknown>) { return this.repo.listarAreas(this.ctx(u), f); }
}
