import { Controller, Get, Query } from '@nestjs/common';
import { ApiOperation, ApiQuery, ApiResponse, ApiTags } from '@nestjs/swagger';

import { CatalogService } from './catalog.service.js';
import { GetSubjectsQueryDto } from './dto/get_subjects_query.dto.js';

@ApiTags('catalog')
@Controller('catalog')
export class CatalogController {
  constructor(private readonly catalogService: CatalogService) {}

  @Get('careers')
  @ApiOperation({ summary: 'Consultar catálogo público de carreras' })
  @ApiResponse({
    status: 200,
    description: 'Listado de carreras disponibles',
  })
  getCareers() {
    return this.catalogService.getCareers();
  }

  @Get('buildings')
  @ApiOperation({ summary: 'Consultar catálogo público de edificios' })
  @ApiResponse({
    status: 200,
    description: 'Listado de edificios disponibles',
  })
  getBuildings() {
    return this.catalogService.getBuildings();
  }

  @Get('subjects')
  @ApiOperation({
    summary: 'Consultar materias por carrera, plan y semestre',
  })
  @ApiQuery({
    name: 'careerId',
    required: false,
    type: Number,
    description: 'ID de la carrera',
    example: 1,
  })
  @ApiQuery({
    name: 'plan',
    required: false,
    type: String,
    description: 'Plan de estudios',
    example: '2020',
  })
  @ApiQuery({
    name: 'semestre',
    required: false,
    type: Number,
    description: 'Semestre de la materia',
    example: 3,
  })
  @ApiResponse({
    status: 200,
    description: 'Listado de materias filtradas',
  })
  getSubjects(@Query() query: GetSubjectsQueryDto) {
    return this.catalogService.getSubjects(query);
  }
}