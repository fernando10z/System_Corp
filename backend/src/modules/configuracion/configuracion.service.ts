import { Injectable } from "@nestjs/common";
import { ConfiguracionRepository } from "./configuracion.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class ConfiguracionService {
  constructor(private readonly repo: ConfiguracionRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  obtener(u: JwtPayload) {
    return this.repo.obtener(this.ctx(u));
  }
  guardar(u: JwtPayload, clave: string, valor: unknown, descripcion?: string) {
    return this.repo.guardar(this.ctx(u), clave, valor, descripcion);
  }
}
