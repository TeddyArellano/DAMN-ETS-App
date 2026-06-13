import { BadRequestException } from '@nestjs/common';

// Evita cargar el cliente Prisma generado (usa import.meta) en el runtime de jest.
jest.mock('../prisma/prisma.service.js', () => ({ PrismaService: class {} }));

import { EtsService } from './ets.service.js';

function makePrisma() {
  return {
    ets: {
      findMany: jest.fn(),
    },
  };
}

const sampleRow = {
  id: 1,
  ua: 'Bases de Datos',
  careerId: 1,
  plan: '2020',
  semestre: 4,
  fechaIso: '2026-06-22T14:30:00.000Z',
  turno: 'Matutino',
  salon: '2204',
  profesor: 'Profe',
  correo: 'p@escom.ipn.mx',
  buildingId: 2,
  career: { code: 'ISC', name: 'Ingeniería en Sistemas Computacionales' },
  building: { name: 'Edificio 2' },
};

describe('EtsService', () => {
  let prisma: ReturnType<typeof makePrisma>;
  let service: EtsService;

  beforeEach(() => {
    prisma = makePrisma();
    service = new EtsService(prisma as never);
  });

  it('mapea la fila de Prisma al DTO público (carrera, edificio)', async () => {
    prisma.ets.findMany.mockResolvedValue([sampleRow]);

    const result = await service.getEts({});

    expect(result).toHaveLength(1);
    expect(result[0].carrera).toBe('ISC');
    expect(result[0].carreraNombre).toContain('Sistemas');
    expect(result[0].edificio).toBe('Edificio 2');
  });

  it('devuelve edificio null cuando no hay building', async () => {
    prisma.ets.findMany.mockResolvedValue([{ ...sampleRow, building: null }]);

    const result = await service.getEts({});
    expect(result[0].edificio).toBeNull();
  });

  it('construye el filtro: carrera en mayúsculas, plan, semestre y búsqueda OR', async () => {
    prisma.ets.findMany.mockResolvedValue([]);

    await service.getEts({
      carrera: 'isc',
      plan: '2020',
      semestre: '4',
      query: 'algoritmos',
    });

    const where = prisma.ets.findMany.mock.calls[0][0].where;
    expect(where.career.code).toBe('ISC');
    expect(where.plan).toBe('2020');
    expect(where.semestre).toBe(4);
    expect(Array.isArray(where.OR)).toBe(true);
    expect(where.OR.length).toBeGreaterThan(0);
  });

  it('sin filtros no agrega condiciones de carrera/plan/semestre', async () => {
    prisma.ets.findMany.mockResolvedValue([]);

    await service.getEts({});

    const where = prisma.ets.findMany.mock.calls[0][0].where;
    expect(where.career).toBeUndefined();
    expect(where.plan).toBeUndefined();
    expect(where.semestre).toBeUndefined();
    expect(where.OR).toBeUndefined();
  });

  it('rechaza semestres fuera de rango con 400', async () => {
    await expect(service.getEts({ semestre: '99' })).rejects.toBeInstanceOf(
      BadRequestException,
    );
    await expect(service.getEts({ semestre: 'abc' })).rejects.toBeInstanceOf(
      BadRequestException,
    );
    expect(prisma.ets.findMany).not.toHaveBeenCalled();
  });
});
