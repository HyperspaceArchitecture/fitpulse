import 'dart:math' as math;

import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/features/progress/domain/wellness_metric.dart';
import 'package:fitpulse/features/progress/domain/wellness_score.dart';
import 'package:flutter/material.dart';

/// A deliberately simple single-line view of holistic growth.
class SimpleGrowthChart extends StatelessWidget {
  /// Creates a green combined-growth chart.
  const SimpleGrowthChart({required this.metrics, super.key});

  /// Chronological wellness inputs combined into one series.
  final List<WellnessMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).extension<FitPulseColors>()!.success;
    return Semantics(
      label: 'Overall growth trend combining exercise, sleep, and nutrition for the last seven days.',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 850),
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) {
          return CustomPaint(
            painter: _SimpleGrowthPainter(
              metrics: metrics,
              progress: progress,
              green: green,
              grid: Theme.of(context).colorScheme.outlineVariant
                  .withValues(alpha: 0.24),
              labelStyle: Theme.of(context).textTheme.labelSmall!,
              labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            child: const SizedBox(height: 210),
          );
        },
      ),
    );
  }
}

class _SimpleGrowthPainter extends CustomPainter {
  const _SimpleGrowthPainter({
    required this.metrics,
    required this.progress,
    required this.green,
    required this.grid,
    required this.labelStyle,
    required this.labelColor,
  });

  final List<WellnessMetric> metrics;
  final double progress;
  final Color green;
  final Color grid;
  final TextStyle labelStyle;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;
    const left = 10.0;
    const right = 10.0;
    const top = 12.0;
    const bottom = 28.0;
    final bounds = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final scores = metrics.map(WellnessScore.calculate).toList();
    final minimum = scores.reduce(math.min) - 1.2;
    final maximum = scores.reduce(math.max) + 1.2;
    final range = math.max(1.0, maximum - minimum);

    final baselinePaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(bounds.left, bounds.bottom),
      Offset(bounds.right, bounds.bottom),
      baselinePaint,
    );

    final path = Path();
    for (var index = 0; index < scores.length; index++) {
      final x = scores.length == 1
          ? bounds.center.dx
          : bounds.left + bounds.width * index / (scores.length - 1);
      final normalized = (scores[index] - minimum) / range;
      final targetY = bounds.bottom - bounds.height * normalized;
      final y = bounds.bottom + (targetY - bounds.bottom) * progress;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      if (progress == 1) {
        canvas.drawCircle(
          Offset(x, y),
          index == scores.length - 1 ? 5 : 3,
          Paint()..color = green,
        );
      }
      _drawLabel(
        canvas,
        _day(metrics[index].date.weekday),
        Offset(x - 8, bounds.bottom + 9),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawLabel(Canvas canvas, String value, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: labelStyle.copyWith(color: labelColor),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  static String _day(int weekday) {
    return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
  }

  @override
  bool shouldRepaint(covariant _SimpleGrowthPainter oldDelegate) {
    return metrics != oldDelegate.metrics ||
        progress != oldDelegate.progress ||
        green != oldDelegate.green;
  }
}
