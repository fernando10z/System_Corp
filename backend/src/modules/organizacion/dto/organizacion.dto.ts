import { IsArray, IsOptional, IsString, IsUUID, Length, MinLength } from "class-validator";

export class CrearSucursalDto {
  @IsString() @Length(2, 30) codigo!: string;
  @IsString() @MinLength(2) nombre!: string;
  @IsOptional() @IsString() direccion?: string;
}

export class CrearEmpresaRucDto {
  /** La validación real del dígito verificador la hace internal.validar_ruc. */
  @IsString() @Length(11, 11, { message: "El RUC debe tener 11 dígitos" }) ruc!: string;
  @IsString() @MinLength(3) razonSocial!: string;
  @IsOptional() @IsString() nombreCorto?: string;
  @IsOptional() @IsArray() sucursalIds?: string[];
}

export class CrearAreaDto {
  @IsUUID() empresaRucId!: string;
  @IsString() @Length(2, 30) codigo!: string;
  @IsString() @MinLength(2) nombre!: string;
}

export class InactivarDto {
  @IsString() @MinLength(5, { message: "Indique el motivo" }) motivo!: string;
}
