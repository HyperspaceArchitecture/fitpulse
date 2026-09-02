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
                track: Theme.of(context).colorScheme.surfaceContainerHighest,
                active: colors.success,
                needle: Theme.of(context).colorScheme.onSurface,
              ),
              child: Align(
                alignment: const Alignment(0, 0.55),
                child:
                    center ??
                    Text(
                      animatedValue.round().toString(),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
              ),
            ),
          ),
          Text(
            lift > 0
                ? '+${lift.toStringAsFixed(1)} momentum from your workout'
                : 'Your next workout will move the needle',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: lift > 0 ? colors.success : null,
              fontWeight: FontWeight.w800,
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
    required this.track,
    required this.active,
    required this.needle,
  });

  final double value;
  final Color track;
  final Color active;
  final Color needle;

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
      ..strokeWidth = size.width * 0.065;
    final activePaint = Paint()
      ..color = active
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.065;
    canvas.drawArc(rect, start, sweep, false, trackPaint);
    canvas.drawArc(
      rect,
      start,
      sweep * value.clamp(0, 100) / 100,
      false,
      activePaint,
    );

    final angle = start + sweep * value.clamp(0, 100) / 100;
    final end = Offset(
      center.dx + math.cos(angle) * radius * 0.68,
      center.dy + math.sin(angle) * radius * 0.68,
    );
    canvas.drawLine(
      center,
      end,
      Paint()
        ..color = needle
        ..strokeWidth = size.width * 0.025
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, size.width * 0.045, Paint()..color = needle);
  }

  @override
  bool shouldRepaint(_NeedlePainter oldDelegate) =>
      value != oldDelegate.value ||
      track != oldDelegate.track ||
      active != oldDelegate.active ||
      needle != oldDelegate.needle;
}
