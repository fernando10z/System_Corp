import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from "@nestjs/common";
import type { FastifyReply } from "fastify";

/**
 * Todo lo que sale del backend con error tiene la MISMA forma que lo que
 * devuelve la base: { ok:false, error:{ code, message, field? } }. El frontend
 * no necesita saber si el error nació en un SP, en un guard o en una excepción
 * inesperada.
 */
const CODIGO_POR_ESTADO: Record<number, string> = {
  400: "VALIDATION",
  401: "UNAUTHORIZED",
  403: "FORBIDDEN",
  404: "NOT_FOUND",
  409: "CONFLICT",
  422: "BUSINESS_RULE",
  429: "TOO_MANY_REQUESTS",
};

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const res = host.switchToHttp().getResponse<FastifyReply>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let code = "INTERNAL_ERROR";
    let message = "Error interno del servidor";
    let field: string | undefined;
    let detail: unknown;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const cuerpo = exception.getResponse();
      code = CODIGO_POR_ESTADO[status] ?? "INTERNAL_ERROR";
      if (typeof cuerpo === "string") {
        message = cuerpo;
      } else if (cuerpo && typeof cuerpo === "object") {
        const c = cuerpo as Record<string, unknown>;
        code = (c.code as string) ?? code;
        message = (c.message as string) ?? exception.message;
        field = c.field as string | undefined;
        detail = c.detail;
      }
    } else if (exception instanceof Error) {
      // Un error no controlado no debe filtrar su mensaje al cliente, pero sí
      // debe quedar íntegro en el log.
      this.logger.error(exception.message, exception.stack);
    }

    res.status(status).send({ ok: false, error: { code, message, field, detail } });
  }
}
