import { Injectable, Logger } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { createTransport, type Transporter } from "nodemailer";

/**
 * El correo es una COPIA de la notificación interna, nunca la fuente de verdad
 * (cap. 34.1). Un fallo de entrega NO revierte la operación de negocio: se
 * registra en core.notificacion.error_envio para soporte y se sigue adelante.
 *
 * Si MAIL_ENABLED es false el servicio arranca inerte y sólo escribe en el log.
 * Eso permite desarrollar sin un servidor SMTP y sin fingir que se envió algo.
 */
@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private readonly transporter: Transporter | null;
  private readonly from: string;
  readonly habilitado: boolean;

  constructor(config: ConfigService) {
    this.habilitado = config.get("MAIL_ENABLED") === "true" && !!config.get("MAIL_HOST");
    this.from = config.get<string>("MAIL_FROM") ?? "MIP <no-reply@mip.local>";

    this.transporter = this.habilitado
      ? createTransport({
          host: config.get<string>("MAIL_HOST"),
          port: Number(config.get("MAIL_PORT") ?? 587),
          secure: config.get("MAIL_SECURE") === "true",
          auth: config.get("MAIL_USER")
            ? { user: config.get<string>("MAIL_USER"), pass: config.get<string>("MAIL_PASSWORD") }
            : undefined,
        })
      : null;

    if (!this.habilitado) {
      this.logger.warn(
        "Correo deshabilitado: las notificaciones sólo se verán dentro de la plataforma.",
      );
    }
  }

  /** Devuelve el error como texto en vez de lanzar: quien llama decide qué hacer. */
  async enviar(
    para: string,
    asunto: string,
    texto: string,
    html?: string,
  ): Promise<{ ok: boolean; error?: string }> {
    if (!this.transporter) {
      this.logger.debug(`[correo inerte] ${para} · ${asunto}`);
      return { ok: true };
    }
    try {
      await this.transporter.sendMail({
        from: this.from,
        to: para,
        subject: asunto,
        text: texto,
        html,
      });
      return { ok: true };
    } catch (e) {
      const msg = (e as Error).message;
      this.logger.warn(`Fallo al enviar a ${para}: ${msg}`);
      return { ok: false, error: msg };
    }
  }
}
