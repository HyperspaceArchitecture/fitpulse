import 'dart:math' as math;

import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/features/progress/domain/wellness_metric.dart';
import 'package:fitpulse/features/progress/domain/wellness_score.dart';
import 'package:flutter/material.dart';

/// Interactive multi-series chart for combined wellness progress.
class WellnessChart extends StatefulWidget {
  /// Creates a wellness chart from chronological [metrics].
  const WellnessChart({required this.metrics, super.key});

  /// Daily measurements displayed from oldest to newest.
  final List<WellnessMetric> metrics;

  @override
  State<WellnessChart> createState() => _WellnessChartState();
}

class _WellnessChartState extends State<WellnessChart> {
  int? _selectedIndex;

  void _selectPoint(TapDownDetails details, double width) {
    if (widget.metrics.isEmpty) return;
    const leftInset = 42.0;
    const rightInset = 16.0;
    final chartWidth = math.max(1, width - leftInset - rightInset);
    final normalized = ((details.localPosition.dx - leftInset) / chartWidth)
        .clamp(0.0, 1.0);
    final index = (normalized * (widget.metrics.length - 1)).round();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedIndex == null
        ? widget.metrics.lastOrNull
        : widget.metrics[_selectedIndex!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  _selectPoint(details, constraints.maxWidth),
              child: Semantics(
                label:
                    'Wellness progress graph. Tap a day to inspect its scores.',
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, progress, child) {
                    return CustomPaint(
                      painter: _WellnessChartPainter(
                        metrics: widget.metrics,
                        animationProgress: progress,
                        selectedIndex: _selectedIndex,
                        scheme: Theme.of(context).colorScheme,
                        colors: Theme.of(context).extension<FitPulseColors>()!,
                        textStyle: Theme.of(context).textTheme.labelSmall!,
                      ),
                      child: const SizedBox(height: 300),
                    );
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        if (selected != null) _SelectedDay(metric: selected),
      ],
    );
  }
}

class _SelectedDay extends StatelessWidget {
  const _SelectedDay({required this.metric});

  final WellnessMetric metric;

  @override
  Widget build(BuildContext context) {
    final score = WellnessScore.calculate(metric).round();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '${_weekday(metric.date.weekday)}, ${metric.date.day}/${metric.date.month}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _ScoreLabel(label: 'Overall', value: score),
            _ScoreLabel(label: 'Exercise', value: metric.exercise.round()),
            _ScoreLabel(label: 'Sleep', value: metric.sleep.round()),
            _ScoreLabel(label: 'Nutrition', value: metric.nutrition.round()),
            Text(
              'Weight ${metric.weightKg.toStringAsFixed(1)} kg',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _weekday(int weekday) {
    return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
  }
}

class _ScoreLabel extends StatelessWidget {
  const _ScoreLabel({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label $value',
      style: Theme.of(context).textTheme.labelMedium
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class _WellnessChartPainter extends CustomPainter {
  _WellnessChartPainter({
    required this.metrics,
    required this.animationProgress,
    required this.selectedIndex,
    required this.scheme,
    required this.colors,
    required this.textStyle,
  });

  final List<WellnessMetric> metrics;
  final double animationProgress;
  final int? selectedIndex;
  final ColorScheme scheme;
  final FitPulseColors colors;
  final TextStyle textStyle;

  static const _left = 42.0;
  static const _right = 16.0;
  static const _top = 18.0;
  static const _bottom = 30.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;
    final bounds = Rect.fromLTRB(
      _left,
      _top,
      size.width - _right,
      size.height - _bottom,
    );
    _drawGrid(canvas, bounds);
    _drawOverallFill(canvas, bounds);
    _drawSeries(
      canvas,
      bounds,
      metrics.map(WellnessScore.calculate).toList(),
      scheme.primary,
      3.2,
    );
    _drawSeries(
      canvas,
      bounds,
      metrics.map((metric) => metric.exercise).toList(),
      colors.success,
      2,
    );
    _drawSeries(
      canvas,
      bounds,
      metrics.map((metric) => metric.sleep).toList(),
      scheme.tertiary,
      2,
    );
    _drawSeries(
      canvas,
      bounds,
      metrics.map((metric) => metric.nutrition).toList(),
      colors.warning,
      2,
    );
    _drawWeightSeries(canvas, bounds);
    _drawSelection(canvas, bounds);
  }

  void _drawGrid(Canvas canvas, Rect bounds) {
    final paint = Paint()
      ..color = scheme.outlineVariant.withValues(alpha: 0.22)
      ..strokeWidth = 1;
    for (final value in [0, 25, 50, 75, 100]) {
      final y = bounds.bottom - bounds.height * value / 100;
      canvas.drawLine(Offset(bounds.left, y), Offset(bounds.right, y), paint);
      _drawText(canvas, '$value', Offset(4, y - 7));
    }
    for (var index = 0; index < metrics.length; index++) {
      final x = _x(bounds, index);
      _drawText(
        canvas,
        _dayLetter(metrics[index].date.weekday),
        Offset(x - 4, bounds.bottom + 10),
      );
    }
  }

  void _drawOverallFill(Canvas canvas, Rect bounds) {
    final values = metrics.map(WellnessScore.calculate).toList();
    final path = _path(bounds, values)
      ..lineTo(_x(bounds, values.length - 1), bounds.bottom)
      ..lineTo(_x(bounds, 0), bounds.bottom)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.primary.withValues(alpha: 0.22),
            scheme.primary.withValues(alpha: 0),
          ],
        ).createShader(bounds),
    );
  }

  void _drawSeries(
    Canvas canvas,
    Rect bounds,
    List<double> values,
    Color color,
    double strokeWidth,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_path(bounds, values), paint);
    for (var index = 0; index < values.length; index++) {
      canvas.drawCircle(
        Offset(_x(bounds, index), _y(bounds, values[index])),
        strokeWidth > 3 ? 3.5 : 2.3,
        Paint()..color = color,
      );
    }
  }

