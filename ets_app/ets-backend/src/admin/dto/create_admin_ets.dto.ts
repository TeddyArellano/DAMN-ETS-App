import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  IsDateString,
  IsEmail,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
  MinLength,
} from 'class-validator';

export class CreateAdminEtsDto {
  @ApiPropertyOptional({
    example: 'Algoritmos y Estructuras de Datos',
    description: 'Unidad de aprendizaje o materia del ETS. Se mantiene por compatibilidad.',
  })
  @IsOptional()
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim() : value,
  )
  @IsString()
  @MinLength(2, {
    message: 'La unidad de aprendizaje debe contener al menos 2 caracteres',
  })
  ua?: string;

  @ApiProperty({
    example: 1,
    description: 'Identificador de la carrera',
  })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  careerId: number;

  @ApiProperty({
    example: 1,
    description: 'Identificador de la materia seleccionada',
  })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  subjectId: number;

  @ApiProperty({
    example: '2020',
    description: 'Plan de estudios',
  })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim() : value,
  )
  @IsString()
  @MinLength(2, {
    message: 'El plan debe contener al menos 2 caracteres',
  })
  plan: string;

  @ApiProperty({
    example: 3,
    description: 'Semestre de la unidad de aprendizaje',
  })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(12)
  semestre: number;

  @ApiProperty({
    example: '2026-06-15T09:00:00.000Z',
    description: 'Fecha y hora del examen en formato ISO',
  })
  @IsDateString(
    {},
    {
      message: 'La fecha debe estar en formato ISO válido',
    },
  )
  fechaIso: string;

  @ApiProperty({
    example: 'Matutino',
    description: 'Turno del examen',
  })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim() : value,
  )
  @IsString()
  @MinLength(2)
  turno: string;

  @ApiProperty({
    example: 'A-1103',
    description: 'Salón asignado para el examen',
  })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim() : value,
  )
  @IsString()
  @MinLength(2)
  salon: string;

  @ApiProperty({
    example: 'Dra. Ana López',
    description: 'Profesor evaluador',
  })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim() : value,
  )
  @IsString()
  @MinLength(3)
  profesor: string;

  @ApiProperty({
    example: 'ana.lopez@escom.ipn.mx',
    description: 'Correo de contacto del profesor evaluador',
  })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  @IsEmail(
    {},
    {
      message: 'El correo del profesor no es válido',
    },
  )
  correo: string;

  @ApiPropertyOptional({
    example: 1,
    description: 'Identificador del edificio relacionado',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  buildingId?: number;
}