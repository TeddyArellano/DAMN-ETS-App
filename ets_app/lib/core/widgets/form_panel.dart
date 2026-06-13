import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

/// FormPanel — sub-panel atenuado que enmarca los formularios de "crear"
/// dentro de una Card (estilo v2). Título en mayúsculas con ícono.
class FormPanel extends StatelessWidget {
  const FormPanel({
    super.key,
    required this.title,
    required this.children,
    this.icon = Icons.add_circle_outline,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.rmd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppType.sans(
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.04 * 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
