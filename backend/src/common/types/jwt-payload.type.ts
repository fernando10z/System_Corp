export interface JwtPayload {
  /** id del usuario */
  sub: string;
  email: string;
  tenant_id: string | null;
  is_super_admin: boolean;
  roles?: string[];
  permisos?: string[];
  /** identificador del token, usado para la whitelist de refresh en Redis */
  jti?: string;
  iat?: number;
  exp?: number;
  iss?: string;
  aud?: string;
}
