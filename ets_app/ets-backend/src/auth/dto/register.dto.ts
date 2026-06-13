import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsOptional,
  IsString,
  Matches,
  MinLength,
} from 'class-validator';

export class RegisterDto {
  @ApiProperty({
    example: 'Miguel Juárez',
    description: 'Nombre completo del estudiante',
  })
  @IsString()
  @MinLength(3, { message: 'El nombre debe contener al menos 3 caracteres' })
  name: string;

  @ApiProperty({
    example: 'alumno@escom.ipn.mx',
    description: 'Correo electrónico del usuario',
  })
  @IsEmail({}, { message: 'El correo electrónico no es válido' })
  email: string;

  @ApiPropertyOptional({
    example: '2024630123',
    description: 'Boleta del estudiante',
  })
  @IsOptional()
  @IsString()
  @Matches(/^[0-9]{8,12}$/, {
    message: 'La boleta debe contener entre 8 y 12 números',
  })
  boleta?: string;

  @ApiProperty({
    example: 'Password123',
    description: 'Contraseña con mínimo 8 caracteres',
  })
  @IsString()
  @MinLength(8, {
    message: 'La contraseña debe contener al menos 8 caracteres',
  })
  password: string;
}