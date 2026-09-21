import { Injectable } from "@nestjs/common";
import { AdministrativoRepository } from "./administrativo.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";
import type {
  AnularSolpedDto,
  NumeroSapDto,
  PrepararSolpedDto,
  RegistrarLiberacionDto,
  RegistrarOcDto,
} from "./dto/administrativo.dto";

@Injectable()
export class AdministrativoService {
  constructor(private readonly repo: AdministrativoRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  obtener(u: JwtPayload, otId: string) {
    return this.repo.obtener(this.ctx(u), otId);
  }
  prepararSolped(u: JwtPayload, otId: string, d: PrepararSolpedDto) {
    return this.repo.prepararSolped(this.ctx(u), otId, d);
  }
  marcarLista(u: JwtPayload, id: string) {
    return this.repo.marcarLista(this.ctx(u), id);
  }
  registrarNumeroSap(u: JwtPayload, id: string, d: NumeroSapDto) {
    return this.repo.registrarNumeroSap(this.ctx(u), id, d);
  }
  anularSolped(u: JwtPayload, id: string, d: AnularSolpedDto) {
    return this.repo.anularSolped(this.ctx(u), id, d);
  }
  registrarOc(u: JwtPayload, otId: string, d: RegistrarOcDto) {
    return this.repo.registrarOc(this.ctx(u), otId, d);
  }
  registrarLiberacion(u: JwtPayload, otId: string, d: RegistrarLiberacionDto) {
    return this.repo.registrarLiberacion(this.ctx(u), otId, d);
  }
}
