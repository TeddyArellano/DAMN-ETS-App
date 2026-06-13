import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// ETS ESCOM — Tipografía.
///
/// - **Public Sans** para todo lo funcional y de cuerpo (herencia de los
///   design systems de gobierno: neutra, precisa, "oficial").
/// - **Source Serif 4** para momentos display: títulos de pantalla, el héroe
///   del login, numerales de estadísticas. Da gravedad académica, con mesura.
/// - **IBM Plex Mono** para códigos, salones, fechas e identificadores.
class AppType {
  AppType._();

  /// Sans (Public Sans) — UI y cuerpo.
  static TextStyle sans({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textBody,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.publicSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Serif (Source Serif 4) — momentos display.
  static TextStyle serif({
    double size = 28,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.textStrong,
    double? height,
    double letterSpacing = -0.4,
  }) {
    return GoogleFonts.sourceSerif4(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Mono (IBM Plex Mono) — códigos, salones, fechas.
  static TextStyle mono({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.textBody,
    double? height,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  /// Eyebrow / label: 12px, mayúsculas, tracking +0.08em, en azul.
  static TextStyle eyebrow({Color color = AppColors.primary}) {
    return GoogleFonts.publicSans(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 12 * 0.08,
      height: 1.2,
    );
  }

  /// TextTheme base de Material, derivado de Public Sans.
  static TextTheme textTheme(TextTheme base) {
    return GoogleFonts.publicSansTextTheme(base).apply(
      bodyColor: AppColors.textBody,
      displayColor: AppColors.textStrong,
    );
  }
}
