import 'package:fitpulse/features/workout/domain/workout_plan.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Animated, offline exercise illustration with an optional external demo.
class ExerciseMotionCard extends StatefulWidget {
  /// Creates an exercise motion card.
  const ExerciseMotionCard({
    required this.exercise,
    this.compact = false,
    super.key,
  });

  /// Exercise whose demonstration is shown.
  final WorkoutExercise exercise;

  /// Whether to use the compact overview presentation.
  final bool compact;

  @override
  State<ExerciseMotionCard> createState() => _ExerciseMotionCardState();
}

class _ExerciseMotionCardState extends State<ExerciseMotionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _motion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _motion = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.compact ? 16 : 22);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: radius,
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.exercise.illustrationAsset,
                  fit: BoxFit.cover,
                  semanticLabel:
                      'Two-phase cartoon demonstration of ${widget.exercise.name}',
                ),
                AnimatedBuilder(
                  animation: _motion,
                  builder: (context, child) {
                    return Positioned(
                      left: 12 + (_motion.value * 8),
                      bottom: 12,
                      child: Opacity(
                        opacity: 0.72 + (_motion.value * 0.28),
                        child: child,
                      ),
                    );
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.motion_photos_on_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FOLLOW THE MOTION',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 9),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _openVideo,
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: Text('Watch on YouTube • ${widget.exercise.videoSource}'),
          ),
        ),
      ],
    );
  }

  Future<void> _openVideo() async {
    final uri = Uri.parse(widget.exercise.videoUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the technique video.')),
      );
    }
  }
}
