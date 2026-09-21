import {
  IsDateString,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
  MinLength,
} from "class-validator";

export class IniciarEjecucionDto {
  @IsUUID() responsableId!: string;
  @IsOptional() @IsDateString() inicioReal?: string;
  @IsOptional() @IsString() observaciones?: string;
}

/** El porcentaje NO es obligatorio: un avance es narrativo (cap. 29.2). */
export class RegistrarAvanceDto {
  @IsString() @MinLength(5, { message: "Describa el avance" }) descripcion!: string;
  @IsOptional() @IsNumber() @Min(0) @Max(100) porcentaje?: number;
}

export class RegistrarIncidenciaDto {
  @IsString() @MinLength(5, { message: "Describa la incidencia" }) descripcion!: string;
  @IsOptional() @IsUUID() tipoId?: string;
}

export class PausarDto {
  @IsString() @MinLength(5, { message: "La pausa exige motivo" }) motivoTexto!: string;
  @IsOptional() @IsUUID() motivoId?: string;
}

export class ReanudarDto {
  @IsOptional() @IsString() observacion?: string;
}

export class DeclararTrabajoDto {
  @IsString() @MinLength(10, { message: "Describa el trabajo realizado" }) descripcion!: string;
  @IsOptional() @IsDateString() fechaTermino?: string;
  @IsOptional() @IsUUID() resultadoId?: string;
  @IsOptional() @IsString() resultadoTexto?: string;
  @IsOptional() @IsString() observaciones?: string;
}
