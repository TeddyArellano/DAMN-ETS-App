import { ConflictException, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcryptjs';

// Evita cargar el cliente Prisma generado (usa import.meta) en el runtime de jest.
jest.mock('../prisma/prisma.service.js', () => ({ PrismaService: class {} }));

import { AuthService } from './auth.service.js';

function makePrisma() {
  return {
    user: {
      findFirst: jest.fn(),
      findUnique: jest.fn(),
      create: jest.fn(),
    },
  };
}

describe('AuthService', () => {
  let prisma: ReturnType<typeof makePrisma>;
  let jwt: { signAsync: jest.Mock };
  let service: AuthService;

  beforeEach(() => {
    prisma = makePrisma();
    jwt = { signAsync: jest.fn().mockResolvedValue('token123') };
    service = new AuthService(prisma as never, jwt as never);
  });

  describe('register', () => {
    it('crea un estudiante, normaliza el correo y hashea la contraseña', async () => {
      prisma.user.findFirst.mockResolvedValue(null);
      prisma.user.create.mockImplementation(async ({ data }: any) => ({
        id: 1,
        ...data,
      }));

      const res = await service.register({
        name: '  Ana López  ',
        email: '  ANA@Escom.IPN.mx ',
        password: 'password123',
      } as never);

      const createArg = prisma.user.create.mock.calls[0][0].data;
      expect(createArg.email).toBe('ana@escom.ipn.mx');
      expect(createArg.name).toBe('Ana López');
      expect(createArg.role).toBe('STUDENT');
      // La contraseña nunca se guarda en claro.
      expect(createArg.password).not.toBe('password123');
      expect(await bcrypt.compare('password123', createArg.password)).toBe(true);

      expect(res.accessToken).toBe('token123');
      expect(res.user.role).toBe('STUDENT');
    });

    it('rechaza correos duplicados con 409', async () => {
      prisma.user.findFirst.mockResolvedValue({ id: 9 });

      await expect(
        service.register({
          name: 'Ana',
          email: 'ana@escom.ipn.mx',
          password: 'password123',
        } as never),
      ).rejects.toBeInstanceOf(ConflictException);
      expect(prisma.user.create).not.toHaveBeenCalled();
    });

    it('rechaza boletas duplicadas con 409', async () => {
      prisma.user.findFirst
        .mockResolvedValueOnce(null) // correo libre
        .mockResolvedValueOnce({ id: 7 }); // boleta ocupada

      await expect(
        service.register({
          name: 'Ana',
          email: 'ana@escom.ipn.mx',
          boleta: '2024630123',
          password: 'password123',
        } as never),
      ).rejects.toBeInstanceOf(ConflictException);
    });
  });

  describe('login', () => {
    it('devuelve token y usuario seguro con credenciales válidas', async () => {
      const hash = await bcrypt.hash('secret123', 12);
      prisma.user.findUnique.mockResolvedValue({
        id: 1,
        name: 'Admin',
        email: 'admin@escom.mx',
        boleta: null,
        password: hash,
        role: 'ADMIN',
        createdAt: new Date(),
      });

      const res = await service.login({
        email: 'ADMIN@escom.mx',
        password: 'secret123',
      } as never);

      expect(res.accessToken).toBe('token123');
      expect(res.user.role).toBe('ADMIN');
      // No filtra el hash de la contraseña.
      expect((res.user as Record<string, unknown>).password).toBeUndefined();
    });

    it('lanza 401 si el usuario no existe', async () => {
      prisma.user.findUnique.mockResolvedValue(null);

      await expect(
        service.login({ email: 'x@y.z', password: 'whatever' } as never),
      ).rejects.toBeInstanceOf(UnauthorizedException);
    });

    it('lanza 401 si la contraseña es incorrecta', async () => {
      const hash = await bcrypt.hash('correcta', 12);
      prisma.user.findUnique.mockResolvedValue({
        id: 1,
        name: 'Ana',
        email: 'ana@escom.ipn.mx',
        boleta: null,
        password: hash,
        role: 'STUDENT',
        createdAt: new Date(),
      });

      await expect(
        service.login({
          email: 'ana@escom.ipn.mx',
          password: 'incorrecta',
        } as never),
      ).rejects.toBeInstanceOf(UnauthorizedException);
    });
  });
});
