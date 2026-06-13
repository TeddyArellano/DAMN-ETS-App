import { ApiProperty } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { IsInt, IsString, Max, Min, MinLength } from 'class-validator';

/// Alta de una materia (unidad de aprendizaje) en una carrera/plan/semestre.
export class CreateSubjectDto {
  @ApiProperty({ example: 'Análisis y Diseño de Algoritmos' })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  @MinLength(3, { message: 'El nombre debe contener al menos 3 caracteres' })
  name: string;

  @ApiProperty({ example: 1, description: 'ID de la carrera' })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  careerId: number;

  @ApiProperty({ example: '2020', description: 'Plan de estudios' })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  plan: string;

  @ApiProperty({ example: 4, description: 'Semestre (1-12)' })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(12)
  semestre: number;
}
