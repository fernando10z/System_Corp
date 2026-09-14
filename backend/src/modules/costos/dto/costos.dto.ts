import { IsBoolean, IsIn, IsNumber, IsOptional, IsString, IsUUID, Min, MinLength } from "class-validator";

export class RegistrarCostoDto {
  /** Inmutable y obligatorio: no hay registros sin procedencia (cap. 32.2). */
  @IsString() @MinLength(3, { message: "El texto original del documento es obligatorio" })
  textoOriginal!: string;

  @IsNumber() @Min(0) montoTotal!: number;

  @IsOptional() @IsIn(["cotizacion", "ot_cerrada", "documento_administrativo", "carga_validada"])
  fuente?: string;

  @IsOptional() @IsIn(["material", "repuesto", "servicio", "trabajo_integral"]) concepto?: string;

  /** Sin cantidad positiva no se calcula costo unitario: se conserva el total. */
  @IsOptional() @IsNumber() @Min(0) cantidad?: number;
  @IsOptional() @IsString() unidad?: string;
  @IsOptional() @IsIn(["PEN", "USD", "EUR"]) moneda?: string;
  @IsOptional() @IsUUID() cotizacionId?: string;
  @IsOptional() @IsUUID() descripcionNormalizadaId?: string;
}

export class CalificarCostoDto {
  @IsBoolean() esComparable!: boolean;
  @IsOptional() @IsBoolean() esOutlier?: boolean;
  /** Obligatoria si esOutlier: un atípico se marca, nunca se borra (cap. 16.3). */
  @IsOptional() @IsString() justificacion?: string;
}
