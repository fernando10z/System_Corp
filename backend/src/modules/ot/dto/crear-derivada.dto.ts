import { IsBoolean, IsIn, IsOptional, IsString, IsUUID, MinLength } from "class-validator";

/**
 * Una derivada se crea cuando el trabajo deja de ser UNA intervención ejecutable
 * y necesita control independiente (cap. 27.1). El contexto organizacional es
 * opcional: si no se envía, se hereda del padre.
 */
export class CrearDerivadaDto {
  @IsString() @MinLength(10, { message: "Explique por qué se deriva, con al menos 10 caracteres" })
  motivoDerivacion!: string;

  @IsOptional() @IsUUID() motivoDerivacionId?: string;
  @IsOptional() @IsUUID() tipoMantenimientoId?: string;
  @IsOptional() @IsUUID() tipoTrabajoId?: string;
  @IsOptional() @IsIn(["critica", "alta", "media", "baja"]) prioridadTecnica?: string;
  @IsOptional() @IsUUID() coordinadorId?: string;
  @IsOptional() @IsUUID() sucursalId?: string;
  @IsOptional() @IsUUID() empresaRucId?: string;
  @IsOptional() @IsUUID() areaId?: string;

  /** Si es false, la derivada no impide cerrar al padre (cap. 10, 27.2). */
  @IsOptional() @IsBoolean() esBloqueante?: boolean;
}
