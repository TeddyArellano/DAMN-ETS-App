import 'package:web/web.dart' as web;

import '../../domain/entities/ets.dart';
import 'ics_helpers.dart';

Future<void> exportEtsToCalendar(Ets exam) async {
  final content = buildIcsContent(exam);
  final fileName = buildIcsFileName(exam.ua);

  final encodedContent = Uri.encodeComponent(content);

  final anchor = web.HTMLAnchorElement()
    ..href = 'data:text/calendar;charset=utf-8,$encodedContent'
    ..download = fileName
    ..style.display = 'none';

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}