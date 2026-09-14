import { IsOptional, IsUUID } from "class-validator";

export class ActualizarOtDto {
  @IsOptional() @IsUUID() sucursalId?: string;
  @IsOptional() @IsUUID() empresaRucId?: string;
  @IsOptional() @IsUUID() areaId?: string;
  @IsOptional() @IsUUID() cecosId?: string;
  @IsOptional() @IsUUID() tipoMantenimientoId?: string;
  @IsOptional() @IsUUID() tipoTrabajoId?: string;
  @IsOptional() @IsUUID() coordinadorId?: string;
  @IsOptional() @IsUUID() ejecutorId?: string;
}
