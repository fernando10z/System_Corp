import { Injectable } from "@nestjs/common";
import { EjecucionRepository } from "./ejecucion.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";
import type {
  DeclararTrabajoDto,
  IniciarEjecucionDto,
  PausarDto,
  RegistrarAvanceDto,
  RegistrarIncidenciaDto,
} from "./dto/ejecucion.dto";

@Injectable()
export class EjecucionService {
  constructor(private readonly repo: EjecucionRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  iniciar(u: JwtPayload, otId: string, d: IniciarEjecucionDto) {
    return this.repo.iniciar(this.ctx(u), otId, d);
  }
  avance(u: JwtPayload, otId: string, d: RegistrarAvanceDto) {
    return this.repo.avance(this.ctx(u), otId, d);
  }
  incidencia(u: JwtPayload, otId: string, d: RegistrarIncidenciaDto) {
    return this.repo.incidencia(this.ctx(u), otId, d);
  }
  pausar(u: JwtPayload, otId: string, d: PausarDto) {
    return this.repo.pausar(this.ctx(u), otId, d);
  }
  reanudar(u: JwtPayload, otId: string, obs?: string) {
    return this.repo.reanudar(this.ctx(u), otId, obs);
  }
  declararTrabajo(u: JwtPayload, otId: string, d: DeclararTrabajoDto) {
    return this.repo.declararTrabajo(this.ctx(u), otId, d);
  }
}
