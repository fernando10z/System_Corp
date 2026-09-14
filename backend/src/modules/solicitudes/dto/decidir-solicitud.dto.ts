import { IsIn, IsOptional, IsString, IsUUID } from "class-validator";

export class DecidirSolicitudDto {
  /** Aceptar NO va aquí: crea una OT y tiene su propio endpoint. */
  @IsIn(["observar", "rechazar", "derivar", "marcar_duplicada"])
  tipo!: string;

  @IsOptional() @IsString() comentario?: string;
  @IsOptional() @IsUUID() motivoId?: string;
  @IsOptional() @IsUUID() destinatarioId?: string;
  @IsOptional() @IsUUID() solicitudPrincipalId?: string;
}
