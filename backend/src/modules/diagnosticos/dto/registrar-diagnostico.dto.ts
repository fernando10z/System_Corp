import { IsOptional, IsString, MinLength } from "class-validator";

/**
 * Los CUATRO campos técnicos son obligatorios y sin ellos la OT no puede pasar a
 * cotización (cap. 9, QA-07). El motivo del cambio es obligatorio a partir de la
 * segunda versión, y eso lo hace cumplir el SP: sólo él sabe si ya hay una
 * versión vigente.
 */
export class RegistrarDiagnosticoDto {
  @IsString()
  @MinLength(10, { message: "El diagnóstico debe tener al menos 10 caracteres" })
  diagnostico!: string;

  @IsString()
  @MinLength(5, { message: "Indique la causa probable" })
  causaProbable!: string;

  @IsString()
  @MinLength(5, { message: "Delimite el alcance de la intervención" })
  alcance!: string;

  @IsString()
  @MinLength(5, { message: "Describa el trabajo a realizar (el plan, no lo ya ejecutado)" })
  trabajoARealizar!: string;

  @IsOptional() @IsString() observaciones?: string;

  /** Sólo texto: el MVP no modela unidades ni series medibles (cap. 9, 26.2). */
  @IsOptional() @IsString() lecturasInstrumentos?: string;

  @IsOptional() @IsString() motivoCambio?: string;
}
