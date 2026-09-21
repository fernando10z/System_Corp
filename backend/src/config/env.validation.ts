import { plainToInstance } from "class-transformer";
import {
  IsIn,
  IsNumberString,
  IsOptional,
  IsString,
  MinLength,
  validateSync,
} from "class-validator";

/**
 * Se ejecuta al arrancar. Si algo falta o es demasiado corto, el proceso NO
 * levanta y dice exactamente qué. Preferimos fallar en el arranque que descubrir
 * en producción que JWT_ACCESS_SECRET era la cadena vacía.
 */
class VariablesEntorno {
  @IsIn(["development", "test", "production"])
  NODE_ENV!: string;

  @IsNumberString()
  PORT!: string;

  @IsString()
  @MinLength(10, { message: "DATABASE_URL no parece una cadena de conexión válida" })
  DATABASE_URL!: string;

  @IsString()
  @MinLength(32, { message: "JWT_ACCESS_SECRET debe tener al menos 32 caracteres" })
  JWT_ACCESS_SECRET!: string;

  @IsString()
  @MinLength(32, { message: "JWT_REFRESH_SECRET debe tener al menos 32 caracteres" })
  JWT_REFRESH_SECRET!: string;

  @IsString()
  @MinLength(16, { message: "COOKIE_SECRET debe tener al menos 16 caracteres" })
  COOKIE_SECRET!: string;

  @IsOptional() @IsString() REDIS_URL?: string;
  @IsOptional() @IsString() STORAGE_ENDPOINT?: string;
  @IsOptional() @IsString() CORS_ORIGINS?: string;
  @IsOptional() @IsString() MAIL_HOST?: string;
}

export function validateEnv(raw: Record<string, unknown>) {
  const config = plainToInstance(VariablesEntorno, raw, { enableImplicitConversion: true });
  const errores = validateSync(config, { skipMissingProperties: false });

  if (errores.length) {
    const resumen = errores
      .map((e) => `${e.property}: ${Object.values(e.constraints ?? {}).join(", ")}`)
      .join("\n  ");
    throw new Error(`Variables de entorno inválidas:\n  ${resumen}\n\nRevise backend/.env.example`);
  }
  return raw;
}
