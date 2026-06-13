# Arquitectura y Diseño — Sistema para la Gestión de ETS

**Materia:** Desarrollo de Aplicaciones Móviles Nativas
**Escuela:** Escuela Superior de Cómputo (ESCOM) — IPN
**Profesor:** Ing. José Antonio Ortiz Ramírez
**Periodo:** 2026-2

---

## 1. Idea y objetivo del proyecto

Desarrollar una solución móvil nativa que permita a la comunidad estudiantil de ESCOM consultar y gestionar su calendario de **Exámenes a Título de Suficiencia (ETS)**. La aplicación debe:

- Funcionar en entornos de conectividad limitada (**Offline-first**).
- Gestionar estados complejos con un manejador de estado formal (sin abuso de `setState()`).
- Ofrecer una experiencia de usuario de alto nivel con **Material Design 3**.

El sistema se divide en dos módulos funcionales:

| Módulo | Usuario | Funcionalidad |
|---|---|---|
| **Público (Consulta)** | Estudiante | Buscador con filtros (carrera, semestre, materia), tabla de resultados (materia, fecha, turno, salón, profesor) y exportación del calendario (PDF / `.ics`). |
| **Administrativo (Gestión)** | Administrador | Login seguro, dashboard de estadísticas, CRUD completo de la oferta de ETS y gestión de catálogos (carreras y edificios/salones). |

Los requerimientos completos están en el [README](README.md) y en el [documento del proyecto (PDF)](docs/ProyectoFinal_DAMN_20262.pdf).

---

## 2. Arquitectura general

El sistema sigue una arquitectura cliente-servidor de tres capas:

```
┌─────────────────────────────┐         ┌──────────────────────────┐         ┌──────────────┐
│   App Flutter (ets_app)     │  HTTP   │   API REST (NestJS)      │ Prisma  │  PostgreSQL  │
│   Clean Architecture        │ ──────► │   ets_app/ets-backend    │ ──────► │              │
│   Riverpod + go_router      │  JSON   │   JWT + Swagger          │   ORM   │              │
└─────────────────────────────┘         └──────────────────────────┘         └──────────────┘
        │
        ├── Caché local (shared_preferences) → modo offline
        ├── Notificaciones locales (recordatorios de examen)
        └── Geolocalización / mapa de salones
```

### Estructura del repositorio

```
DAMN-ETS-App/
├── README.md                    # Requerimientos del proyecto
├── ARQUITECTURA_Y_DISENO.md     # Este documento
├── docs/
│   └── ProyectoFinal_DAMN_20262.pdf
└── ets_app/                     # Proyecto Flutter (frontend)
    ├── lib/
    │   ├── core/                # Infraestructura transversal
    │   │   ├── network/         # Cliente Dio + excepciones de API
    │   │   ├── router/          # go_router con guardas por sesión y rol
    │   │   ├── storage/         # Persistencia del token JWT
    │   │   ├── notifications/   # Notificaciones locales programadas
    │   │   └── theme/           # Material 3 (claro/oscuro)
    │   └── features/            # Módulos por funcionalidad (Clean Architecture)
    │       ├── auth/            #   data / domain / presentation
    │       ├── ets/             #   data / domain / presentation
    │       ├── admin/           #   data / domain / presentation
    │       └── location/        #   mapa ESCOM y geolocalización
    └── ets-backend/             # API REST (backend)
        ├── prisma/              # Esquema, migraciones y seed de materias
        └── src/
            ├── auth/            # Registro, login, JWT, roles
            ├── ets/             # Consulta pública de ETS
            ├── catalog/         # Catálogos públicos (carreras, edificios, materias)
            ├── admin/           # Dashboard y CRUD protegido (rol ADMIN)
            └── prisma/          # Servicio de acceso a datos
```

---

## 3. Backend (implementado)

### 3.1 Stack

| Componente | Tecnología |
|---|---|
| Framework | NestJS 11 (TypeScript, ESM) |
| ORM | Prisma 7 (adaptador `pg`) |
| Base de datos | PostgreSQL |
| Autenticación | JWT (`@nestjs/jwt` + Passport) con contraseñas hasheadas con **bcrypt** (factor 12) |
| Validación | `class-validator` + `ValidationPipe` global (`whitelist`, `forbidNonWhitelisted`, `transform`) |
| Documentación | Swagger disponible en `/docs` (con soporte Bearer Auth) |
| CORS | Habilitado para consumo desde la app |

