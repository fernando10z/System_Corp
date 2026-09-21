import { Injectable } from "@nestjs/common";
import { ConversacionesRepository } from "./conversaciones.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";
import type {
  EditarMensajeDto,
  InvitarParticipanteDto,
  PublicarMensajeDto,
} from "./dto/conversaciones.dto";

@Injectable()
export class ConversacionesService {
  constructor(private readonly repo: ConversacionesRepository) {}
  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }
  publicar(u: JwtPayload, otId: string, d: PublicarMensajeDto) {
    return this.repo.publicar(this.ctx(u), otId, d);
  }
  editar(u: JwtPayload, id: string, d: EditarMensajeDto) {
    return this.repo.editar(this.ctx(u), id, d);
  }
  retirar(u: JwtPayload, id: string, motivo?: string) {
    return this.repo.retirar(this.ctx(u), id, motivo);
  }
  invitar(u: JwtPayload, otId: string, d: InvitarParticipanteDto) {
    return this.repo.invitar(this.ctx(u), otId, d);
  }
  lineaTiempo(u: JwtPayload, otId: string) {
    return this.repo.lineaTiempo(this.ctx(u), otId);
  }
}
