import { IsBoolean, IsIn, IsOptional, IsString, IsUUID, MinLength } from "class-validator";

export class RevisarTrabajoDto {
  @IsIn(["aprobado", "correccion_solicitada", "derivada_creada"]) resultado!: string;
  /** Obligatorio al solicitar correcciones (cap. 14.2, QA-14). */
  @IsOptional() @IsString() observacion?: string;
}

export class ConformidadDto {
  @IsIn(["conforme", "no_conforme", "sin_pronunciarse"]) conformidad!: string;
  @IsOptional() @IsString() comentario?: string;
}

/**
 * Cerrar con pendiente administrativo exige DOS cosas (cap. 31.2, QA-19):
 * la confirmación explícita de que se revisó el seguimiento, y una observación
 * escrita que explique el pendiente. Sin ambas, el SP rechaza el cierre.
 */
export class CerrarOtDto {
  @IsOptional() @IsBoolean() adminRevisado?: boolean;
  @IsOptional() @IsString() observacionPendiente?: string;
}

export class ReabrirOtDto {
  @IsString()
  @MinLength(10, { message: "La reapertura exige un motivo de al menos 10 caracteres" })
  motivoTexto!: string;

  @IsOptional() @IsIn(["en_trabajo", "en_diagnostico"]) estadoRetorno?: string;
  @IsOptional() @IsUUID() motivoId?: string;
}
