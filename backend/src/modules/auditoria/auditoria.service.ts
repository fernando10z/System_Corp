import { Injectable } from "@nestjs/common";
import { AuditoriaRepository } from "./auditoria.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class AuditoriaService {
  constructor(private readonly repo: AuditoriaRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  listar(u: JwtPayload, f: Record<string, unknown>, p: number, s: number) {
    return this.repo.listar(this.ctx(u), f, p, s);
  }
}
