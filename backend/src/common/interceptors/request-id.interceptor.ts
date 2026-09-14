import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from "@nestjs/common";
import { randomUUID } from "node:crypto";
import type { Observable } from "rxjs";
import type { FastifyReply } from "fastify";
import type { AuthenticatedRequest } from "../types/authenticated-request.type";

/**
 * Un identificador por petición que viaja al log y a audit_log.request_id, para
 * poder reconstruir qué llamada HTTP produjo qué cambio en la base.
 */
@Injectable()
export class RequestIdInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const req = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const res = context.switchToHttp().getResponse<FastifyReply>();
    const id = (req.headers["x-request-id"] as string) || randomUUID();
    (req as unknown as { id: string }).id = id;
    res.header("x-request-id", id);
    return next.handle();
  }
}
