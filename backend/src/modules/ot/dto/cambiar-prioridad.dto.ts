import { IsIn, IsOptional, IsString } from "class-validator";

export class CambiarPrioridadDto {
  @IsIn(["critica", "alta", "media", "baja"]) prioridad!: string;
  /** Obligatorio al bajar una prioridad crítica/alta o al cambiarla en ejecución. */
  @IsOptional() @IsString() motivo?: string;
}
