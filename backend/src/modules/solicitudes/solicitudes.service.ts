import { Injectable } from "@nestjs/common";
import { SolicitudesRepository } from "./solicitudes.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";
import type { CrearSolicitudDto } from "./dto/crear-solicitud.dto";
import type { DecidirSolicitudDto } from "./dto/decidir-solicitud.dto";

@Injectable()
export class SolicitudesService {
  constructor(private readonly repo: SolicitudesRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  listar(u: JwtPayload, f: Record<string, unknown>, p: number, s: number) { return this.repo.listar(this.ctx(u), f, p, s); }
  obtener(u: JwtPayload, id: string) { return this.repo.obtener(this.ctx(u), id); }
  crear(u: JwtPayload, d: CrearSolicitudDto) { return this.repo.crear(this.ctx(u), d); }
  enviar(u: JwtPayload, id: string) { return this.repo.enviar(this.ctx(u), id); }
  tomarRevision(u: JwtPayload, id: string) { return this.repo.tomarRevision(this.ctx(u), id); }
  decidir(u: JwtPayload, id: string, d: DecidirSolicitudDto) { return this.repo.decidir(this.ctx(u), id, d); }
}
