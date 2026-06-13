import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// DsCard — la superficie blanca tipo papel. Primitivo estructural de la app:
/// borde hairline real, radio moderado y elevación fría y contenida.
class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color = AppColors.surface,
    this.borderColor = AppColors.borderSubtle,
    this.shadow,
    this.radius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final List<BoxShadow>? shadow;
  final BorderRadius? radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final br = radius ?? AppRadii.rlg;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: shadow ?? AppShadows.sm,
      ),
      child: Material(
        color: color,
        borderRadius: br,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: br,
              border: Border.all(color: borderColor),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
