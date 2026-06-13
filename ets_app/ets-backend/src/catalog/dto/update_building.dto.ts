import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsString, MinLength } from 'class-validator';

/// Actualización de un edificio.
export class UpdateBuildingDto {
  @ApiProperty({ example: 'Edificio 3' })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  @MinLength(2, { message: 'El nombre debe contener al menos 2 caracteres' })
  name: string;
}
