import { Body, Controller, Get, Post } from "@nestjs/common";
import { Throttle } from "@nestjs/throttler";
import { AuthService } from "./auth.service";
import { Public } from "../../common/decorators/public.decorator";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { LoginDto } from "./dto/login.dto";
import { RefreshDto } from "./dto/refresh.dto";
import { CambiarPasswordDto } from "./dto/cambiar-password.dto";
import type { JwtPayload } from "../../common/types/jwt-payload.type";

@Controller("auth")
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  /**
   * Dos capas, y cada una hace un trabajo distinto:
   *
   *  · El BLOQUEO POR CUENTA (app.sp_auth_login) es el control preciso: cinco
   *    fallos consecutivos y esa cuenta queda cerrada 15 minutos, venga el
   *    intento de donde venga. Es lo que detiene de verdad un ataque dirigido.
   *
   *  · Este límite por IP es sólo un tope grueso contra el barrido automatizado
   *    de correos. No puede ser estrecho: un cliente corporativo sale entero
   *    por una o dos IP públicas, así que un límite de ocho por minuto dejaría
   *    fuera a la oficina a las nueve de la mañana. Treinta por minuto corta un
   *    script y no estorba a un turno entrante — y aunque el atacante los
   *    gaste, el bloqueo por cuenta ya le ha dado sólo cinco por usuario.
   */
  @Public()
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @Post("login")
  async login(@Body() dto: LoginDto) {
    return { ok: true, data: await this.auth.login(dto.email, dto.password) };
  }

  @Public()
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @Post("refresh")
  async refresh(@Body() dto: RefreshDto) {
    return { ok: true, data: await this.auth.refresh(dto.refreshToken) };
  }

  @Post("logout")
  async logout(@CurrentUser() u: JwtPayload) {
    return { ok: true, data: await this.auth.logout(u) };
  }

  @Get("perfil")
  async perfil(@CurrentUser() u: JwtPayload) {
    return { ok: true, data: await this.auth.perfil(u) };
  }

  @Throttle({ default: { limit: 8, ttl: 60_000 } })
  @Post("cambiar-password")
  async cambiarPassword(@CurrentUser() u: JwtPayload, @Body() dto: CambiarPasswordDto) {
    return {
      ok: true,
      data: await this.auth.cambiarPassword(u, dto.passwordActual, dto.passwordNueva),
    };
  }
}
