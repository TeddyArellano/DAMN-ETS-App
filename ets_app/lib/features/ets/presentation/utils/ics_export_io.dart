import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/ets.dart';
import 'ics_helpers.dart';

Future<void> exportEtsToCalendar(Ets exam) async {
  final content = buildIcsContent(exam);
  final fileName = buildIcsFileName(exam.ua);

  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$fileName');

  await file.writeAsString(content, flush: true);

  await SharePlus.instance.share(
    ShareParams(
      subject: 'ETS - ${exam.ua}',
      text: 'Calendario del ETS: ${exam.ua}',
      files: [
        XFile(
          file.path,
          mimeType: 'text/calendar',
          name: fileName,
        ),
      ],
    ),
  );
}