### 3.2 Modelo de datos (Prisma)

| Modelo | Campos principales | Relaciones |
|---|---|---|
| `User` | name, email (único), password (hash), boleta (única, opcional), role (`STUDENT` \| `ADMIN`) | — |
| `Career` | code (único), name, plans[] | tiene muchos `Ets` y `Subject` |
| `Building` | name (único) | tiene muchos `Ets` |
| `Subject` | name, plan, semestre | pertenece a `Career` (cascade); única por (carrera, plan, semestre, nombre) |
| `Ets` | ua (materia), plan, semestre, fechaIso, turno, salon, profesor, correo | `Career` (restrict), `Building` (set null), `Subject` (set null) |

Incluye índices sobre los campos de filtrado frecuente (carrera, semestre, fecha, plan) y dos migraciones aplicadas (`init` y `add_subjects`). Existe un **seed de materias** (`npm run seed:subjects`) con los planes de estudio por carrera/semestre.

### 3.3 Endpoints

**Públicos:**

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/auth/register` | Registro de estudiante (409 si correo/boleta duplicados) |
| POST | `/auth/login` | Login; devuelve `accessToken` JWT + datos del usuario |
| GET | `/auth/me` | Usuario autenticado (requiere JWT) |
| GET | `/ets` | Oferta pública de ETS con filtros `carrera`, `plan`, `semestre` y `query` (búsqueda por materia, profesor, salón o carrera) |
| GET | `/catalog/careers` | Catálogo de carreras |
| GET | `/catalog/buildings` | Catálogo de edificios |
| GET | `/catalog/subjects` | Materias filtradas por `careerId`, `plan`, `semestre` |

**Administrativos** (JWT + guard de rol `ADMIN`):

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/admin/dashboard` | Totales (ETS, carreras, edificios, usuarios) y ETS programados por carrera |
| GET / POST | `/admin/ets` | Listado administrativo / alta de ETS |
| PUT / DELETE | `/admin/ets/:id` | Modificación / baja de ETS |
| POST / DELETE | `/admin/catalog/careers(/:id)` | Alta / baja de carreras (409 si tiene ETS asociados) |
| POST / DELETE | `/admin/catalog/buildings(/:id)` | Alta / baja de edificios (409 si tiene ETS asociados) |

### 3.4 Seguridad

- Contraseñas nunca almacenadas en claro (bcrypt, factor de costo 12).
- Tokens JWT firmados con payload mínimo (`sub`, `email`, `role`).
- Rutas administrativas protegidas con doble guard: `JwtAuthGuard` + `RolesGuard` (decorador `@Roles('ADMIN')`).
- Manejo de errores con códigos HTTP semánticos (401, 403, 404, 409, 422).

### 3.5 Cómo ejecutar el backend

```bash
cd ets_app/ets-backend
npm install
# Configurar .env: DATABASE_URL, JWT_SECRET, PORT
npx prisma migrate dev      # aplica migraciones
npm run seed:subjects       # carga el catálogo de materias
npm run start:dev           # API en http://localhost:3000, Swagger en /docs
```

---

## 4. Frontend (avance actual)

> **Nota:** aunque el plan original contemplaba el frontend como trabajo futuro, la carpeta `ets_app` ya incluye un avance considerable de la app Flutter. Se documenta aquí lo que existe para partir de una base real.

### 4.1 Stack y cumplimiento de requerimientos técnicos

