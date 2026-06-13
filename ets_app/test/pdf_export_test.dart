import 'package:ets_app/features/ets/domain/entities/ets.dart';
import 'package:ets_app/features/ets/presentation/utils/pdf_export.dart';
import 'package:flutter_test/flutter_test.dart';

Ets _ets(int id, String ua) => Ets(
      id: id,
      ua: ua,
      carrera: 'ISC',
      carreraNombre: 'Ingeniería en Sistemas Computacionales',
      careerId: 1,
      plan: '2020',
      semestre: 6,
      fechaIso: '2026-06-22T14:30:00.000Z',
      turno: 'Vespertino',
      salon: '2204',
      profesor: 'Dra. María Fernanda González',
      correo: 'profe@escom.ipn.mx',
      edificio: 'Edificio 2',
    );

void main() {
  // El builder carga el escudo vía rootBundle; aseguramos binding inicializado.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buildEtsCalendarPdf genera un PDF válido y no vacío', () async {
    final bytes = await buildEtsCalendarPdf(
      [_ets(1, 'Análisis de Algoritmos'), _ets(2, 'Bases de Datos')],
      title: 'Calendario de ETS',
      generatedAt: DateTime(2026, 6, 13, 10, 30),
    );

    expect(bytes.isNotEmpty, isTrue);
    // Cabecera de un archivo PDF: "%PDF"
    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('buildEtsCalendarPdf no falla con lista vacía', () async {
    final bytes = await buildEtsCalendarPdf(const []);
    expect(bytes.isNotEmpty, isTrue);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('buildEtsCalendarPdf maneja muchos ETS (varias páginas)', () async {
    final many = [for (var i = 0; i < 40; i++) _ets(i, 'Materia $i')];
    final bytes = await buildEtsCalendarPdf(many);
    expect(bytes.isNotEmpty, isTrue);
  });
}
