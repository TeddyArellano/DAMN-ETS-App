import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

/// Rutas de los escudos institucionales.
class BrandAssets {
  BrandAssets._();
  static const escudoEscom = 'assets/logos/escudo-escom.png';
  static const escudoEscomWhite = 'assets/logos/escudo-escom-white.png';
  static const ipnLogo = 'assets/logos/ipn-logo.png';
  static const ipnLogoWhite = 'assets/logos/ipn-logo-white.png';
}

/// FieldLabel — caption por encima de un input (estilo académico, no flotante).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: AppType.sans(
            size: 14,
            weight: FontWeight.w600,
            color: AppColors.textBody,
          ),
        ),
      ),
    );
  }
}

/// Eyebrow — etiqueta superior en mayúsculas, tracking abierto, en azul.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = AppColors.primary});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppType.eyebrow(color: color));
  }
}

/// BrandLockup — escudo ESCOM + wordmark serif "ETS ESCOM" con subtítulo.
class BrandLockup extends StatelessWidget {
  const BrandLockup({
    super.key,
    this.subtitle = 'Calendario de exámenes',
    this.crestSize = 38,
    this.titleSize = 19,
    this.onDark = false,
  });

  final String subtitle;
  final double crestSize;
  final double titleSize;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          onDark ? BrandAssets.escudoEscomWhite : BrandAssets.escudoEscom,
          height: crestSize,
        ),
        const SizedBox(width: 12),
        // Flexible + ellipsis: el wordmark se encoge en pantallas angostas
        // en vez de desbordar el AppBar.
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ETS ESCOM',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.serif(
                  size: titleSize,
                  weight: FontWeight.w700,
                  color: onDark ? AppColors.white : AppColors.textStrong,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.sans(
                  size: 11,
                  color: onDark ? AppColors.azul200 : AppColors.textMuted,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// IpnFooter — tira de atribución institucional con el sello IPN.
class IpnFooter extends StatelessWidget {
  const IpnFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(BrandAssets.ipnLogo, height: 24),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            'Instituto Politécnico Nacional · Escuela Superior de Cómputo',
            style: AppType.sans(size: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

/// PanelHeader — encabezado de sección: disco de ícono + título + descripción.
class PanelHeader extends StatelessWidget {
  const PanelHeader({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.trailing,
  }) : _guinda = false;

  const PanelHeader.guinda({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.trailing,
  }) : _guinda = true;

  final IconData icon;
  final String title;
  final String? description;
  final Widget? trailing;
  final bool _guinda;

  @override
  Widget build(BuildContext context) {
    final (discBg, discFg) = _guinda
        ? (AppColors.guinda50, AppColors.guinda600)
        : (AppColors.primarySoft, AppColors.primary);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: discBg, borderRadius: AppRadii.rmd),
          child: Icon(icon, size: 22, color: discFg),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppType.sans(
                  size: 19,
                  weight: FontWeight.w700,
                  color: AppColors.textStrong,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 2),
                Text(
                  description!,
                  style: AppType.sans(size: 13, color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}
