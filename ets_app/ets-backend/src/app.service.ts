import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHealth() {
    return {
      name: 'ETS ESCOM API',
      status: 'ok',
      message: 'Backend funcionando correctamente',
    };
  }
}