  void _drawWeightSeries(Canvas canvas, Rect bounds) {
    final weights = metrics.map((metric) => metric.weightKg).toList();
    final minimum = weights.reduce(math.min);
    final maximum = weights.reduce(math.max);
    final range = math.max(0.5, maximum - minimum);
    final normalized = weights
        .map((weight) => 18 + ((weight - minimum) / range) * 64)
        .toList();
    _drawSeries(
      canvas,
      bounds,
      normalized,
      scheme.onSurface.withValues(alpha: 0.72),
      1.6,
    );
    _drawText(
      canvas,
      '${maximum.toStringAsFixed(1)}kg',
      Offset(bounds.right - 42, bounds.top + 2),
    );
    _drawText(
      canvas,
      '${minimum.toStringAsFixed(1)}kg',
      Offset(bounds.right - 42, bounds.bottom - 16),
    );
  }

  Path _path(Rect bounds, List<double> values) {
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final point = Offset(_x(bounds, index), _y(bounds, values[index]));
      index == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  void _drawSelection(Canvas canvas, Rect bounds) {
    if (selectedIndex == null) return;
    final x = _x(bounds, selectedIndex!);
    canvas.drawLine(
      Offset(x, bounds.top),
      Offset(x, bounds.bottom),
      Paint()
        ..color = scheme.onSurface.withValues(alpha: 0.35)
        ..strokeWidth = 1,
    );
  }

  double _x(Rect bounds, int index) {
    if (metrics.length == 1) return bounds.center.dx;
    return bounds.left + bounds.width * index / (metrics.length - 1);
  }

  double _y(Rect bounds, double value) {
    return bounds.bottom - bounds.height * (value / 100) * animationProgress;
  }

  void _drawText(Canvas canvas, String value, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: textStyle.copyWith(color: scheme.onSurfaceVariant),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  static String _dayLetter(int weekday) {
    return const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][weekday - 1];
  }

  @override
  bool shouldRepaint(covariant _WellnessChartPainter oldDelegate) {
    return animationProgress != oldDelegate.animationProgress ||
        selectedIndex != oldDelegate.selectedIndex ||
        metrics != oldDelegate.metrics ||
        scheme != oldDelegate.scheme;
  }
}
