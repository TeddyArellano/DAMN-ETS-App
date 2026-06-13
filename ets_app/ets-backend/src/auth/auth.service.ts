import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';

import { PrismaService } from '../prisma/prisma.service.js';
import { LoginDto } from './dto/login.dto.js';
import { RegisterDto } from './dto/register.dto.js';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const email = dto.email.trim().toLowerCase();
    const boleta = dto.boleta?.trim();

    const existingEmail = await this.prisma.user.findFirst({
      where: {
        email,
      },
    });

    if (existingEmail) {
      throw new ConflictException('Este correo ya está registrado.');
    }

    if (boleta) {
      const existingBoleta = await this.prisma.user.findFirst({
        where: {
          boleta,
        },
      });

      if (existingBoleta) {
        throw new ConflictException('Esta boleta ya está registrada.');
      }
    }

    const hashedPassword = await bcrypt.hash(dto.password, 12);

    const user = await this.prisma.user.create({
      data: {
        name: dto.name.trim(),
        email,
        boleta: boleta || null,
        password: hashedPassword,
        role: 'STUDENT',
      },
    });

    const accessToken = await this.jwtService.signAsync({
      sub: user.id,
      email: user.email,
      role: user.role,
    });

    return {
      accessToken,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        boleta: user.boleta,
        role: user.role,
      },
    };
  }

  async login(dto: LoginDto) {
    const email = dto.email.trim().toLowerCase();

    const user = await this.prisma.user.findUnique({
      where: {
        email,
      },
    });

    if (!user) {
      throw new UnauthorizedException('Correo o contraseña incorrectos');
    }

    const passwordMatches = await bcrypt.compare(dto.password, user.password);

    if (!passwordMatches) {
      throw new UnauthorizedException('Correo o contraseña incorrectos');
    }

    const safeUser = {
      id: user.id,
      name: user.name,
      email: user.email,
      boleta: user.boleta,
      role: user.role,
      createdAt: user.createdAt,
    };

    const accessToken = await this.createToken(safeUser);

    return {
      message: 'Inicio de sesión correcto',
      accessToken,
      user: safeUser,
    };
  }

  private async createToken(user: {
    id: number;
    email: string;
    role: string;
  }): Promise<string> {
    return this.jwtService.signAsync({
      sub: user.id,
      email: user.email,
      role: user.role,
    });
  }
}