import 'dart:math' as math;

import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// An encouragement gauge. It is deliberately not presented as a health score.
class MomentumNeedle extends StatelessWidget {
  const MomentumNeedle({
    required this.value,
    required this.lift,
    this.compact = false,
    this.center,
    super.key,
  });

  final double value;
  final double lift;
  final bool compact;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FitPulseColors>()!;
    final size = compact ? 150.0 : 220.0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: (value - lift).clamp(0, 100), end: value),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutBack,
      builder: (context, animatedValue, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _NeedlePainter(
                value: animatedValue,
                lift: lift,
                track: Theme.of(context).colorScheme.surfaceContainerHighest,
                active: colors.success,
                marker: Theme.of(context).colorScheme.onSurface,
              ),
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, size * 0.16),
                  child:
                      center ??
                      Text(
                        animatedValue.round().toString(),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              lift > 0
                  ? '+${lift.toStringAsFixed(1)} momentum from your workout'
                  : 'Your next workout will move the needle',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: lift > 0 ? colors.success : null,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeedlePainter extends CustomPainter {
  const _NeedlePainter({
    required this.value,
    required this.lift,
    required this.track,
    required this.active,
    required this.marker,
  });

  final double value;
  final double lift;
  final Color track;
  final Color active;
  final Color marker;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.66);
    final radius = size.width * 0.39;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = math.pi * 0.8;
    const sweep = math.pi * 1.4;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.028;
    final activePaint = Paint()
      ..color = active
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.028;
    canvas.drawArc(rect, start, sweep, false, trackPaint);
    canvas.drawArc(
      rect,
      start,
      sweep * value.clamp(0, 100) / 100,
      false,
      activePaint,
    );

    final currentAngle = start + sweep * value.clamp(0, 100) / 100;
    final currentPoint = Offset(
      center.dx + math.cos(currentAngle) * radius,
      center.dy + math.sin(currentAngle) * radius,
    );
    if (lift > 0) {
      final previousAngle = start + sweep * (value - lift).clamp(0, 100) / 100;
      final previousPoint = Offset(
        center.dx + math.cos(previousAngle) * radius,
        center.dy + math.sin(previousAngle) * radius,
      );
      canvas.drawCircle(
        previousPoint,
        size.width * 0.018,
        Paint()..color = marker.withValues(alpha: 0.35),
      );
    }
    canvas.drawCircle(
      currentPoint,
      size.width * 0.024,
      Paint()..color = marker,
    );
    canvas.drawCircle(
      currentPoint,
      size.width * 0.010,
      Paint()..color = active,
    );
  }

  @override
  bool shouldRepaint(_NeedlePainter oldDelegate) =>
      value != oldDelegate.value ||
      lift != oldDelegate.lift ||
      track != oldDelegate.track ||
      active != oldDelegate.active ||
      marker != oldDelegate.marker;
}