| Requerimiento | Estado | Implementación |
|---|---|---|
| Flutter Stable 3.x / Dart | ✅ | SDK `^3.12.0`, `flutter_lints` activo |
| Manejador de estado | ✅ | **Riverpod 3** (`flutter_riverpod`) |
| Clean Architecture | ✅ | Cada feature separada en `data` / `domain` / `presentation` con entidades, repositorios, casos de uso y datasources |
| Consumo de API REST | ✅ | **Dio** con cliente centralizado y excepciones tipadas (`api_exceptions.dart`) |
| Modelos con `fromJSON` | ✅ | Modelos de datos por feature (`ets_model`, `career_model`, etc.) |
| Caché local (offline) | ✅ | `shared_preferences`: caché del listado de ETS con marca de última actualización + favoritos |
| Notificaciones locales | ✅ | `flutter_local_notifications` + `timezone` (canal Android de recordatorios de examen) |
| Interoperabilidad | ✅ | `url_launcher` + `geolocator`: pantalla de ubicación de ESCOM y mapa SVG interno de salones |
| Material Design 3 | ✅ | `ColorScheme.fromSeed` + `useMaterial3`, tema claro/oscuro según sistema |
| Navegación | ✅ | `go_router` con redirects por estado de sesión y rol (rutas `/admin` bloqueadas a no-administradores) |
| Exportación `.ics` | ✅ | Generación de iCalendar multiplataforma (IO / Web) con `share_plus` |
| Exportación PDF | ⬜ | Paquetes `pdf` y `printing` ya declarados en `pubspec.yaml`, **sin uso todavía** |

### 4.2 Pantallas existentes

- **Auth:** login y registro, con persistencia de sesión (token en `shared_preferences`) y restauración automática al abrir la app.
- **Estudiante:** home de búsqueda de ETS con filtros, detalle de examen, favoritos con recordatorios, exportación `.ics`, mapa de salón y ubicación de ESCOM.
- **Admin:** dashboard con estadísticas del backend, CRUD de ETS y gestión de catálogos (carreras/edificios).

### 4.3 Cómo ejecutar la app

```bash
cd ets_app
flutter pub get
flutter run    # requiere el backend corriendo (ver §3.5)
```

---

## 5. Lo que falta (roadmap)

### Frontend

1. **Exportación a PDF** del calendario seleccionado (requerimiento base; `.ics` ya cubre los puntos extra). Los paquetes `pdf`/`printing` ya están declarados.
2. **Pulido de UX**: revisión fina de manejo de errores de red (Timeout, 404, 500) con Snackbars/diálogos en todos los flujos, estados de carga y vacío.
3. **Pruebas de widgets/unitarias**: solo existe el `widget_test.dart` por defecto.
4. **Revisión de lint**: garantizar cero warnings de `flutter_lints` (criterio de calificación).

### Backend

1. **Edición (PUT) de catálogos**: carreras y edificios solo tienen alta y baja; falta modificación.
2. **CRUD administrativo de materias (`Subject`)**: hoy solo se cargan por seed y se consultan públicamente.
3. **Pruebas**: solo existen los specs por defecto de NestJS; faltan pruebas unitarias y e2e reales.
4. **Documentar variables de entorno** (`.env.example` con `DATABASE_URL`, `JWT_SECRET`, `PORT`).
5. **Despliegue**: definir hosting de la API y la base de datos para la demo (actualmente solo local).

### Integración

1. Configurar la URL base de la API por entorno (dev/producción) en la app.
2. Flujo de expiración de sesión (manejo de 401 → re-login).
3. Verificación end-to-end de ambos módulos contra el backend desplegado.

---

## 6. Decisiones de diseño relevantes

- **Riverpod como manejador de estado e inyección de dependencias**: cubre tanto el requerimiento de gestión de estado como el desacoplamiento de servicios que el documento sugiere resolver con `get_it` (los providers actúan como contenedor de DI).
- **`shared_preferences` para caché offline**: suficiente para el volumen de datos (listados de ETS serializados a JSON); evita la complejidad de `sqflite`. La caché guarda la fecha de última actualización para informar al usuario en modo offline.
- **Fechas como `fechaIso` (string ISO) en el backend**: simplifica el filtrado/ordenado y la serialización hacia la app, que las parsea a `DateTime` localmente.
- **`Subject` como catálogo separado de `Ets`**: la oferta de ETS captura la materia como texto (`ua`) con referencia opcional al catálogo, lo que permite registrar exámenes aunque la materia no esté en el seed.
- **Borrado protegido en catálogos** (`onDelete: Restrict` en carrera, 409 en API): impide eliminar carreras/edificios con exámenes registrados y mantiene integridad referencial.
