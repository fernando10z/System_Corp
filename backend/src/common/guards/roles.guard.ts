import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { ROLES_KEY } from "../decorators/roles.decorator";
import type { AuthenticatedRequest } from "../types/authenticated-request.type";

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requeridos = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requeridos?.length) return true;

    const user = context.switchToHttp().getRequest<AuthenticatedRequest>().user;
    if (!user) throw new ForbiddenException({ code: "FORBIDDEN", message: "Sin sesión" });
    if (user.is_super_admin) return true;

    const tiene = (user.roles ?? []).some((r) => requeridos.includes(r));
    if (!tiene) {
      throw new ForbiddenException({
        code: "FORBIDDEN",
        message: `Requiere uno de estos roles: ${requeridos.join(", ")}`,
      });
    }
    return true;
  }
}
