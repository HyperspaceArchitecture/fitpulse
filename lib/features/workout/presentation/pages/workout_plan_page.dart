import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/theme_selector.dart';
import 'package:fitpulse/features/workout/application/workout_engine_controller.dart';
import 'package:fitpulse/features/workout/domain/workout_plan.dart';
import 'package:fitpulse/shared/widgets/brand_mark.dart';
import 'package:fitpulse/shared/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Workout overview shown before an active session begins.
class WorkoutPlanPage extends ConsumerWidget {
  /// Creates the workout plan page.
  const WorkoutPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutEngineProvider);
    final plan = session.plan;
    final colors = Theme.of(context).extension<FitPulseColors>()!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            right: -240,
            top: -280,
            child: _WorkoutGlow(color: colors.glow),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton.filledTonal(
                            tooltip: 'Back to dashboard',
                            onPressed: () => context.go(AppRoutes.dashboard),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 12),
                          const BrandMark(),
                          const Spacer(),
                          const ThemeSelector(),
                        ],
                      ),
                      const SizedBox(height: 36),
                      Text(
                        'TODAY’S WORKOUT',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        plan.title,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        plan.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _PlanFact(
                            icon: Icons.timer_outlined,
                            text: '${plan.durationMinutes} min',
                          ),
                          _PlanFact(
                            icon: Icons.speed_rounded,
                            text: plan.intensity,
                          ),
                          _PlanFact(
                            icon: Icons.repeat_rounded,
                            text: '${plan.totalSets} working sets',
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      GlassPanel(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Session plan',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Spacer(),
                                Text('${plan.exercises.length} movements'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...plan.exercises.indexed.map(
                              (entry) => _ExerciseTile(
                                index: entry.$1,
                                exercise: entry.$2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () {
                          if (session.complete) {
                            ref.read(workoutEngineProvider.notifier).reset();
                          }
                          context.go(AppRoutes.workoutSession);
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          session.started && !session.complete
                              ? 'Resume workout'
                              : 'Start workout',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.index, required this.exercise});

  final int index;
  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.48),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Text('${index + 1}'),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    exercise.focus,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${exercise.sets} × ${exercise.reps}',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanFact extends StatelessWidget {
  const _PlanFact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(text));
  }
}

class _WorkoutGlow extends StatelessWidget {
  const _WorkoutGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.24), color.withValues(alpha: 0)],
          ),
        ),
        child: const SizedBox.square(dimension: 680),
      ),
    );
  }
}
