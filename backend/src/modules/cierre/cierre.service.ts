import { Injectable } from "@nestjs/common";
import { CierreRepository } from "./cierre.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";
import type {
  CerrarOtDto,
  ConformidadDto,
  ReabrirOtDto,
  RevisarTrabajoDto,
} from "./dto/cierre.dto";

@Injectable()
export class CierreService {
  constructor(private readonly repo: CierreRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  revisar(u: JwtPayload, otId: string, d: RevisarTrabajoDto) {
    return this.repo.revisar(this.ctx(u), otId, d);
  }
  conformidad(u: JwtPayload, otId: string, d: ConformidadDto) {
    return this.repo.conformidad(this.ctx(u), otId, d);
  }
  cerrar(u: JwtPayload, otId: string, d: CerrarOtDto) {
    return this.repo.cerrar(this.ctx(u), otId, d);
  }
  reabrir(u: JwtPayload, otId: string, d: ReabrirOtDto) {
    return this.repo.reabrir(this.ctx(u), otId, d);
  }
}
