import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Put,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';

import { Roles } from '../auth/decorators/roles.decorator.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { RolesGuard } from '../auth/guards/roles.guard.js';
import { CreateBuildingDto } from '../catalog/dto/create_building.dto.js';
import { CreateCareerDto } from '../catalog/dto/create_career.dto.js';
import { AdminService } from './admin.service.js';
import { CreateAdminEtsDto } from './dto/create_admin_ets.dto.js';
import { UpdateAdminEtsDto } from './dto/update_admin_ets.dto.js';

@ApiTags('admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN')
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Consultar estadísticas del panel administrativo' })
  @ApiResponse({ status: 200, description: 'Estadísticas administrativas' })
  @ApiResponse({ status: 403, description: 'Acceso solo para administradores' })
  getDashboard() {
    return this.adminService.getDashboard();
  }

  @Post('catalog/careers')
  @ApiOperation({ summary: 'Crear una carrera' })
  @ApiResponse({ status: 201, description: 'Carrera creada correctamente' })
  createCareer(@Body() dto: CreateCareerDto) {
    return this.adminService.createCareer(dto);
  }

  @Delete('catalog/careers/:id')
  @ApiOperation({ summary: 'Eliminar una carrera sin ETS asociados' })
  @ApiResponse({ status: 200, description: 'Carrera eliminada correctamente' })
  @ApiResponse({
    status: 404,
    description: 'La carrera solicitada no existe',
  })
  @ApiResponse({
    status: 409,
    description: 'La carrera tiene ETS registrados y no puede eliminarse',
  })
  deleteCareer(@Param('id', ParseIntPipe) id: number) {
    return this.adminService.deleteCareer(id);
  }

  @Post('catalog/buildings')
  @ApiOperation({ summary: 'Crear un edificio' })
  @ApiResponse({ status: 201, description: 'Edificio creado correctamente' })
  createBuilding(@Body() dto: CreateBuildingDto) {
    return this.adminService.createBuilding(dto);
  }

  @Delete('catalog/buildings/:id')
  @ApiOperation({ summary: 'Eliminar un edificio sin ETS asociados' })
  @ApiResponse({ status: 200, description: 'Edificio eliminado correctamente' })
  @ApiResponse({
    status: 404,
    description: 'El edificio solicitado no existe',
  })
  @ApiResponse({
    status: 409,
    description: 'El edificio tiene ETS registrados y no puede eliminarse',
  })
  deleteBuilding(@Param('id', ParseIntPipe) id: number) {
    return this.adminService.deleteBuilding(id);
  }

  @Get('ets')
  @ApiOperation({ summary: 'Consultar ETS para administración' })
  @ApiResponse({ status: 200, description: 'Listado administrativo de ETS' })
  getEts() {
    return this.adminService.getEts();
  }

  @Post('ets')
  @ApiOperation({ summary: 'Crear un ETS' })
  @ApiResponse({ status: 201, description: 'ETS creado correctamente' })
  createEts(@Body() dto: CreateAdminEtsDto) {
    return this.adminService.createEts(dto);
  }

  @Put('ets/:id')
  @ApiOperation({ summary: 'Actualizar un ETS existente' })
  @ApiResponse({ status: 200, description: 'ETS actualizado correctamente' })
  updateEts(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateAdminEtsDto,
  ) {
    return this.adminService.updateEts(id, dto);
  }

  @Delete('ets/:id')
  @ApiOperation({ summary: 'Eliminar un ETS existente' })
  @ApiResponse({ status: 200, description: 'ETS eliminado correctamente' })
  @ApiResponse({ status: 404, description: 'El ETS solicitado no existe' })
  deleteEts(@Param('id', ParseIntPipe) id: number) {
    return this.adminService.deleteEts(id);
  }
}