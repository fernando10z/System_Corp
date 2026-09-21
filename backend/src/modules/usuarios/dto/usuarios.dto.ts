import { IsArray, IsEmail, IsIn, IsOptional, IsString, MinLength } from "class-validator";

export class CrearUsuarioDto {
  @IsEmail({}, { message: "Indique un correo válido" }) email!: string;
  @IsString() @MinLength(2) nombres!: string;
  @IsString() @MinLength(2) apellidos!: string;
  @IsString()
  @MinLength(10, { message: "La contraseña debe tener al menos 10 caracteres" })
  password!: string;
  @IsOptional() @IsArray() rolCodigos?: string[];
  @IsOptional() @IsString() cargo?: string;
  @IsOptional() @IsString() documento?: string;
  @IsOptional() @IsString() telefono?: string;
  /** [{sucursalId?, empresaRucId?, areaId?}] · null en un nivel = todo ese nivel. */
  @IsOptional() @IsArray() alcance?: Array<Record<string, string>>;
}

export class InactivarUsuarioDto {
  @IsString() @MinLength(5, { message: "Indique el motivo" }) motivo!: string;
}

export class ActualizarUsuarioDto {
  @IsOptional() @IsString() @MinLength(2) nombres?: string;
  @IsOptional() @IsString() @MinLength(2) apellidos?: string;
  @IsOptional() @IsString() cargo?: string;
  @IsOptional() @IsString() documento?: string;
  @IsOptional() @IsString() telefono?: string;
  @IsOptional() @IsArray() @IsString({ each: true }) rolCodigos?: string[];
  @IsOptional() @IsIn(["activo", "inactivo"]) estado?: string;
}

export class RestablecerPasswordDto {
  /** Igual que en el alta: sin mínimo no hay política que valga. */
  @IsString()
  @MinLength(10, { message: "La contraseña necesita al menos 10 caracteres" })
  passwordNueva!: string;
}
