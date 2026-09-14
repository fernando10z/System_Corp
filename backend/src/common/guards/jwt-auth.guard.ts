import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { Reflector } from "@nestjs/core";
import { IS_PUBLIC_KEY } from "../decorators/public.decorator";
import type { AuthenticatedRequest } from "../types/authenticated-request.type";
import type { JwtPayload } from "../types/jwt-payload.type";

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    private readonly reflector: Reflector,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const esPublica = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (esPublica) return true;

    const req = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const header = req.headers.authorization;
    if (!header?.startsWith("Bearer ")) {
      throw new UnauthorizedException({ code: "UNAUTHORIZED", message: "Falta el token de acceso" });
    }

    try {
      req.user = await this.jwt.verifyAsync<JwtPayload>(header.slice(7), {
        secret: this.config.get<string>("JWT_ACCESS_SECRET"),
        issuer: this.config.get<string>("JWT_ISSUER"),
        audience: this.config.get<string>("JWT_AUDIENCE"),
      });
      return true;
    } catch {
      throw new UnauthorizedException({ code: "UNAUTHORIZED", message: "Token inválido o expirado" });
    }
  }
}
