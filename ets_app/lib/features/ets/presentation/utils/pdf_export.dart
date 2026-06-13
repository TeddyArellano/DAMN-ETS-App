import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/ets.dart';

/// Generación y exportación del calendario de ETS en **PDF**.
///
/// Cumple el requerimiento base de "generar el calendario seleccionado en
/// formato PDF". El documento usa la identidad ETS ESCOM (azul institucional,
/// escudo) y una tabla con Materia, Fecha, Turno, Salón y Profesor evaluador.

// Paleta institucional (espejo de AppColors, en PdfColor).
const _azul = PdfColor.fromInt(0xFF00679A);
const _azulSoft = PdfColor.fromInt(0xFFEEF6FB);
const _guinda = PdfColor.fromInt(0xFF7A0E3C);
const _slate900 = PdfColor.fromInt(0xFF111A26);
const _slate600 = PdfColor.fromInt(0xFF495669);
const _slate200 = PdfColor.fromInt(0xFFE1E7EE);

/// Construye los bytes del PDF del calendario. Función **pura y testeable**
/// (no toca UI ni el sistema de impresión).
Future<Uint8List> buildEtsCalendarPdf(
  List<Ets> items, {
  String title = 'Calendario de ETS',
  String subtitle = 'Exámenes a Título de Suficiencia',
  DateTime? generatedAt,
}) async {
  final doc = pw.Document(
    title: title,
    author: 'ETS ESCOM',
    creator: 'ETS ESCOM',
  );

  final dateFmt = DateFormat('dd/MM/yyyy');
  final timeFmt = DateFormat('HH:mm');
  final stamp = generatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  // Escudo ESCOM (opcional: si falla la carga, el PDF se genera igual).
  pw.MemoryImage? crest;
  try {
    final data = await rootBundle.load('assets/logos/escudo-escom.png');
    crest = pw.MemoryImage(data.buffer.asUint8List());
  } catch (_) {
    crest = null;
  }

  final sorted = [...items]..sort((a, b) {
      try {
        return a.fecha.compareTo(b.fecha);
      } catch (_) {
        return 0;
      }
    });

  final headers = ['Materia', 'Carrera · Plan', 'Fecha', 'Turno', 'Salón', 'Profesor'];

  final rows = sorted.map((e) {
    String fecha;
    String hora;
    try {
      final d = e.fecha.toLocal();
      fecha = dateFmt.format(d);
      hora = timeFmt.format(d);
    } catch (_) {
      fecha = e.fechaIso;
      hora = '';
    }
    return [
      e.ua,
      '${e.carrera} · ${e.plan} · ${e.semestre}°',
      hora.isEmpty ? fecha : '$fecha\n$hora h',
      e.turno,
      '${e.salon}\n${e.edificio ?? ''}'.trim(),
      e.profesor,
    ];
  }).toList();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 36),
      header: (context) => context.pageNumber == 1
          ? _buildHeader(title, subtitle, stamp, items.length, crest, dateFmt, timeFmt)
          : pw.SizedBox(),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          'ESCOM · IPN · Página ${context.pageNumber} de ${context.pagesCount}',
          style: pw.TextStyle(fontSize: 9, color: _slate600),
        ),
      ),
      build: (context) => [
        if (rows.isEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 24),
            child: pw.Text(
              'No hay ETS para exportar.',
              style: pw.TextStyle(fontSize: 12, color: _slate600),
            ),
          )
        else
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            border: pw.TableBorder.all(color: _slate200, width: 0.5),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: _azul),
            headerHeight: 26,
            cellStyle: const pw.TextStyle(fontSize: 9, color: _slate900),
            cellHeight: 30,
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _slate200, width: 0.5)),
            ),
            oddRowDecoration: const pw.BoxDecoration(color: _azulSoft),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.center,
              4: pw.Alignment.centerLeft,
              5: pw.Alignment.centerLeft,
            },
            columnWidths: {
              0: const pw.FlexColumnWidth(2.6),
              1: const pw.FlexColumnWidth(2.0),
              2: const pw.FlexColumnWidth(1.4),
              3: const pw.FlexColumnWidth(1.2),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FlexColumnWidth(2.4),
            },
          ),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _buildHeader(
  String title,
  String subtitle,
  DateTime stamp,
  int count,
  pw.MemoryImage? crest,
  DateFormat dateFmt,
  DateFormat timeFmt,
) {
  final stampText = stamp.millisecondsSinceEpoch == 0
      ? ''
      : 'Generado el ${dateFmt.format(stamp)} ${timeFmt.format(stamp)}';

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 16),
    padding: const pw.EdgeInsets.only(bottom: 12),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _azul, width: 2)),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (crest != null) ...[
          pw.Image(crest, height: 44, width: 44),
          pw.SizedBox(width: 14),
        ],
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                subtitle.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 8,
                  color: _azul,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 20,
                  color: _slate900,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'ESCOM · Instituto Politécnico Nacional',
                style: pw.TextStyle(fontSize: 9, color: _slate600),
              ),
            ],
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: pw.BoxDecoration(
                color: _guinda,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Text(
                '$count ETS',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            if (stampText.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(stampText, style: pw.TextStyle(fontSize: 8, color: _slate600)),
            ],
          ],
        ),
      ],
    ),
  );
}

/// Genera y comparte/descarga el PDF (diálogo nativo en móvil, descarga en web).
Future<void> exportEtsCalendarToPdf(
  List<Ets> items, {
  String title = 'Calendario de ETS',
  String filename = 'calendario_ets.pdf',
}) async {
  final bytes = await buildEtsCalendarPdf(
    items,
    title: title,
    generatedAt: DateTime.now(),
  );

  await Printing.sharePdf(bytes: bytes, filename: filename);
}
