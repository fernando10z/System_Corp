import { IsString, MinLength } from "class-validator";
export class CambiarPasswordDto {
  @IsString() passwordActual!: string;
  @IsString() @MinLength(10, { message: "La nueva contraseña debe tener al menos 10 caracteres" })
  passwordNueva!: string;
}
