import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/features/dashboard/presentation/widgets/momentum_needle.dart';
import 'package:fitpulse/features/workout/application/workout_engine_controller.dart';
import 'package:fitpulse/features/workout/presentation/widgets/exercise_motion_card.dart';
import 'package:fitpulse/shared/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Live set-by-set workout execution screen.
class WorkoutSessionPage extends ConsumerWidget {
  /// Creates the live workout session.
  const WorkoutSessionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutEngineProvider);
    final controller = ref.read(workoutEngineProvider.notifier);

    if (session.complete) {
      return _CompletedSession(session: session, onReset: controller.reset);
    }

    final exercise = session.exercise;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Workout overview',
                        onPressed: () => context.go(AppRoutes.workouts),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      const Spacer(),
                      Text(_duration(session.elapsedSeconds)),
                      const SizedBox(width: 10),
                      IconButton.filledTonal(
                        tooltip: session.paused ? 'Resume' : 'Pause',
                        onPressed: session.started
                            ? controller.togglePause
                            : null,
                        icon: Icon(
                          session.paused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  LinearProgressIndicator(
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(999),
                    value: session.progress,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'MOVEMENT ${session.exerciseIndex + 1} OF ${session.plan.exercises.length}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${session.completedSets}/${session.plan.totalSets} sets',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  GlassPanel(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          exercise.focus.toUpperCase(),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          exercise.reps,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 22),
                        ExerciseMotionCard(exercise: exercise),
                        const SizedBox(height: 24),
                        _SetMarkers(
                          total: exercise.sets,
                          completed: session.setIndex,
                        ),
                        const SizedBox(height: 28),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(exercise.coachingCue)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (!session.started)
                    FilledButton.icon(
                      onPressed: controller.start,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Begin first set'),
                    )
                  else if (session.paused)
                    FilledButton.icon(
                      onPressed: controller.togglePause,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Resume workout'),
                    )
                  else if (session.resting)
                    _RestControl(
                      seconds: session.restRemaining,
                      onSkip: controller.skipRest,
                    )
                  else
                    FilledButton.icon(
                      key: const Key('complete-set'),
                      onPressed: controller.completeSet,
                      icon: const Icon(Icons.check_rounded),
                      label: Text('Complete set ${session.setIndex + 1}'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _duration(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }
}

class _SetMarkers extends StatelessWidget {
  const _SetMarkers({required this.total, required this.completed});

  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final done = index < completed;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == total - 1 ? 0 : 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: done
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: done
                    ? Icon(
                        Icons.check_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : Text('SET ${index + 1}'),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _RestControl extends StatelessWidget {
  const _RestControl({required this.seconds, required this.onSkip});

  final int seconds;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rest', style: Theme.of(context).textTheme.titleMedium),
                Text('$seconds seconds'),
              ],
            ),
          ),
          TextButton(onPressed: onSkip, child: const Text('Skip rest')),
        ],
      ),
    );
  }
}

class _CompletedSession extends StatelessWidget {
  const _CompletedSession({required this.session, required this.onReset});

  final WorkoutSessionState session;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: GlassPanel(
                padding: const EdgeInsets.all(36),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      child: const Icon(Icons.celebration_rounded, size: 38),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Workout complete',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${session.completedSets} sets logged offline. Consistency beats perfection.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    MomentumNeedle(
                      value: 78 + session.completedSets * 0.24,
                      lift: session.completedSets * 0.24,
                      compact: true,
                    ),
                    const SizedBox(height: 26),
                    FilledButton.icon(
                      onPressed: () {
                        onReset();
                        context.go(AppRoutes.landing);
                      },
                      icon: const Icon(Icons.trending_up_rounded),
                      label: const Text('See my momentum'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
