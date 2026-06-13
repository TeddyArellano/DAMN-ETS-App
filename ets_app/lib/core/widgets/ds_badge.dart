import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Tono semántico de un [DsBadge].
enum BadgeTone { neutral, info, success, warning, danger, guinda }

/// Estilo del [DsBadge].
enum BadgeVariant { soft, solid, outline }

/// DsBadge — etiqueta compacta de estado o metadato (píldora).
class DsBadge extends StatelessWidget {
  const DsBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.neutral,
    this.variant = BadgeVariant.soft,
    this.icon,
    this.mono = false,
  });

  final String label;
  final BadgeTone tone;
  final BadgeVariant variant;
  final IconData? icon;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final palette = switch (tone) {
      BadgeTone.neutral => (
          AppColors.slate100,
          AppColors.slate700,
          AppColors.slate700,
          AppColors.border,
        ),
      BadgeTone.info => (
          AppColors.primarySoft,
          AppColors.azul700,
          AppColors.primary,
          AppColors.azul300,
        ),
      BadgeTone.success => (
          AppColors.successSoft,
          AppColors.success,
          AppColors.success,
          AppColors.green600,
        ),
      BadgeTone.warning => (
          AppColors.warningSoft,
          AppColors.warning,
          AppColors.warning,
          AppColors.amber600,
        ),
      BadgeTone.danger => (
          AppColors.dangerSoft,
          AppColors.danger,
          AppColors.danger,
          AppColors.red600,
        ),
      BadgeTone.guinda => (
          AppColors.guinda50,
          AppColors.guinda600,
          AppColors.accent,
          AppColors.guinda300,
        ),
    };
    final (softBg, softFg, solidBg, lineColor) = palette;

    late final Color bg;
    late final Color fg;
    late final Color borderColor;
    switch (variant) {
      case BadgeVariant.solid:
        bg = solidBg;
        fg = AppColors.white;
        borderColor = Colors.transparent;
      case BadgeVariant.outline:
        bg = Colors.transparent;
        fg = softFg;
        borderColor = lineColor;
      case BadgeVariant.soft:
        bg = softBg;
        fg = softFg;
        borderColor = Colors.transparent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: mono
                ? AppType.mono(size: 12, weight: FontWeight.w500, color: fg)
                : AppType.sans(
                    size: 12,
                    weight: FontWeight.w600,
                    color: fg,
                    letterSpacing: 0.1,
                  ),
          ),
        ],
      ),
    );
  }
}
