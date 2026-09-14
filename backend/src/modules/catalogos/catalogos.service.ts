import { Injectable } from "@nestjs/common";
import { CatalogosRepository } from "./catalogos.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class CatalogosService {
  constructor(private readonly repo: CatalogosRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  listar(u: JwtPayload, tipo?: string) { return this.repo.listar(this.ctx(u), tipo); }
  crearItem(u: JwtPayload, a: Parameters<CatalogosRepository["crearItem"]>[1]) { return this.repo.crearItem(this.ctx(u), a); }
  tiposTrabajo(u: JwtPayload) { return this.repo.tiposTrabajo(this.ctx(u)); }
  crearTipoTrabajo(u: JwtPayload, c: string, n: string, p?: string, d?: string) {
    return this.repo.crearTipoTrabajo(this.ctx(u), c, n, p, d);
  }
  proveedores(u: JwtPayload, f: Record<string, unknown>, p: number, s: number) {
    return this.repo.proveedores(this.ctx(u), f, p, s);
  }
  crearProveedor(u: JwtPayload, a: Parameters<CatalogosRepository["crearProveedor"]>[1]) {
    return this.repo.crearProveedor(this.ctx(u), a);
  }
}
