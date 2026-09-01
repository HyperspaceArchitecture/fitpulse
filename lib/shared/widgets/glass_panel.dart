import 'dart:ui';

import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A bounded glassmorphism surface shared across FitPulse features.
class GlassPanel extends StatelessWidget {
  /// Creates a performant translucent panel.
  const GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 28,
    super.key,
  });

  /// Panel content.
  final Widget child;

  /// Interior spacing.
  final EdgeInsetsGeometry padding;

  /// Corner radius used by clipping, border, and decoration.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<FitPulseColors>()!;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.panel.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.34),
              ),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
