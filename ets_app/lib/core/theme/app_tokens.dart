import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ETS ESCOM — Espaciado, radios, elevación y movimiento.
/// Cuadrícula base de 4px. Mesura académica: bordes reales (hairline),
/// elevación suave de tinte frío y movimiento tranquilo.
class AppSpacing {
  AppSpacing._();

  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
  static const double s20 = 80;

  /// Anchos de layout
  static const double container = 1100;
  static const double containerNarrow = 760;
}

/// Radios de esquina — moderados, profesionales (no "pill-y").
class AppRadii {
  AppRadii._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 22;
  static const double full = 999;

  static const BorderRadius rxs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius rsm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rmd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius rlg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius rxl = BorderRadius.all(Radius.circular(xl));
}

/// Elevación — fría, de baja dispersión, contenida.
/// Nunca sombras negras duras: `rgba(12,56,81,...)`.
class AppShadows {
  AppShadows._();

  static const Color _tint = Color(0xFF0C3851);

  static List<BoxShadow> get xs => [
        BoxShadow(
          color: _tint.withValues(alpha: 0.06),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: _tint.withValues(alpha: 0.08),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: _tint.withValues(alpha: 0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: _tint.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: _tint.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: _tint.withValues(alpha: 0.12),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: _tint.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  /// Resplandor azul para el CTA principal.
  static List<BoxShadow> get primary => [
        BoxShadow(
          color: AppColors.azul600.withValues(alpha: 0.28),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];
}

/// Movimiento — rápido y tranquilo.
class AppMotion {
  AppMotion._();

  static const Curve easeOut = Cubic(0.22, 1, 0.36, 1);
  static const Curve easeInOut = Cubic(0.65, 0, 0.35, 1);
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
}
