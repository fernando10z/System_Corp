import { Body, Controller, Get, Post } from "@nestjs/common";
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

  @Public()
  @Post("login")
  async login(@Body() dto: LoginDto) {
    return { ok: true, data: await this.auth.login(dto.email, dto.password) };
  }

  @Public()
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

  @Post("cambiar-password")
  async cambiarPassword(@CurrentUser() u: JwtPayload, @Body() dto: CambiarPasswordDto) {
    return { ok: true, data: await this.auth.cambiarPassword(u, dto.passwordActual, dto.passwordNueva) };
  }
}
