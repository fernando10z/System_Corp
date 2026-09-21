import { Injectable } from "@nestjs/common";
import { ReportesRepository } from "./reportes.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class ReportesService {
  constructor(private readonly repo: ReportesRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  ot(u: JwtPayload, f: Record<string, unknown>, limite?: number) {
    return this.repo.ot(this.ctx(u), f, limite);
  }
}
