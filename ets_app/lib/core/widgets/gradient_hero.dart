import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import 'brand.dart';
import 'hex_motif.dart';

/// Barra de acento de marca: línea fina con gradiente azul → guinda.
/// Va al tope de los headers (público y admin).
class BrandAccentBar extends StatelessWidget {
  const BrandAccentBar({super.key, this.height = 3});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.azul600, AppColors.azul400, AppColors.guinda500],
          stops: [0, 0.55, 1],
        ),
      ),
    );
  }
}

/// GradientHero — el panel oscuro institucional de v2: gradiente azul profundo,
/// resplandor guinda radial, escudo en marca de agua y, opcional, el entramado
/// hexagonal. Es la superficie de héroe reutilizable (consulta, dashboard,
/// PageHero de catálogos/ETS y panel de login).
class GradientHero extends StatelessWidget {
  const GradientHero({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.borderRadius,
    this.showWatermark = true,
    this.showHexMotif = false,
    this.shadow,
    this.tallGradient = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// `null` = esquinas rectas (héroe a sangre, como en el público).
  final BorderRadius? borderRadius;
  final bool showWatermark;
  final bool showHexMotif;
  final List<BoxShadow>? shadow;

  /// Gradiente más profundo (155°, azul-900) usado en el panel de login.
  final bool tallGradient;

  @override
  Widget build(BuildContext context) {
    final gradient = tallGradient
        ? const LinearGradient(
            begin: Alignment(-0.4, -1),
            end: Alignment(0.4, 1),
            colors: [AppColors.azul700, AppColors.azul900, Color(0xFF06283A)],
            stops: [0, 0.58, 1],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.azul700, AppColors.azul800, Color(0xFF06283A)],
            stops: [0, 0.52, 1],
          );

    final content = Stack(
      children: [
        // Resplandor guinda radial (arriba a la derecha).
        Positioned(
          top: -120,
          right: -60,
          child: Container(
            width: 320,
            height: 320,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x807A0E3C), Color(0x007A0E3C)],
                stops: [0, 0.68],
              ),
            ),
          ),
        ),
        if (showHexMotif)
          const Positioned.fill(child: HexMotif(color: Colors.white, opacity: 0.05)),
        // Escudo en marca de agua (abajo a la derecha).
        if (showWatermark)
          Positioned(
            right: -30,
            bottom: -70,
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(BrandAssets.escudoEscomWhite, width: 280),
            ),
          ),
        Padding(padding: padding, child: child),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: shadow,
      ),
      child: borderRadius != null
          ? ClipRRect(borderRadius: borderRadius!, child: content)
          : ClipRect(child: content),
    );
  }
}

/// HeroPill — píldora de cristal sobre el héroe oscuro (stats del público).
class HeroPill extends StatelessWidget {
  const HeroPill({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          // Flexible + ellipsis: si una píldora es más ancha que la línea
          // disponible (móvil angosto), su texto se acorta en vez de desbordar.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: AppType.sans(
                size: 13.5,
                weight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Disco de ícono "de cristal" para los héroes oscuros (52x52).
class HeroIconDisc extends StatelessWidget {
  const HeroIconDisc({super.key, required this.icon, this.size = 52});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: AppRadii.rlg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, size: size * 0.42, color: Colors.white),
    );
  }
}
