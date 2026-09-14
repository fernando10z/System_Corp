import { Injectable } from "@nestjs/common";
import { OtRepository } from "./ot.repository";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";
import type { CrearOtDto } from "./dto/crear-ot.dto";
import type { CrearDerivadaDto } from "./dto/crear-derivada.dto";
import type { ActualizarOtDto } from "./dto/actualizar-ot.dto";

/**
 * Capa fina a propósito: su única responsabilidad real es traducir el JWT al
 * contexto que esperan los SP. La lógica de negocio vive en la base, y duplicarla
 * aquí sólo crearía dos verdades que acabarían divergiendo.
 */
@Injectable()
export class OtService {
  constructor(private readonly repo: OtRepository) {}

  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }

  listar(u: JwtPayload, filtros: Record<string, unknown>, page: number, pageSize: number) {
    return this.repo.listar(this.ctx(u), filtros, page, pageSize);
  }
  obtener(u: JwtPayload, id: string) { return this.repo.obtener(this.ctx(u), id); }
  trazabilidad(u: JwtPayload, id: string, prof?: number) { return this.repo.trazabilidad(this.ctx(u), id, prof); }
  jerarquia(u: JwtPayload, id: string) { return this.repo.jerarquia(this.ctx(u), id); }
  consolidado(u: JwtPayload, id: string) { return this.repo.consolidado(this.ctx(u), id); }
  lineaTiempo(u: JwtPayload, id: string) { return this.repo.lineaTiempo(this.ctx(u), id); }
  historial(u: JwtPayload, id: string) { return this.repo.historial(this.ctx(u), id); }

  crearDesdeSolicitud(u: JwtPayload, dto: CrearOtDto) { return this.repo.crearDesdeSolicitud(this.ctx(u), dto); }
  crearDerivada(u: JwtPayload, padreId: string, dto: CrearDerivadaDto) {
    return this.repo.crearDerivada(this.ctx(u), padreId, dto);
  }
  cambiarEstado(u: JwtPayload, id: string, estado: string, motivo?: string, motivoId?: string) {
    return this.repo.cambiarEstado(this.ctx(u), id, estado, motivo, motivoId);
  }
  cancelar(u: JwtPayload, id: string, motivoId: string | null, observacion: string, tratamiento: string) {
    return this.repo.cancelar(this.ctx(u), id, motivoId, observacion, tratamiento);
  }
  cambiarPrioridad(u: JwtPayload, id: string, prioridad: string, motivo?: string) {
    return this.repo.cambiarPrioridad(this.ctx(u), id, prioridad, motivo);
  }
  actualizar(u: JwtPayload, id: string, dto: ActualizarOtDto) {
    return this.repo.actualizar(this.ctx(u), id, dto);
  }
  verificarTrazabilidad(u: JwtPayload, limite?: number) {
    return this.repo.verificarTrazabilidad(this.ctx(u), limite);
  }
  buscarEnTrazabilidad(u: JwtPayload, criterio: Record<string, unknown>, limite?: number) {
    return this.repo.buscarEnTrazabilidad(this.ctx(u), criterio, limite);
  }
}
