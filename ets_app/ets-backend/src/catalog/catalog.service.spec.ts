import {
  ConflictException,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';

// Evita cargar el cliente Prisma generado (usa import.meta) en jest.
jest.mock('../prisma/prisma.service.js', () => ({ PrismaService: class {} }));

import { CatalogService } from './catalog.service.js';

function makePrisma() {
  return {
    career: { findUnique: jest.fn(), update: jest.fn() },
    building: { findUnique: jest.fn(), update: jest.fn() },
    subject: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
  };
}

const uniqueError = { code: 'P2002' };

describe('CatalogService (catálogos y materias)', () => {
  let prisma: ReturnType<typeof makePrisma>;
  let service: CatalogService;

  beforeEach(() => {
    prisma = makePrisma();
    service = new CatalogService(prisma as never);
  });

  describe('updateCareer', () => {
    it('lanza 404 si la carrera no existe', async () => {
      prisma.career.findUnique.mockResolvedValue(null);
      await expect(
        service.updateCareer(1, { name: 'X' }),
      ).rejects.toBeInstanceOf(NotFoundException);
      expect(prisma.career.update).not.toHaveBeenCalled();
    });

    it('actualiza solo los campos enviados', async () => {
      prisma.career.findUnique.mockResolvedValue({ id: 1, code: 'ISC' });
      prisma.career.update.mockResolvedValue({
        id: 1,
        code: 'ISC',
        name: 'Nuevo',
        plans: ['2020'],
      });

      await service.updateCareer(1, { name: 'Nuevo' });

      const data = prisma.career.update.mock.calls[0][0].data;
      expect(data.name).toBe('Nuevo');
      expect(data.code).toBeUndefined();
      expect(data.plans).toBeUndefined();
    });

    it('mapea el código duplicado a 409', async () => {
      prisma.career.findUnique.mockResolvedValue({ id: 1, code: 'ISC' });
      prisma.career.update.mockRejectedValue(uniqueError);
      await expect(
        service.updateCareer(1, { code: 'IIA' }),
      ).rejects.toBeInstanceOf(ConflictException);
    });
  });

  describe('updateBuilding', () => {
    it('lanza 404 si el edificio no existe', async () => {
      prisma.building.findUnique.mockResolvedValue(null);
      await expect(
        service.updateBuilding(5, { name: 'Edificio 9' }),
      ).rejects.toBeInstanceOf(NotFoundException);
    });
  });

  describe('createSubject', () => {
    it('lanza 404 si la carrera no existe', async () => {
      prisma.career.findUnique.mockResolvedValue(null);
      await expect(
        service.createSubject({
          name: 'Redes',
          careerId: 1,
          plan: '2020',
          semestre: 5,
        }),
      ).rejects.toBeInstanceOf(NotFoundException);
    });

    it('lanza 422 si el plan no pertenece a la carrera', async () => {
      prisma.career.findUnique.mockResolvedValue({
        id: 1,
        code: 'ISC',
        plans: ['2009'],
      });
      await expect(
        service.createSubject({
          name: 'Redes',
          careerId: 1,
          plan: '2020',
          semestre: 5,
        }),
      ).rejects.toBeInstanceOf(UnprocessableEntityException);
    });

    it('crea la materia cuando carrera y plan son válidos', async () => {
      prisma.career.findUnique.mockResolvedValue({
        id: 1,
        code: 'ISC',
        plans: ['2020'],
      });
      prisma.subject.create.mockResolvedValue({
        id: 10,
        name: 'Redes',
        careerId: 1,
        plan: '2020',
        semestre: 5,
      });

      const result = await service.createSubject({
        name: 'Redes',
        careerId: 1,
        plan: '2020',
        semestre: 5,
      });

      expect(prisma.subject.create).toHaveBeenCalled();
      expect(result.id).toBe(10);
    });

    it('mapea la materia duplicada a 409', async () => {
      prisma.career.findUnique.mockResolvedValue({
        id: 1,
        code: 'ISC',
        plans: ['2020'],
      });
      prisma.subject.create.mockRejectedValue(uniqueError);
      await expect(
        service.createSubject({
          name: 'Redes',
          careerId: 1,
          plan: '2020',
          semestre: 5,
        }),
      ).rejects.toBeInstanceOf(ConflictException);
    });
  });

  describe('deleteSubject', () => {
    it('lanza 404 si la materia no existe', async () => {
      prisma.subject.findUnique.mockResolvedValue(null);
      await expect(service.deleteSubject(7)).rejects.toBeInstanceOf(
        NotFoundException,
      );
      expect(prisma.subject.delete).not.toHaveBeenCalled();
    });

    it('elimina la materia existente', async () => {
      prisma.subject.findUnique.mockResolvedValue({ id: 7, name: 'Redes' });
      prisma.subject.delete.mockResolvedValue({});

      const result = await service.deleteSubject(7);

      expect(prisma.subject.delete).toHaveBeenCalledWith({ where: { id: 7 } });
      expect(result.id).toBe(7);
    });
  });
});
