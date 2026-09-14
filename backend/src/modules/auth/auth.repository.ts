import { Injectable } from "@nestjs/common";
import { SpExecutorService } from "../../infrastructure/database/sp-executor.service";
import type { SpContext } from "../../common/types/sp-result.type";

@Injectable()
export class AuthRepository {
  constructor(private readonly sp: SpExecutorService) {}

  login(email: string, password: string) {
    // La contraseña se verifica DENTRO de la base con pgcrypto: en claro no sale
    // nunca de la transacción, y el backend jamás ve el hash.
    return this.sp.call<Record<string, unknown>>("app.sp_auth_login", [email, password]);
  }

  perfil(userId: string) {
    return this.sp.call<Record<string, unknown>>("app.fn_auth_perfil", [userId]);
  }

  cambiarPassword(ctx: SpContext, actual: string, nueva: string) {
    return this.sp.callCtx<{ cambiada: boolean }>("app.sp_auth_cambiar_password", ctx, [actual, nueva]);
  }
}
