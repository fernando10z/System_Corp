import {
  IsBoolean,
  IsEmail,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Length,
  MinLength,
} from "class-validator";

export class CrearItemCatalogoDto {
  @IsString() tipo!: string;
  @IsString() @Length(2, 60) codigo!: string;
  @IsString() @MinLength(2) nombre!: string;
  @IsOptional() @IsString() descripcion?: string;
  @IsOptional() @IsInt() orden?: number;
  /** true para ítems tipo 'Otro', que exigen texto libre (cap. 24.3). */
  @IsOptional() @IsBoolean() requiereComentario?: boolean;
}

export class CrearTipoTrabajoDto {
  @IsString() @Length(2, 60) codigo!: string;
  @IsString() @MinLength(2) nombre!: string;
  @IsOptional() @IsUUID() padreId?: string;
  @IsOptional() @IsString() descripcion?: string;
}

export class CrearProveedorDto {
  @IsString() @MinLength(3) razonSocial!: string;
  @IsOptional() @IsString() @Length(11, 11) ruc?: string;
  @IsOptional() @IsString() contacto?: string;
  @IsOptional() @IsString() telefono?: string;
  @IsOptional() @IsEmail() email?: string;
}
