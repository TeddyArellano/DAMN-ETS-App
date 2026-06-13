import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export class GetSubjectsQueryDto {
  @ApiPropertyOptional({
    example: 1,
    description: 'ID de la carrera',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  careerId?: number;

  @ApiPropertyOptional({
    example: '2020',
    description: 'Plan de estudios',
  })
  @IsOptional()
  @IsString()
  plan?: string;

  @ApiPropertyOptional({
    example: 3,
    description: 'Semestre',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(12)
  semestre?: number;
}