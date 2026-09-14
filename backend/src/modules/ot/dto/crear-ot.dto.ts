import { IsBoolean, IsIn, IsOptional, IsString, IsUUID, MinLength } from "class-validator";

/** Datos mínimos de la OT al aceptar una solicitud (cap. 24.4). */
export class CrearOtDto {
  @IsUUID() solicitudId!: string;
  @IsUUID() sucursalId!: string;
  @IsUUID() empresaRucId!: string;
  @IsUUID() areaId!: string;
  @IsUUID() tipoMantenimientoId!: string;
  @IsUUID() coordinadorId!: string;

  @IsIn(["critica", "alta", "media", "baja"], { message: "Prioridad técnica no válida" })
  prioridadTecnica!: string;

  @IsOptional() @IsBoolean() esEmergencia?: boolean;

  // La justificación es obligatoria cuando esEmergencia es true. No se declara
  // con @ValidateIf porque la regla ya la hace cumplir el SP y un CHECK de la
  // tabla: mejor una sola fuente de verdad que dos que puedan divergir.
  @IsOptional() @IsString() @MinLength(10, { message: "Justifique la emergencia con al menos 10 caracteres" })
  emergenciaJustificacion?: string;

  @IsOptional() @IsUUID() tipoTrabajoId?: string;
  @IsOptional() @IsUUID() cecosId?: string;
}
