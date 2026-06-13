import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Variantes visuales del [CareerBadge].
enum CareerBadgeVariant { soft, solid, guinda }

/// CareerBadge — el chip circular recurrente con el código de carrera
/// (IIA / ISC / LCD) en tipografía mono. Dispositivo iconográfico de la marca.
class CareerBadge extends StatelessWidget {
  const CareerBadge({
    super.key,
    required this.code,
    this.size = 44,
    this.variant = CareerBadgeVariant.soft,
  });

  final String code;
  final double size;
  final CareerBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, borderColor) = switch (variant) {
      CareerBadgeVariant.soft => (
          AppColors.primarySoft,
          AppColors.azul700,
          AppColors.azul200,
        ),
      CareerBadgeVariant.solid => (
          AppColors.primary,
          AppColors.white,
          Colors.transparent,
        ),
      CareerBadgeVariant.guinda => (
          AppColors.guinda50,
          AppColors.guinda600,
          AppColors.guinda200,
        ),
    };

    final fontSize = (size * 0.3).clamp(11, 20).toDouble();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Text(
        code,
        style: AppType.mono(
          size: fontSize,
          weight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
