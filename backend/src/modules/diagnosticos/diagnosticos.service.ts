import { Injectable } from "@nestjs/common";
import { DiagnosticosRepository } from "./diagnosticos.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";
import type { RegistrarDiagnosticoDto } from "./dto/registrar-diagnostico.dto";

@Injectable()
export class DiagnosticosService {
  constructor(private readonly repo: DiagnosticosRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  listar(u: JwtPayload, otId: string) { return this.repo.listar(this.ctx(u), otId); }
  registrar(u: JwtPayload, otId: string, d: RegistrarDiagnosticoDto) { return this.repo.registrar(this.ctx(u), otId, d); }
  aprobar(u: JwtPayload, id: string, obs?: string) { return this.repo.aprobar(this.ctx(u), id, obs); }
}
