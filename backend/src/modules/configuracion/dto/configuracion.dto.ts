import { IsDefined, IsOptional, IsString } from "class-validator";

export class GuardarConfiguracionDto {
  /** Debe estar en la lista blanca de internal.claves_configurables(). */
  @IsString() clave!: string;
  /** Cualquier JSON: la forma depende de la clave. */
  @IsDefined() valor!: unknown;
  @IsOptional() @IsString() descripcion?: string;
}
