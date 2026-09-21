import { Injectable } from "@nestjs/common";
import { DashboardsRepository } from "./dashboards.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class DashboardsService {
  constructor(private readonly repo: DashboardsRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  coordinador(u: JwtPayload) {
    return this.repo.coordinador(this.ctx(u));
  }
  solicitante(u: JwtPayload) {
    return this.repo.solicitante(this.ctx(u));
  }
  kpis(u: JwtPayload, f: Record<string, unknown>) {
    return this.repo.kpis(this.ctx(u), f);
  }
}
