import '../../domain/entities/ets.dart';

String buildIcsContent(Ets exam) {
  final start = exam.fecha.toUtc();
  final end = start.add(const Duration(hours: 2));
  final created = DateTime.now().toUtc();

  final title = escapeIcsText('ETS - ${exam.ua}');
  final location = escapeIcsText(
    '${exam.salon} - ${exam.edificio ?? 'Edificio no asignado'}',
  );

  final description = escapeIcsText(
    'Carrera: ${exam.carrera}\n'
    'Plan: ${exam.plan}\n'
    'Semestre: ${exam.semestre}\n'
    'Turno: ${exam.turno}\n'
    'Profesor evaluador: ${exam.profesor}\n'
    'Correo: ${exam.correo}',
  );

  return '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//ETS ESCOM//Flutter App//ES
CALSCALE:GREGORIAN
METHOD:PUBLISH
BEGIN:VEVENT
UID:ets-${exam.id}-${start.millisecondsSinceEpoch}@ets-escom
DTSTAMP:${formatIcsDate(created)}
DTSTART:${formatIcsDate(start)}
DTEND:${formatIcsDate(end)}
SUMMARY:$title
DESCRIPTION:$description
LOCATION:$location
END:VEVENT
END:VCALENDAR
''';
}

String formatIcsDate(DateTime date) {
  final utc = date.toUtc();

  String two(int value) => value.toString().padLeft(2, '0');

  return '${utc.year}'
      '${two(utc.month)}'
      '${two(utc.day)}'
      'T'
      '${two(utc.hour)}'
      '${two(utc.minute)}'
      '${two(utc.second)}'
      'Z';
}

String escapeIcsText(String value) {
  return value
      .replaceAll('\\', '\\\\')
      .replaceAll('\n', '\\n')
      .replaceAll(',', '\\,')
      .replaceAll(';', '\\;');
}

String buildIcsFileName(String ua) {
  final normalized = ua
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâ]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöô]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  return 'ets_$normalized.ics';
}