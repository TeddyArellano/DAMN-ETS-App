import { ConflictException, Injectable } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service.js';
import { CreateBuildingDto } from './dto/create_building.dto.js';
import { CreateCareerDto } from './dto/create_career.dto.js';

@Injectable()
export class CatalogService {
  constructor(private readonly prisma: PrismaService) {}

  getCareers() {
    return this.prisma.career.findMany({
      orderBy: {
        code: 'asc',
      },
      select: {
        id: true,
        code: true,
        name: true,
        plans: true,
      },
    });
  }

  getBuildings() {
    return this.prisma.building.findMany({
      orderBy: {
        name: 'asc',
      },
      select: {
        id: true,
        name: true,
      },
    });
  }

  async getSubjects(query: {
    careerId?: number;
    plan?: string;
    semestre?: number;
  }) {
    const where: {
      careerId?: number;
      plan?: string;
      semestre?: number;
    } = {};

    if (query.careerId !== undefined) {
      where.careerId = query.careerId;
    }

    if (query.plan !== undefined && query.plan.trim().length > 0) {
      where.plan = query.plan.trim();
    }

    if (query.semestre !== undefined) {
      where.semestre = query.semestre;
    }

    const subjects = await this.prisma.subject.findMany({
      where,
      include: {
        career: true,
      },
      orderBy: [
        {
          career: {
            code: 'asc',
          },
        },
        {
          plan: 'asc',
        },
        {
          semestre: 'asc',
        },
        {
          name: 'asc',
        },
      ],
    });

    return subjects.map((subject) => ({
      id: subject.id,
      name: subject.name,
      careerId: subject.careerId,
      careerCode: subject.career.code,
      careerName: subject.career.name,
      plan: subject.plan,
      semestre: subject.semestre,
    }));
  }

  async createCareer(dto: CreateCareerDto) {
    try {
      return await this.prisma.career.create({
        data: {
          code: dto.code,
          name: dto.name,
          plans: dto.plans,
        },
        select: {
          id: true,
          code: true,
          name: true,
          plans: true,
        },
      });
    } catch (error: unknown) {
      if (this.isUniqueConstraintError(error)) {
        throw new ConflictException(
          'Ya existe una carrera registrada con ese código',
        );
      }

      throw error;
    }
  }

  async createBuilding(dto: CreateBuildingDto) {
    try {
      return await this.prisma.building.create({
        data: {
          name: dto.name,
        },
        select: {
          id: true,
          name: true,
        },
      });
    } catch (error: unknown) {
      if (this.isUniqueConstraintError(error)) {
        throw new ConflictException(
          'Ya existe un edificio registrado con ese nombre',
        );
      }

      throw error;
    }
  }

  private isUniqueConstraintError(error: unknown): boolean {
    return (
      typeof error === 'object' &&
      error !== null &&
      'code' in error &&
      error.code === 'P2002'
    );
  }
}