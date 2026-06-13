import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

/// Tono del disco de ícono del [StatTile].
enum StatTone { info, guinda, success, neutral }

/// StatTile — estadística rápida del dashboard: disco de ícono, número grande
/// en serif y etiqueta. El número hace el trabajo; la etiqueta va pequeña.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.tone = StatTone.info,
    this.hint,
  });

  final String value;
  final String label;
  final IconData icon;
  final StatTone tone;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final (discBg, discFg) = switch (tone) {
      StatTone.info => (AppColors.primarySoft, AppColors.primary),
      StatTone.guinda => (AppColors.guinda50, AppColors.guinda600),
      StatTone.success => (AppColors.successSoft, AppColors.success),
      StatTone.neutral => (AppColors.surfaceSunken, AppColors.slate600),
    };

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.rlg,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: discBg,
                  borderRadius: AppRadii.rmd,
                ),
                child: Icon(icon, size: 22, color: discFg),
              ),
              if (hint != null)
                Text(
                  hint!,
                  style: AppType.mono(size: 12, color: AppColors.textFaint),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppType.serif(
              size: 40,
              weight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppType.sans(size: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
