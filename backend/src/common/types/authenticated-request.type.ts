import type { FastifyRequest } from "fastify";
import type { JwtPayload } from "./jwt-payload.type";

export interface AuthenticatedRequest extends FastifyRequest {
  user?: JwtPayload;
}
