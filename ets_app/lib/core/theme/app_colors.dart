import 'package:flutter/material.dart';

/// ETS ESCOM — Sistema de color.
///
/// Anclas de marca: **Azul ESCOM** (`#00679A`) y **Guinda IPN** (`#7A0E3C`),
/// muestreadas de los escudos oficiales. Identidad clara, académica y minimalista:
/// el azul lidera; el guinda es un acento institucional usado con mesura.
/// Los neutros son slate (grises con tinte azul) para vivir en la misma familia.
class AppColors {
  AppColors._();

  // ---- Azul ESCOM (rampa primaria) ----
  static const azul50 = Color(0xFFEEF6FB);
  static const azul100 = Color(0xFFD7EAF4);
  static const azul200 = Color(0xFFAED6E9);
  static const azul300 = Color(0xFF79BADD);
  static const azul400 = Color(0xFF3F97C4);
  static const azul500 = Color(0xFF1179A8);
  static const azul600 = Color(0xFF00679A); // azul ESCOM base
  static const azul700 = Color(0xFF015681);
  static const azul800 = Color(0xFF094668);
  static const azul900 = Color(0xFF0C3851);
  static const azul950 = Color(0xFF082434);

  // ---- Guinda IPN (rampa de acento institucional) ----
  static const guinda50 = Color(0xFFFBEDF2);
  static const guinda100 = Color(0xFFF6D6E1);
  static const guinda200 = Color(0xFFECADC1);
  static const guinda300 = Color(0xFFDB7799);
  static const guinda400 = Color(0xFFC44470);
  static const guinda500 = Color(0xFFA31A50);
  static const guinda600 = Color(0xFF7A0E3C); // guinda IPN base
  static const guinda700 = Color(0xFF640A31);
  static const guinda900 = Color(0xFF3F0620);

  // ---- Slate (neutros fríos, armonizados al azul) ----
  static const slate50 = Color(0xFFF6F8FB);
  static const slate100 = Color(0xFFEEF2F6);
  static const slate200 = Color(0xFFE1E7EE);
  static const slate300 = Color(0xFFC9D3DD);
  static const slate400 = Color(0xFF93A2B3);
  static const slate500 = Color(0xFF647387);
  static const slate600 = Color(0xFF495669);
  static const slate700 = Color(0xFF344050);
  static const slate800 = Color(0xFF1F2937);
  static const slate900 = Color(0xFF111A26);
  static const white = Color(0xFFFFFFFF);

  // ---- Semánticos de estado ----
  static const green600 = Color(0xFF15803D);
  static const green50 = Color(0xFFE9F6EE);
  static const amber600 = Color(0xFFB45309);
  static const amber50 = Color(0xFFFDF3E3);
  static const red600 = Color(0xFFC0322B);
  static const red50 = Color(0xFFFBECEB);

  // =========================================================
  // ALIASES SEMÁNTICOS — usar estos en los componentes
  // =========================================================
  static const primary = azul600;
  static const primaryHover = azul700;
  static const primaryPress = azul800;
  static const primarySoft = azul50;
  static const primarySoft2 = azul100;
  static const onPrimary = white;

  static const accent = guinda600;
  static const accentHover = guinda700;
  static const accentSoft = guinda50;
  static const onAccent = white;

  static const bgPage = Color(0xFFF4F7FA);
  static const bgPageTint = Color(0xFFEEF3F8);
  static const surface = white;
  static const surfaceMuted = slate50;
  static const surfaceSunken = slate100;

  static const borderSubtle = slate200;
  static const border = slate300;
  static const borderStrong = slate400;

  static const textStrong = slate900;
  static const textBody = slate700;
  static const textMuted = slate500;
  static const textFaint = slate400;
  static const textOnDark = Color(0xFFEAF2F8);
  static const textLink = azul600;

  /// Anillo de foco azul al ~38% de opacidad.
  static const focusRing = Color(0x6100679A);

  static const success = green600;
  static const successSoft = green50;
  static const warning = amber600;
  static const warningSoft = amber50;
  static const danger = red600;
  static const dangerSoft = red50;
}
