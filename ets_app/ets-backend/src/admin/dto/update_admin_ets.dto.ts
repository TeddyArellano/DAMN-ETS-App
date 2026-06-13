import { PartialType } from '@nestjs/swagger';

import { CreateAdminEtsDto } from './create_admin_ets.dto.js';

export class UpdateAdminEtsDto extends PartialType(CreateAdminEtsDto) {}