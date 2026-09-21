import { IsIn, IsOptional, IsString, IsUUID, MinLength } from "class-validator";

export class CancelarOtDto {
  @IsOptional() @IsUUID() motivoId?: string;

  @IsString()
  @MinLength(10, { message: "La cancelación exige una observación de al menos 10 caracteres" })
  observacion!: string;

  /**
   * Qué hacer con las derivadas activas (cap. 25.3):
   *   bloquear     · no cancelar; devolver la lista para que el usuario decida
   *   cancelar     · cancelarlas en cascada, cada una con su motivo
   *   independizar · mantenerlas vivas, dejando constancia en la auditoría
   */
  @IsOptional()
  @IsIn(["bloquear", "cancelar", "independizar"])
  tratamientoDerivadas?: string;
}
