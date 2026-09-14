import { Injectable, Logger } from "@nestjs/common";
import { NotificacionesRepository } from "./notificaciones.repository";
import { MailService } from "../../infrastructure/mail/mail.service";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class NotificacionesService {
  private readonly logger = new Logger(NotificacionesService.name);

  constructor(
    private readonly repo: NotificacionesRepository,
    private readonly mail: MailService,
  ) {}

  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }

  listar(u: JwtPayload, soloNoLeidas: boolean, limite: number) {
    return this.repo.listar(this.ctx(u), soloNoLeidas, limite);
  }
  marcarLeida(u: JwtPayload, id?: string) { return this.repo.marcarLeida(this.ctx(u), id); }
  sla(u: JwtPayload) { return this.repo.sla(this.ctx(u)); }

  /**
   * Vacía la cola de correo pendiente.
   *
   * Un fallo de entrega NO revierte nada (cap. 34.1): se marca la notificación
   * como fallida con su mensaje de error, para que soporte pueda investigar, y
   * se continúa con la siguiente.
   */
  async despacharCorreos(u: JwtPayload, limite = 50) {
    const ctx = this.ctx(u);
    const pendientes = await this.repo.pendientesCorreo(ctx, limite);
    let enviados = 0;
    let fallidos = 0;

    for (const n of pendientes) {
      const r = await this.mail.enviar(
        String(n.email),
        String(n.titulo),
        [n.cuerpo, n.ot_numero ? `\nOT: ${n.ot_numero}` : ""].filter(Boolean).join("\n"),
      );
      await this.repo.marcarEnviada(ctx, String(n.id), r.ok, r.error);
      r.ok ? enviados++ : fallidos++;
    }

    if (fallidos) this.logger.warn(`${fallidos} correo(s) no pudieron entregarse; quedan registrados.`);
    return { pendientes: pendientes.length, enviados, fallidos };
  }
}
