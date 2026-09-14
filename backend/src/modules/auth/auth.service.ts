import { Injectable, UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { randomUUID } from "node:crypto";
import { AuthRepository } from "./auth.repository";
import { RedisService } from "../../infrastructure/cache/redis.service";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";

export interface Perfil {
  id: string;
  email: string;
  tenant_id: string | null;
  is_super_admin: boolean;
  roles?: string[];
  permisos?: string[];
  [k: string]: unknown;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly repo: AuthRepository,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    private readonly redis: RedisService,
  ) {}

  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }

  async login(email: string, password: string) {
    const perfil = (await this.repo.login(email, password)) as unknown as Perfil;
    return { usuario: perfil, ...(await this.emitirTokens(perfil)) };
  }

  async refresh(refreshToken: string) {
    let payload: JwtPayload;
    try {
      payload = await this.jwt.verifyAsync<JwtPayload>(refreshToken, {
        secret: this.config.get<string>("JWT_REFRESH_SECRET"),
        issuer: this.config.get<string>("JWT_ISSUER"),
        audience: this.config.get<string>("JWT_AUDIENCE"),
      });
    } catch {
      throw new UnauthorizedException({ code: "UNAUTHORIZED", message: "Refresh token inválido o expirado" });
    }

    // La firma es válida, pero la sesión pudo revocarse (logout, cambio de
    // contraseña, baja del usuario). La whitelist es la que manda.
    if (payload.jti && !(await this.redis.refreshVigente(payload.jti))) {
      throw new UnauthorizedException({ code: "UNAUTHORIZED", message: "La sesión fue revocada" });
    }

    // Se relee el perfil en cada refresh: si al usuario le cambiaron los roles o
    // lo inactivaron, el token nuevo ya lo refleja.
    const perfil = (await this.repo.perfil(payload.sub)) as unknown as Perfil;
    if (payload.jti) await this.redis.revocarRefresh(payload.jti);
    return { usuario: perfil, ...(await this.emitirTokens(perfil)) };
  }

  async logout(u: JwtPayload) {
    const n = await this.redis.revocarTodosDe(u.sub);
    return { sesionesRevocadas: n };
  }

  perfil(u: JwtPayload) {
    return this.repo.perfil(u.sub);
  }

  cambiarPassword(u: JwtPayload, actual: string, nueva: string) {
    return this.repo.cambiarPassword(this.ctx(u), actual, nueva);
  }

  private async emitirTokens(perfil: Perfil) {
    const jti = randomUUID();
    const base: JwtPayload = {
      sub: perfil.id,
      email: perfil.email,
      tenant_id: perfil.tenant_id,
      is_super_admin: perfil.is_super_admin,
      roles: perfil.roles ?? [],
      permisos: perfil.permisos ?? [],
    };
    const comun = {
      issuer: this.config.get<string>("JWT_ISSUER"),
      audience: this.config.get<string>("JWT_AUDIENCE"),
    };

    const accessToken = await this.jwt.signAsync(base, {
      ...comun,
      secret: this.config.get<string>("JWT_ACCESS_SECRET"),
      expiresIn: this.config.get<string>("JWT_ACCESS_TTL") ?? "15m",
    });
    const refreshToken = await this.jwt.signAsync(
      { sub: base.sub, email: base.email, tenant_id: base.tenant_id, is_super_admin: base.is_super_admin, jti },
      {
        ...comun,
        secret: this.config.get<string>("JWT_REFRESH_SECRET"),
        expiresIn: this.config.get<string>("JWT_REFRESH_TTL") ?? "7d",
      },
    );

    await this.redis.guardarRefresh(jti, perfil.id, this.segundosDeTtl(this.config.get<string>("JWT_REFRESH_TTL") ?? "7d"));
    return { accessToken, refreshToken };
  }

  /** Convierte "15m" / "7d" / "3600" a segundos. */
  private segundosDeTtl(ttl: string): number {
    const m = ttl.match(/^(\d+)([smhd])?$/);
    if (!m) return 604800;
    const n = Number(m[1]);
    return n * ({ s: 1, m: 60, h: 3600, d: 86400 }[m[2] ?? "s"] ?? 1);
  }
}
