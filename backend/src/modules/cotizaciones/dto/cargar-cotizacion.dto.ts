import {
  IsDateString,
  IsIn,
  IsInt,
  IsNumber,
  Max,
  IsOptional,
  IsString,
  IsUUID,
  Min,
} from "class-validator";

/**
 * MIP recibe la cotización FINAL YA SELECCIONADA (cap. 11): no compara
 * proveedores ni calcula puntajes. Si hay proveedores o alcances independientes,
 * eso son OT derivadas, no varias cotizaciones vigentes.
 */
export class CargarCotizacionDto {
  @IsOptional() @IsUUID() proveedorId?: string;
  @IsOptional() @IsString() proveedorNombre?: string;
  @IsOptional() @IsString() proveedorRuc?: string;
  @IsOptional() @IsString() numeroCotizacion?: string;
  /** Fecha del documento del proveedor, no la de carga. */
  @IsOptional() @IsDateString() fecha?: string;
  @IsOptional() @IsNumber() @Min(0) monto?: number;
  @IsOptional() @IsIn(["PEN", "USD", "EUR"]) moneda?: string;

  /** El plazo pertenece a la cotización, no a la OT (cap. 12.1). */
  @IsOptional() @IsInt() @Min(0) plazoOfrecidoDias?: number;

  /** Días que la oferta se mantiene en pie. Sirve para avisar si venció. */
  @IsOptional() @IsInt() @Min(0) @Max(365) validezDias?: number;

  @IsOptional() @IsString() observaciones?: string;

  /** Obligatorio al reemplazar una cotización vigente (cap. 28.2). */
  @IsOptional() @IsString() motivoReemplazo?: string;
}
