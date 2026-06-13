import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// HexMotif — el único florituría de marca: un sutil entramado hexagonal de
/// líneas (eco del Escudo ESCOM) a muy baja opacidad, para superficies de héroe
/// y login. Superficies grandes permanecen tranquilas; nunca imagen a sangre.
class HexMotif extends StatelessWidget {
  const HexMotif({
    super.key,
    this.color = AppColors.primary,
    this.opacity = 0.05,
    this.cell = 64,
  });

  final Color color;
  final double opacity;
  final double cell;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _HexPainter(
          color: color.withValues(alpha: opacity),
          cell: cell,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  _HexPainter({required this.color, required this.cell});

  final Color color;
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;

    final r = cell / 2;
    final hexWidth = math.sqrt(3) * r;
    final vert = 1.5 * r;

    for (double row = -vert, y = -vert; y < size.height + cell; row++, y += vert) {
      final xOffset = (row.toInt().isOdd) ? hexWidth / 2 : 0.0;
      for (double x = -hexWidth + xOffset;
          x < size.width + hexWidth;
          x += hexWidth) {
        _drawHexagon(canvas, Offset(x, y), r, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 180) * (60 * i - 90);
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HexPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.cell != cell;
}
