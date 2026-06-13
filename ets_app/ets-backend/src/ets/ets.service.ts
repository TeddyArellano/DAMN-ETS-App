import { BadRequestException, Injectable } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service.js';

type GetEtsFilters = {
  carrera?: string;
  plan?: string;
  semestre?: string;
  query?: string;
};

@Injectable()
export class EtsService {
  constructor(private readonly prisma: PrismaService) {}

  async getEts(filters: GetEtsFilters) {
    const carrera = filters.carrera?.trim().toUpperCase();
    const plan = filters.plan?.trim();
    const query = filters.query?.trim();
    const semestre = this.parseSemester(filters.semestre);

    const exams = await this.prisma.ets.findMany({
      where: {
        ...(carrera
          ? {
              career: {
                code: carrera,
              },
            }
          : {}),
        ...(plan ? { plan } : {}),
        ...(semestre !== undefined ? { semestre } : {}),
        ...(query
          ? {
              OR: [
                {
                  ua: {
                    contains: query,
                    mode: 'insensitive',
                  },
                },
                {
                  profesor: {
                    contains: query,
                    mode: 'insensitive',
                  },
                },
                {
                  salon: {
                    contains: query,
                    mode: 'insensitive',
                  },
                },
                {
                  career: {
                    name: {
                      contains: query,
                      mode: 'insensitive',
                    },
                  },
                },
              ],
            }
          : {}),
      },
      orderBy: [
        {
          fechaIso: 'asc',
        },
        {
          ua: 'asc',
        },
      ],
      include: {
        career: true,
        building: true,
      },
    });

    return exams.map((exam) => ({
      id: exam.id,
      ua: exam.ua,
      carrera: exam.career.code,
      carreraNombre: exam.career.name,
      careerId: exam.careerId,
      plan: exam.plan,
      semestre: exam.semestre,
      fechaIso: exam.fechaIso,
      turno: exam.turno,
      salon: exam.salon,
      profesor: exam.profesor,
      correo: exam.correo,
      buildingId: exam.buildingId,
      edificio: exam.building?.name ?? null,
    }));
  }

  private parseSemester(value?: string): number | undefined {
    if (!value || value.trim().length === 0) {
      return undefined;
    }

    const semester = Number(value);

    if (!Number.isInteger(semester) || semester < 1 || semester > 12) {
      throw new BadRequestException(
        'El semestre debe ser un número entero entre 1 y 12',
      );
    }

    return semester;
  }
}