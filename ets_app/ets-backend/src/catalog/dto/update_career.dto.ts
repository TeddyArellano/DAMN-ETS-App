import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  ArrayNotEmpty,
  ArrayUnique,
  IsArray,
  IsOptional,
  IsString,
  Matches,
  MinLength,
} from 'class-validator';

/// Actualización parcial de una carrera. Todos los campos son opcionales;
/// se actualizan solo los enviados.
export class UpdateCareerDto {
  @ApiPropertyOptional({ example: 'ISC' })
  @IsOptional()
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim().toUpperCase() : value,
  )
  @IsString()
  @Matches(/^[A-Z0-9]{2,10}$/, {
    message: 'El código debe contener entre 2 y 10 letras o números',
  })
  code?: string;

  @ApiPropertyOptional({ example: 'Ingeniería en Sistemas Computacionales' })
  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  @MinLength(3, { message: 'El nombre debe contener al menos 3 caracteres' })
  name?: string;

  @ApiPropertyOptional({ example: ['2009', '2020'], type: [String] })
  @IsOptional()
  @Transform(({ value }) => {
    if (!Array.isArray(value)) {
      return value;
    }
    return value
      .map((item) => String(item).trim())
      .filter((item) => item.length > 0);
  })
  @IsArray()
  @ArrayNotEmpty({ message: 'Debe ingresar al menos un plan de estudios' })
  @ArrayUnique({ message: 'Los planes no deben repetirse' })
  @IsString({ each: true })
  plans?: string[];
}
