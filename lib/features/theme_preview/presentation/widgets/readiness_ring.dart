import 'package:flutter/material.dart';

/// Compact readiness visualization used by the foundation experience.
class ReadinessRing extends StatelessWidget {
  /// Creates a readiness ring for a normalized [progress] value.
  const ReadinessRing({required this.progress, this.size = 116, super.key});

  /// Completion value between zero and one.
  final double progress;

  /// Diameter of the visualization.
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percentage = (progress.clamp(0, 1) * 100).round();

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text('READY', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
