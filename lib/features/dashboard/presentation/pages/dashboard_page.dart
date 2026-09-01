import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/features/dashboard/data/dashboard_preview_data.dart';
import 'package:fitpulse/features/dashboard/domain/daily_plan.dart';
import 'package:fitpulse/features/onboarding/application/profile_controller.dart';
import 'package:fitpulse/features/onboarding/domain/fitness_profile.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/readiness_ring.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/theme_selector.dart';
import 'package:fitpulse/shared/widgets/brand_mark.dart';
import 'package:fitpulse/shared/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Personalized daily command centre for training, recovery, and nutrition.
class DashboardPage extends ConsumerWidget {
  /// Creates the member dashboard.
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider).value;
    const plan = DashboardPreviewData.today;
    final colors = Theme.of(context).extension<FitPulseColors>()!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            right: -260,
            top: -300,
            child: _DashboardGlow(color: colors.glow),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DashboardHeader(profile: profile),
                      const SizedBox(height: 38),
                      _DashboardIntro(profile: profile, plan: plan),
                      const SizedBox(height: 24),
                      _MainGrid(plan: plan),
                      const SizedBox(height: 24),
                      const _WeeklyPlan(),
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.profile});

  final FitnessProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BrandMark(),
        const Spacer(),
        if (profile != null)
          IconButton.filledTonal(
            tooltip: 'Edit fitness profile',
            onPressed: () => context.go(AppRoutes.onboarding),
            icon: const Icon(Icons.person_outline_rounded),
          ),
        const SizedBox(width: 10),
        const ThemeSelector(),
      ],
    );
  }
}

class _DashboardIntro extends StatelessWidget {
  const _DashboardIntro({required this.profile, required this.plan});

  final FitnessProfile? profile;
  final DailyPlan plan;

  @override
  Widget build(BuildContext context) {
    final name = profile?.displayName;
    return LayoutBuilder(
      builder: (context, constraints) {
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TODAY',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(width: 10),
                const _PreviewBadge(),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name == null ? 'Ready to move?' : 'Ready, $name?',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 10),
            Text(
              plan.recoveryMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (profile == null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => context.go(AppRoutes.onboarding),
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Personalize this plan'),
              ),
            ],
          ],
        );

        final readiness = ReadinessRing(
          progress: plan.readiness / 100,
          size: 126,
        );
        if (constraints.maxWidth < 700) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [copy, const SizedBox(height: 22), readiness],
          );
        }
        return Row(
          children: [
            Expanded(child: copy),
            const SizedBox(width: 36),
            readiness,
          ],
        );
      },
    );
  }
}

class _MainGrid extends StatelessWidget {
  const _MainGrid({required this.plan});

  final DailyPlan plan;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final workout = _WorkoutCard(plan: plan);
        final signals = _SignalsCard(plan: plan);
        if (constraints.maxWidth < 820) {
          return Column(
            children: [workout, const SizedBox(height: 18), signals],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: workout),
            const SizedBox(width: 18),
            Expanded(flex: 2, child: signals),
          ],
        );
      },
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.plan});

  final DailyPlan plan;

  @override
  Widget build(BuildContext context) {
    final session = plan.session;
    return GlassPanel(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.fitness_center_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'YOUR WORKOUT',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              Text(
                '${session.durationMinutes} min',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            session.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            session.focus,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Tag(icon: Icons.speed_rounded, label: session.intensity),
              const _Tag(icon: Icons.repeat_rounded, label: '6 movements'),
              const _Tag(
                icon: Icons.accessibility_new_rounded,
                label: 'Full body',
              ),
            ],
          ),
          const SizedBox(height: 26),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start workout'),
          ),
        ],
      ),
    );
  }
}

class _SignalsCard extends StatelessWidget {
  const _SignalsCard({required this.plan});

  final DailyPlan plan;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Today’s signals',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 18),
          _SignalRow(
            icon: Icons.bedtime_outlined,
            color: Theme.of(context).colorScheme.primary,
            title: 'Sleep',
            value: '${plan.sleepHours.toStringAsFixed(1)} h',
            caption: 'Restored',
          ),
          _SignalRow(
            icon: Icons.directions_walk_rounded,
            color: Theme.of(context).colorScheme.tertiary,
            title: 'Movement',
            value: '${(plan.steps / 1000).toStringAsFixed(1)}k',
            caption: 'Steps',
          ),
          _SignalRow(
            icon: Icons.restaurant_rounded,
            color: Theme.of(context).colorScheme.secondary,
            title: 'Nutrition',
            value: '${plan.proteinGrams} g',
            caption: 'Protein',
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.progress),
            icon: const Icon(Icons.show_chart_rounded),
            label: const Text('View all progress'),
          ),
        ],
      ),
    );
  }
}

class _SignalRow extends StatelessWidget {
  const _SignalRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleMedium),
              Text(caption, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyPlan extends StatelessWidget {
  const _WeeklyPlan();

  @override
  Widget build(BuildContext context) {
    const days = [
      ('MON', 'Strength', true),
      ('TUE', 'Walk', true),
      ('WED', 'Mobility', true),
      ('THU', 'Strength', false),
      ('FRI', 'Recovery', false),
      ('SAT', 'Conditioning', false),
      ('SUN', 'Rest', false),
    ];
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Your week', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Text(
                '3 of 7 complete',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: days
                  .map(
                    (day) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _DayCard(
                        day: day.$1,
                        label: day.$2,
                        complete: day.$3,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.label,
    required this.complete,
  });

  final String day;
  final String label;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 132,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: complete
            ? scheme.primary.withValues(alpha: 0.12)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: complete
              ? scheme.primary.withValues(alpha: 0.35)
              : scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(day, style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              if (complete)
                Icon(
                  Icons.check_circle_rounded,
                  size: 17,
                  color: scheme.primary,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 17), label: Text(label));
  }
}

class _PreviewBadge extends StatelessWidget {
  const _PreviewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'PREVIEW DATA',
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _DashboardGlow extends StatelessWidget {
  const _DashboardGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.26), color.withValues(alpha: 0)],
          ),
        ),
        child: const SizedBox.square(dimension: 720),
      ),
    );
  }
}
