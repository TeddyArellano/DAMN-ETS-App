import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// ETS ESCOM — Tema Material.
///
/// Identidad clara, académica e institucional, liderada por el **Azul ESCOM**.
/// El diseño abandona por completo el Material 3 oscuro genérico: cartas blancas
/// tipo papel sobre una página con leve tinte azul, bordes hairline reales,
/// tipografía Public Sans / Source Serif 4 y mesura en color y movimiento.
class AppTheme {
  AppTheme._();

  static const ColorScheme _scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primarySoft,
    onPrimaryContainer: AppColors.azul700,
    secondary: AppColors.accent,
    onSecondary: AppColors.onAccent,
    secondaryContainer: AppColors.accentSoft,
    onSecondaryContainer: AppColors.guinda700,
    tertiary: AppColors.azul500,
    onTertiary: AppColors.white,
    error: AppColors.danger,
    onError: AppColors.white,
    errorContainer: AppColors.dangerSoft,
    onErrorContainer: AppColors.red600,
    surface: AppColors.surface,
    onSurface: AppColors.textStrong,
    onSurfaceVariant: AppColors.textMuted,
    surfaceContainerLowest: AppColors.white,
    surfaceContainerLow: AppColors.surfaceMuted,
    surfaceContainer: AppColors.surfaceMuted,
    surfaceContainerHigh: AppColors.surfaceSunken,
    surfaceContainerHighest: AppColors.surfaceSunken,
    outline: AppColors.border,
    outlineVariant: AppColors.borderSubtle,
    shadow: Color(0xFF0C3851),
    scrim: Color(0x73111A26),
    inverseSurface: AppColors.slate900,
    onInverseSurface: AppColors.textOnDark,
    inversePrimary: AppColors.azul200,
  );

  static ThemeData get lightTheme {
    final textTheme = AppType.textTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: _scheme,
      scaffoldBackgroundColor: AppColors.bgPage,
      textTheme: textTheme,
      primaryColor: AppColors.primary,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textStrong,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.slate900.withValues(alpha: 0.08),
        centerTitle: false,
        titleTextStyle: AppType.serif(size: 20, weight: FontWeight.w700),
        iconTheme: const IconThemeData(color: AppColors.textMuted, size: 22),
      ),

      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.slate900.withValues(alpha: 0.10),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rlg,
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.slate200,
          disabledForegroundColor: AppColors.slate400,
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          elevation: 0,
          textStyle: AppType.sans(
            size: 15,
            weight: FontWeight.w600,
            letterSpacing: -0.15,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.rmd),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryPress;
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primaryHover;
            }
            return null;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: AppColors.border),
          textStyle: AppType.sans(
            size: 15,
            weight: FontWeight.w600,
            letterSpacing: -0.15,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.rmd),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: AppType.sans(size: 14, weight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.rsm),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textMuted,
          highlightColor: AppColors.primarySoft,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: AppType.sans(size: 15, color: AppColors.textFaint),
        labelStyle: AppType.sans(size: 15, color: AppColors.textMuted),
        floatingLabelStyle: AppType.sans(
          size: 13,
          weight: FontWeight.w600,
          color: AppColors.primary,
        ),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        border: OutlineInputBorder(
          borderRadius: AppRadii.rmd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.rmd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.rmd,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.rmd,
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.rmd,
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.rmd,
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSunken,
        side: BorderSide.none,
        labelStyle: AppType.sans(
          size: 12,
          weight: FontWeight.w600,
          color: AppColors.slate700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: const StadiumBorder(),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.borderSubtle,
        labelStyle: AppType.sans(size: 13, weight: FontWeight.w700),
        unselectedLabelStyle: AppType.sans(size: 13, weight: FontWeight.w500),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.slate900,
        contentTextStyle: AppType.sans(size: 14, color: AppColors.textOnDark),
        actionTextColor: AppColors.azul200,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.rmd),
        insetPadding: const EdgeInsets.all(16),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.rlg),
        titleTextStyle: AppType.serif(size: 22, weight: FontWeight.w700),
        contentTextStyle: AppType.sans(size: 15, color: AppColors.textBody),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        dragHandleColor: AppColors.slate300,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceSunken,
        circularTrackColor: AppColors.surfaceSunken,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rmd,
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        textStyle: AppType.sans(size: 14, color: AppColors.textBody),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textMuted,
        textColor: AppColors.textBody,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.white),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
    );
  }
}
