# DAMN-ETS-App

## Sistema para la Gestión de ETS — Proyecto Final 2026-2

**Materia:** Desarrollo de Aplicaciones Móviles Nativas  
**Escuela:** Escuela Superior de Cómputo (ESCOM) — IPN  
**Profesor:** Ing. José Antonio Ortiz Ramírez

---

## 1. Objetivo del Proyecto

Desarrollar una solución móvil nativa que permita a la comunidad estudiantil de ESCOM gestionar su calendario de **Exámenes a Título de Suficiencia (ETS)**. La aplicación deberá ser capaz de funcionar en entornos de conectividad limitada (**Offline-first**), gestionar estados complejos y ofrecer una experiencia de usuario (UX) de alto nivel mediante **Material Design 3**.

---

## 2. Descripción de Requerimientos

### A. Módulo Público (Consulta)

1. **Buscador Inteligente:** Filtros por Carrera, Semestre y Unidad de Aprendizaje (Materia).
2. **Visualización Dinámica:** Tabla de resultados que muestre: Materia, Fecha, Turno, Salón y Profesor evaluador.
3. **Exportación:** Botón para generar el calendario seleccionado en formato PDF o, para los puntos extra, formato `.ics` (iCalendar).

### B. Módulo Administrativo (Gestión)

1. **Autenticación:** Login seguro con contraseñas encriptadas.
2. **Panel de Control (Dashboard):** Visualización de estadísticas rápidas (ej. cuántos exámenes hay programados por carrera).
3. **CRUD Completo:** Altas, Bajas, Cambios y Consultas de la oferta de exámenes.
4. **Gestión de Catálogos:** Administración de Carreras y Edificios/Salones.

---

## 3. Requerimientos Técnicos

### A. Tecnología

- **Lenguaje:** Dart
- **Framework:** Flutter

### B. Arquitectura y Gestión de Estado

- Se prohíbe el uso excesivo de `setState()` para lógicas de negocio.
- **Manejador de Estado obligatorio:** Provider, Riverpod o BLoC.
- **Clean Architecture:** Separación clara entre:
  - Capa de Datos (Data)
  - Capa de Dominio (Business Logic)
  - Capa de Presentación (UI)

### C. Consumo de Servicios (API REST)

- La aplicación deberá consumir los endpoints de un backend.
- Implementación de **Modelos de Datos** robustos con serialización de JSON (`fromJSON`).
- Manejo profesional de errores de red (Timeout, 404, 500) mediante Snackbars o diálogos informativos.

### D. Persistencia y Capacidades Nativas

- **Caché Local:** Uso de `sqflite` o `shared_preferences` para almacenar los exámenes favoritos/guardados.
- **Notificaciones:** Programación de alertas locales para recordar al usuario la fecha de su examen.
- **Interoperabilidad:** Uso de `url_launcher` para geolocalización de salones o contacto con soporte.

---

## 4. Indicaciones Adicionales

1. **Versionado de Flutter:** Compatible con la versión **Stable 3.x** de Flutter.
2. **Linting:** Obligatorio el uso de `flutter_lints`. Código con warnings de análisis estático perderá puntos de profesionalismo.
3. **Assets:** Todas las imágenes y fuentes deben estar declaradas correctamente en el `pubspec.yaml`. No se permiten rutas hardcoded.
4. **Inyección de Dependencias:** Se valorará positivamente el uso de `get_it` o similares para desacoplar servicios.

---

## Documentación

- [Documento del Proyecto (PDF)](docs/ProyectoFinal_DAMN_20262.pdf)
