import { Module } from '@nestjs/common';

import { EtsController } from './ets.controller.js';
import { EtsService } from './ets.service.js';

@Module({
  controllers: [EtsController],
  providers: [EtsService],
  exports: [EtsService],
})
export class EtsModule {}