import 'package:ets_app/core/theme/app_theme.dart';
import 'package:ets_app/core/widgets/ds_widgets.dart';
import 'package:ets_app/features/ets/domain/entities/ets.dart';
import 'package:ets_app/features/ets/presentation/ets_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Anchos lógicos de móviles a verificar (desde un iPhone SE pequeño hasta
/// un phablet). Un RenderFlex que se desborde lanza una excepción de layout
/// que recuperamos con `tester.takeException()`.
const _mobileSizes = <Size>[
  Size(320, 640), // pequeño (iPhone SE 1ª gen)
  Size(360, 720), // Android común
  Size(390, 844), // iPhone 14
  Size(414, 896), // phablet
];

Future<void> _pumpAt(WidgetTester tester, Size size, Widget child) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
  // pump fijo (no pumpAndSettle) para no esperar indicadores animados.
  await tester.pump(const Duration(milliseconds: 400));
}

Ets _sampleEts() => const Ets(
      id: 1,
      ua: 'Análisis y Diseño de Algoritmos Avanzados',
      carrera: 'ISC',
      carreraNombre: 'Ingeniería en Sistemas Computacionales',
      careerId: 1,
      plan: '2020',
      semestre: 6,
      fechaIso: '2026-06-22T14:30:00.000Z',
      turno: 'Vespertino',
      salon: '2204',
      profesor: 'Dra. María Fernanda González Hernández',
      correo: 'profesor.evaluador@escom.ipn.mx',
      edificio: 'Edificio 2',
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_MX', null);
  });

  group('EtsDetailScreen sin overflow en móvil', () {
    for (final size in _mobileSizes) {
      testWidgets('${size.width.toInt()}px', (tester) async {
        await _pumpAt(tester, size, EtsDetailScreen(ets: _sampleEts()));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Dashboard StatTiles (Wrap responsive) sin overflow', () {
    // Replica exacta de la lógica del dashboard: columnas según ancho y
    // ancho de celda calculado para que la altura del StatTile sea intrínseca.
    Widget statGrid() {
      return Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1050
                  ? 4
                  : width >= 560
                      ? 2
                      : 1;
              const gap = 14.0;
              final itemWidth =
                  ((width - gap * (columns - 1)) / columns).floorToDouble();

              const tiles = <Widget>[
                StatTile(
                  value: '3',
                  label: 'ETS registrados',
                  icon: Icons.event_available_outlined,
                ),
                StatTile(
                  value: '3',
                  label: 'Carreras',
                  icon: Icons.school_outlined,
                  tone: StatTone.guinda,
                ),
                StatTile(
                  value: '3',
                  label: 'Edificios',
                  icon: Icons.apartment_outlined,
                  tone: StatTone.neutral,
                ),
                StatTile(
                  value: '1',
                  label: 'Usuarios',
                  icon: Icons.people_outline,
                  tone: StatTone.success,
                ),
              ];

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final tile in tiles)
                    SizedBox(width: itemWidth, child: tile),
                ],
              );
            },
          ),
        ),
      );
    }

    for (final size in _mobileSizes) {
      testWidgets('${size.width.toInt()}px', (tester) async {
        await _pumpAt(tester, size, statGrid());
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Componentes DS sin overflow en ancho mínimo (300px)', () {
    testWidgets('PanelHeader con título y descripción largos', (tester) async {
      await _pumpAt(
        tester,
        const Size(300, 640),
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: PanelHeader(
              icon: Icons.school_outlined,
              title: 'Ingeniería en Inteligencia Artificial',
              description:
                  'Gestiona las carreras y los planes de estudio registrados.',
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.refresh),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('CareerBadge + DsBadge en Wrap', (tester) async {
      await _pumpAt(
        tester,
        const Size(300, 640),
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CareerBadge(code: 'ISC'),
                DsBadge(
                  label: 'Vespertino',
                  tone: BadgeTone.info,
                  icon: Icons.nights_stay_outlined,
                ),
                DsBadge(label: 'Plan 2020'),
                DsBadge(label: '6° semestre'),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('BrandLockup en AppBar muy angosto no desborda', (tester) async {
      // Simula el espacio de título del AppBar comprimido por las acciones.
      await _pumpAt(
        tester,
        const Size(320, 640),
        Scaffold(
          appBar: AppBar(
            title: const BrandLockup(subtitle: 'Calendario de exámenes'),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.star)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.logout)),
            ],
          ),
          body: const SizedBox.shrink(),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
