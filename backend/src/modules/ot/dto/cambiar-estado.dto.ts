import { IsIn, IsOptional, IsString, IsUUID } from "class-validator";

export class CambiarEstadoDto {
  @IsIn([
    "creada",
    "en_diagnostico",
    "en_cotizacion",
    "en_trabajo",
    "trabajo_realizado",
    "cerrada",
    "cancelada",
  ])
  estado!: string;

  @IsOptional() @IsString() motivo?: string;
  @IsOptional() @IsUUID() motivoId?: string;
}
