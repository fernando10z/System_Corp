import { IsArray, IsEmail, IsOptional, IsString, MinLength } from "class-validator";

export class CrearUsuarioDto {
  @IsEmail({}, { message: "Indique un correo válido" }) email!: string;
  @IsString() @MinLength(2) nombres!: string;
  @IsString() @MinLength(2) apellidos!: string;
  @IsString() @MinLength(10, { message: "La contraseña debe tener al menos 10 caracteres" }) password!: string;
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
