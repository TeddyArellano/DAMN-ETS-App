import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';

import { AppController } from '../src/app.controller.js';
import { AppService } from '../src/app.service.js';

// e2e de la capa HTTP (sin base de datos): arranca un Nest real con el
// controlador de salud y verifica las respuestas vía supertest. La e2e contra
// la base de datos completa requiere Postgres y el runner ESM de jest.
describe('API ETS ESCOM (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [AppService],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET / responde 200 con el estado de la API', async () => {
    const res = await request(app.getHttpServer()).get('/').expect(200);
    expect(res.body.status).toBe('ok');
    expect(res.body.name).toBe('ETS ESCOM API');
  });

  it('GET /ruta-inexistente responde 404', async () => {
    await request(app.getHttpServer()).get('/ruta-inexistente').expect(404);
  });
});
