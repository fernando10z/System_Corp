import { Injectable } from "@nestjs/common";
import { CostosRepository } from "./costos.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";
import type { CalificarCostoDto, RegistrarCostoDto } from "./dto/costos.dto";

@Injectable()
export class CostosService {
  constructor(private readonly repo: CostosRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  registrar(u: JwtPayload, otId: string, d: RegistrarCostoDto) { return this.repo.registrar(this.ctx(u), otId, d); }
  calificar(u: JwtPayload, id: string, d: CalificarCostoDto) { return this.repo.calificar(this.ctx(u), id, d); }
  historico(u: JwtPayload, f: Record<string, unknown>) { return this.repo.historico(this.ctx(u), f); }
}
