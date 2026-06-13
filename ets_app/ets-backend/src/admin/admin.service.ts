import {
  ConflictException,
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';

import { CatalogService } from '../catalog/catalog.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { CreateAdminEtsDto } from './dto/create_admin_ets.dto.js';
import { UpdateAdminEtsDto } from './dto/update_admin_ets.dto.js';

@Injectable()
export class AdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly catalogService: CatalogService,
  ) {}

  async getDashboard() {
    const [totalEts, totalCareers, totalBuildings, totalUsers, careers] =
      await Promise.all([
        this.prisma.ets.count(),
        this.prisma.career.count(),
        this.prisma.building.count(),
        this.prisma.user.count(),
        this.prisma.career.findMany({
          orderBy: {
            code: 'asc',
          },
          select: {
            id: true,
            code: true,
            name: true,
            _count: {
              select: {
                ets: true,
              },
            },
          },
        }),
      ]);

    return {
      totalEts,
      totalCareers,
      totalBuildings,
      totalUsers,
      examsByCareer: careers.map((career) => ({
        careerId: career.id,
        careerCode: career.code,
        careerName: career.name,
        totalEts: career._count.ets,
      })),
    };
  }

  createCareer(dto: Parameters<CatalogService['createCareer']>[0]) {
    return this.catalogService.createCareer(dto);
  }

  async deleteCareer(id: number) {
    const career = await this.prisma.career.findUnique({
      where: {
        id,
      },
      select: {
        id: true,
        code: true,
        name: true,
        _count: {
          select: {
            ets: true,
          },
        },
      },
    });

    if (!career) {
      throw new NotFoundException('La carrera solicitada no existe');
    }

    if (career._count.ets > 0) {
      throw new ConflictException(
        'No puedes eliminar esta carrera porque tiene ETS registrados',
      );
    }

    await this.prisma.career.delete({
      where: {
        id,
      },
    });

    return {
      message: 'Carrera eliminada correctamente',
      id: career.id,
      code: career.code,
      name: career.name,
    };
  }

  updateCareer(
    id: number,
    dto: Parameters<CatalogService['updateCareer']>[1],
  ) {
    return this.catalogService.updateCareer(id, dto);
  }

  createBuilding(dto: Parameters<CatalogService['createBuilding']>[0]) {
    return this.catalogService.createBuilding(dto);
  }

  updateBuilding(
    id: number,
    dto: Parameters<CatalogService['updateBuilding']>[1],
  ) {
    return this.catalogService.updateBuilding(id, dto);
  }

  getSubjects(query: Parameters<CatalogService['getSubjects']>[0]) {
    return this.catalogService.getSubjects(query);
  }

  createSubject(dto: Parameters<CatalogService['createSubject']>[0]) {
    return this.catalogService.createSubject(dto);
  }

  updateSubject(
    id: number,
    dto: Parameters<CatalogService['updateSubject']>[1],
  ) {
    return this.catalogService.updateSubject(id, dto);
  }

  deleteSubject(id: number) {
    return this.catalogService.deleteSubject(id);
  }

  async deleteBuilding(id: number) {
    const building = await this.prisma.building.findUnique({
      where: {
        id,
      },
      select: {
        id: true,
        name: true,
        _count: {
          select: {
            ets: true,
          },
        },
      },
    });

    if (!building) {
      throw new NotFoundException('El edificio solicitado no existe');
    }

    if (building._count.ets > 0) {
      throw new ConflictException(
        'No puedes eliminar este edificio porque tiene ETS registrados',
      );
    }

    await this.prisma.building.delete({
      where: {
        id,
      },
    });

    return {
      message: 'Edificio eliminado correctamente',
      id: building.id,
      name: building.name,
    };
  }

  async getEts() {
    const exams = await this.prisma.ets.findMany({
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
        subject: true,
      },
    });

    return exams.map((exam) => this.toEtsResponse(exam));
  }

  async createEts(dto: CreateAdminEtsDto) {
    await this.validateCareerAndPlan(dto.careerId, dto.plan);

    const subject = await this.validateSubject(
      dto.subjectId,
      dto.careerId,
      dto.plan,
      dto.semestre,
    );

    if (dto.buildingId !== undefined) {
      await this.validateBuilding(dto.buildingId);
    }

    const exam = await this.prisma.ets.create({
      data: {
        ua: subject.name,
        subjectId: subject.id,
        careerId: dto.careerId,
        plan: dto.plan,
        semestre: subject.semestre,
        fechaIso: dto.fechaIso,
        turno: dto.turno,
        salon: dto.salon,
        profesor: dto.profesor,
        correo: dto.correo,
        buildingId: dto.buildingId ?? null,
      },
      include: {
        career: true,
        building: true,
        subject: true,
      },
    });

    return this.toEtsResponse(exam);
  }

  async updateEts(id: number, dto: UpdateAdminEtsDto) {
    const currentExam = await this.prisma.ets.findUnique({
      where: {
        id,
      },
    });

    if (!currentExam) {
      throw new NotFoundException('El ETS solicitado no existe');
    }

    const careerId = dto.careerId ?? currentExam.careerId;
    const plan = dto.plan ?? currentExam.plan;
    const semestre = dto.semestre ?? currentExam.semestre;
    const subjectId = dto.subjectId ?? currentExam.subjectId;

    await this.validateCareerAndPlan(careerId, plan);

    let subjectName = dto.ua ?? currentExam.ua;
    let finalSubjectId = subjectId;

    if (subjectId !== null && subjectId !== undefined) {
      const subject = await this.validateSubject(
        subjectId,
        careerId,
        plan,
        semestre,
      );

      subjectName = subject.name;
      finalSubjectId = subject.id;
    }

    if (dto.buildingId !== undefined) {
      await this.validateBuilding(dto.buildingId);
    }

    const exam = await this.prisma.ets.update({
      where: {
        id,
      },
      data: {
        ua: subjectName,
        subjectId: finalSubjectId,
        careerId: dto.careerId,
        plan: dto.plan,
        semestre: dto.semestre,
        fechaIso: dto.fechaIso,
        turno: dto.turno,
        salon: dto.salon,
        profesor: dto.profesor,
        correo: dto.correo,
        buildingId: dto.buildingId,
      },
      include: {
        career: true,
        building: true,
        subject: true,
      },
    });

    return this.toEtsResponse(exam);
  }

  async deleteEts(id: number) {
    const currentExam = await this.prisma.ets.findUnique({
      where: {
        id,
      },
    });

    if (!currentExam) {
      throw new NotFoundException('El ETS solicitado no existe');
    }

    await this.prisma.ets.delete({
      where: {
        id,
      },
    });

    return {
      message: 'ETS eliminado correctamente',
      id,
    };
  }

  private async validateCareerAndPlan(careerId: number, plan: string) {
    const career = await this.prisma.career.findUnique({
      where: {
        id: careerId,
      },
    });

    if (!career) {
      throw new NotFoundException('La carrera seleccionada no existe');
    }

    if (!career.plans.includes(plan)) {
      throw new UnprocessableEntityException(
        `El plan ${plan} no pertenece a la carrera ${career.code}`,
      );
    }
  }

  private async validateBuilding(buildingId: number) {
    const building = await this.prisma.building.findUnique({
      where: {
        id: buildingId,
      },
    });

    if (!building) {
      throw new NotFoundException('El edificio seleccionado no existe');
    }
  }

  private async validateSubject(
    subjectId: number,
    careerId: number,
    plan: string,
    semestre: number,
  ) {
    const subject = await this.prisma.subject.findUnique({
      where: {
        id: subjectId,
      },
      include: {
        career: true,
      },
    });

    if (!subject) {
      throw new NotFoundException('La materia seleccionada no existe');
    }

    if (subject.careerId !== careerId) {
      throw new UnprocessableEntityException(
        `La materia ${subject.name} no pertenece a la carrera seleccionada`,
      );
    }

    if (subject.plan !== plan) {
      throw new UnprocessableEntityException(
        `La materia ${subject.name} no pertenece al plan ${plan}`,
      );
    }

    if (subject.semestre !== semestre) {
      throw new UnprocessableEntityException(
        `La materia ${subject.name} no pertenece al semestre ${semestre}`,
      );
    }

    return subject;
  }
  private toEtsResponse(exam: {
    id: number;
    ua: string;
    plan: string;
    semestre: number;
    fechaIso: string;
    turno: string;
    salon: string;
    profesor: string;
    correo: string;
    careerId: number;
    buildingId: number | null;
    subjectId: number | null;
    career: {
      code: string;
      name: string;
    };
    building: {
      id: number;
      name: string;
    } | null;
    subject: {
      id: number;
      name: string;
      semestre: number;
      plan: string;
    } | null;
  }) {
    return {
      id: exam.id,
      ua: exam.ua,
      subjectId: exam.subjectId,
      materia: exam.subject?.name ?? exam.ua,
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
    };
  }
}