import {
  ConflictException,
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service.js';
import { CreateBuildingDto } from './dto/create_building.dto.js';
import { CreateCareerDto } from './dto/create_career.dto.js';
import { CreateSubjectDto } from './dto/create_subject.dto.js';
import { UpdateBuildingDto } from './dto/update_building.dto.js';
import { UpdateCareerDto } from './dto/update_career.dto.js';
import { UpdateSubjectDto } from './dto/update_subject.dto.js';

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

  async updateCareer(id: number, dto: UpdateCareerDto) {
    await this.ensureCareerExists(id);

    try {
      return await this.prisma.career.update({
        where: { id },
        data: {
          ...(dto.code !== undefined ? { code: dto.code } : {}),
          ...(dto.name !== undefined ? { name: dto.name } : {}),
          ...(dto.plans !== undefined ? { plans: dto.plans } : {}),
        },
        select: { id: true, code: true, name: true, plans: true },
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

  async updateBuilding(id: number, dto: UpdateBuildingDto) {
    const building = await this.prisma.building.findUnique({ where: { id } });

    if (!building) {
      throw new NotFoundException('El edificio solicitado no existe');
    }

    try {
      return await this.prisma.building.update({
        where: { id },
        data: { name: dto.name },
        select: { id: true, name: true },
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

  async createSubject(dto: CreateSubjectDto) {
    await this.ensureCareerHasPlan(dto.careerId, dto.plan);

    try {
      return await this.prisma.subject.create({
        data: {
          name: dto.name,
          careerId: dto.careerId,
          plan: dto.plan,
          semestre: dto.semestre,
        },
        select: {
          id: true,
          name: true,
          careerId: true,
          plan: true,
          semestre: true,
        },
      });
    } catch (error: unknown) {
      if (this.isUniqueConstraintError(error)) {
        throw new ConflictException(
          'Ya existe una materia con ese nombre en esa carrera, plan y semestre',
        );
      }
      throw error;
    }
  }

  async updateSubject(id: number, dto: UpdateSubjectDto) {
    const subject = await this.prisma.subject.findUnique({ where: { id } });

    if (!subject) {
      throw new NotFoundException('La materia solicitada no existe');
    }

    const careerId = dto.careerId ?? subject.careerId;
    const plan = dto.plan ?? subject.plan;

    if (dto.careerId !== undefined || dto.plan !== undefined) {
      await this.ensureCareerHasPlan(careerId, plan);
    }

    try {
      return await this.prisma.subject.update({
        where: { id },
        data: {
          ...(dto.name !== undefined ? { name: dto.name } : {}),
          ...(dto.careerId !== undefined ? { careerId: dto.careerId } : {}),
          ...(dto.plan !== undefined ? { plan: dto.plan } : {}),
          ...(dto.semestre !== undefined ? { semestre: dto.semestre } : {}),
        },
        select: {
          id: true,
          name: true,
          careerId: true,
          plan: true,
          semestre: true,
        },
      });
    } catch (error: unknown) {
      if (this.isUniqueConstraintError(error)) {
        throw new ConflictException(
          'Ya existe una materia con ese nombre en esa carrera, plan y semestre',
        );
      }
      throw error;
    }
  }

  async deleteSubject(id: number) {
    const subject = await this.prisma.subject.findUnique({ where: { id } });

    if (!subject) {
      throw new NotFoundException('La materia solicitada no existe');
    }

    // Los ETS que referencian la materia quedan con subjectId = null (onDelete: SetNull).
    await this.prisma.subject.delete({ where: { id } });

    return {
      message: 'Materia eliminada correctamente',
      id: subject.id,
      name: subject.name,
    };
  }

  private async ensureCareerExists(id: number) {
    const career = await this.prisma.career.findUnique({ where: { id } });

    if (!career) {
      throw new NotFoundException('La carrera solicitada no existe');
    }

    return career;
  }

  private async ensureCareerHasPlan(careerId: number, plan: string) {
    const career = await this.ensureCareerExists(careerId);

    if (!career.plans.includes(plan)) {
      throw new UnprocessableEntityException(
        `El plan ${plan} no pertenece a la carrera ${career.code}`,
      );
    }

    return career;
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