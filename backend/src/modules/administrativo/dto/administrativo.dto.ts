import {
  IsDateString,
  IsIn,
  IsNumber,
  IsObject,
  IsOptional,
  IsString,
  IsUUID,
  Min,
  MinLength,
} from "class-validator";

/**
 * El formulario de SOLPED es un objeto libre A PROPÓSITO.
 *
 * El cap. 22.4 deja pendientes los campos exactos, las imputaciones, los grupos
 * de compra y los desarrollos Z de cada cliente. Modelarlos aquí en columnas
 * fijas sería inventar una decisión que el documento prohíbe expresamente
 * resolver desde desarrollo (cap. 38).
 */
export class PrepararSolpedDto {
  @IsOptional() @IsObject() formulario?: Record<string, unknown>;
  @IsOptional() @IsUUID() cotizacionId?: string;
  @IsOptional() @IsString() numeroInterno?: string;
}

export class NumeroSapDto {
  @IsString() @MinLength(1, { message: "Indique el número SAP" }) numeroSap!: string;
  @IsOptional() @IsString() observacion?: string;
}

export class AnularSolpedDto {
  @IsString() @MinLength(5, { message: "Anular la SOLPED exige motivo" }) motivo!: string;
}

export class RegistrarOcDto {
  @IsString() @MinLength(1, { message: "Indique el número de OC" }) numeroOc!: string;
  @IsOptional() @IsDateString() fechaOc?: string;
  @IsOptional() @IsNumber() @Min(0) monto?: number;
  @IsOptional() @IsIn(["PEN", "USD", "EUR"]) moneda?: string;
  @IsOptional() @IsString() observacion?: string;
  @IsOptional() @IsUUID() solpedId?: string;
}

export class RegistrarLiberacionDto {
  @IsIn(["pendiente", "parcial", "total"]) estado!: string;
  @IsNumber() @Min(0, { message: "El monto liberado no puede ser negativo" }) monto!: number;
  @IsOptional() @IsString() observacion?: string;
  @IsOptional() @IsUUID() ordenCompraId?: string;
}
