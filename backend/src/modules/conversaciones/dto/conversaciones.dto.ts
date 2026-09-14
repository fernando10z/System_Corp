import { IsArray, IsBoolean, IsIn, IsOptional, IsString, IsUUID, MinLength } from "class-validator";

export class PublicarMensajeDto {
  @IsString() @MinLength(1, { message: "El mensaje no puede estar vacío" }) cuerpo!: string;
  /** 'interna' oculta el mensaje al solicitante (cap. 13, QA-18). */
  @IsOptional() @IsIn(["canal", "interna"]) visibilidad?: string;
  @IsOptional() @IsUUID() respondeA?: string;
  @IsOptional() @IsArray() menciones?: string[];
}

export class EditarMensajeDto {
  @IsString() @MinLength(1) cuerpo!: string;
}

export class InvitarParticipanteDto {
  @IsUUID() usuarioId!: string;
  @IsOptional() @IsBoolean() puedeEscribir?: boolean;
  @IsOptional() @IsBoolean() veNotasInternas?: boolean;
}
