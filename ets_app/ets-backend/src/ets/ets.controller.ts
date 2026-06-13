import { Controller, Get, Query } from '@nestjs/common';
import {
  ApiOperation,
  ApiQuery,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';

import { EtsService } from './ets.service.js';

@ApiTags('ets')
@Controller('ets')
export class EtsController {
  constructor(private readonly etsService: EtsService) {}

  @Get()
  @ApiOperation({
    summary: 'Consultar oferta pública de ETS',
  })
  @ApiQuery({
    name: 'carrera',
    required: false,
    example: 'ISC',
    description: 'Código de carrera',
  })
  @ApiQuery({
    name: 'plan',
    required: false,
    example: '2020',
    description: 'Plan de estudios',
  })
  @ApiQuery({
    name: 'semestre',
    required: false,
    example: 3,
    description: 'Semestre',
  })
  @ApiQuery({
    name: 'query',
    required: false,
    example: 'Algoritmos',
    description: 'Texto de búsqueda por materia, profesor, salón o carrera',
  })
  @ApiResponse({
    status: 200,
    description: 'Listado de ETS disponibles',
  })
  @ApiResponse({
    status: 400,
    description: 'Filtro de semestre inválido',
  })
  getEts(
    @Query('carrera') carrera?: string,
    @Query('plan') plan?: string,
    @Query('semestre') semestre?: string,
    @Query('query') query?: string,
  ) {
    return this.etsService.getEts({
      carrera,
      plan,
      semestre,
      query,
    });
  }
}