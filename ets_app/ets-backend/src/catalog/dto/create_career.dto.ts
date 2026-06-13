import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  ArrayNotEmpty,
  ArrayUnique,
  IsArray,
  IsString,
  Matches,
  MinLength,
} from 'class-validator';

export class CreateCareerDto {
  @ApiProperty({
    example: 'ISC',
    description: 'Código corto de la carrera',
  })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim().toUpperCase() : value,
  )
  @IsString()
  @Matches(/^[A-Z0-9]{2,10}$/, {
    message: 'El código debe contener entre 2 y 10 letras o números',
  })
  code: string;

  @ApiProperty({
    example: 'Ingeniería en Sistemas Computacionales',
    description: 'Nombre completo de la carrera',
  })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim() : value,
  )
  @IsString()
  @MinLength(3, {
    message: 'El nombre debe contener al menos 3 caracteres',
  })
  name: string;

  @ApiProperty({
    example: ['2009', '2020'],
    description: 'Planes de estudio disponibles',
    type: [String],
  })
  @Transform(({ value }) => {
    if (!Array.isArray(value)) {
      return value;
    }

    return value
      .map((item) => String(item).trim())
      .filter((item) => item.length > 0);
  })
  @IsArray()
  @ArrayNotEmpty({
    message: 'Debe ingresar al menos un plan de estudios',
  })
  @ArrayUnique({
    message: 'Los planes no deben repetirse',
  })
  @IsString({ each: true })
  plans: string[];
}