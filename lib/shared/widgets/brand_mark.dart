import 'package:flutter/material.dart';

/// Reusable FitPulse wordmark with its energy-bolt symbol.
class BrandMark extends StatelessWidget {
  /// Creates the FitPulse brand mark.
  const BrandMark({this.compact = false, super.key});

  /// Hides the wordmark when only the symbol is needed.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.24),
                blurRadius: 24,
              ),
            ],
          ),
          child: SizedBox.square(
            dimension: 44,
            child: Icon(Icons.bolt_rounded, color: theme.colorScheme.onPrimary),
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 12),
          Text('FITPULSE', style: theme.textTheme.titleLarge),
        ],
      ],
    );
  }
}
