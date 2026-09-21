import {
  IsBoolean,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from "class-validator";

/**
 * Lo que se le pide al solicitante y NADA MÁS.
 *
 * El cap. 3 lo declara principio fundacional: "el solicitante informa título,
 * descripción, lugar, impacto, prioridad percibida y evidencias; no se le exige
 * activo, CECOS ni diagnóstico". Añadir aquí un campo técnico rompe el producto,
 * no sólo este DTO.
 */
export class CrearSolicitudDto {
  @IsString()
  @MinLength(5, { message: "El título debe tener al menos 5 caracteres" })
  @MaxLength(180, { message: "El título no puede superar los 180 caracteres" })
  titulo!: string;

  @IsString()
  @MinLength(10, { message: "Describa la necesidad con al menos 10 caracteres" })
  descripcion!: string;

  /** Referencia libre: el solicitante puede no conocer la ubicación técnica. */
  @IsString() @MinLength(3) lugar!: string;

  @IsUUID() areaId!: string;

  @IsOptional() @IsUUID() impactoOperativoId?: string;
  @IsOptional() @IsString() impactoComentario?: string;

  /** Informativa. Sólo el coordinador fija la prioridad técnica (cap. 8.4). */
  @IsOptional() @IsIn(["critica", "alta", "media", "baja"]) prioridadPercibida?: string;

  /** false deja la solicitud en borrador: no notifica ni crea OT (cap. 24.2). */
  @IsOptional() @IsBoolean() enviar?: boolean;
}
