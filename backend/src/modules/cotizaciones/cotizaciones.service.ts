import { Injectable } from "@nestjs/common";
import { CotizacionesRepository } from "./cotizaciones.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";
import type { CargarCotizacionDto } from "./dto/cargar-cotizacion.dto";

@Injectable()
export class CotizacionesService {
  constructor(private readonly repo: CotizacionesRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  listar(u: JwtPayload, otId: string) { return this.repo.listar(this.ctx(u), otId); }
  cargar(u: JwtPayload, otId: string, d: CargarCotizacionDto) { return this.repo.cargar(this.ctx(u), otId, d); }
  invalidar(u: JwtPayload, id: string, motivo: string) { return this.repo.invalidar(this.ctx(u), id, motivo); }
}
