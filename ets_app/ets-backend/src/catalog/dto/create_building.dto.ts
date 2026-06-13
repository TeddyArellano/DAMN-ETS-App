import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsString, MinLength } from 'class-validator';

export class CreateBuildingDto {
  @ApiProperty({
    example: 'Edificio 1',
    description: 'Nombre del edificio o zona de salones',
  })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim() : value,
  )
  @IsString()
  @MinLength(2, {
    message: 'El nombre debe contener al menos 2 caracteres',
  })
  name: string;
}