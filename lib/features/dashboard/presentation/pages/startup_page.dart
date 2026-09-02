import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/features/dashboard/data/motivational_quotes.dart';
import 'package:fitpulse/features/dashboard/presentation/widgets/momentum_needle.dart';
import 'package:fitpulse/features/onboarding/application/profile_controller.dart';
import 'package:fitpulse/features/progress/application/progress_controller.dart';
import 'package:fitpulse/features/progress/data/progress_preview_data.dart';
import 'package:fitpulse/features/progress/domain/wellness_score.dart';
import 'package:fitpulse/features/progress/presentation/widgets/simple_growth_chart.dart';
import 'package:fitpulse/features/workout/data/workout_history_repository.dart';
import 'package:fitpulse/shared/widgets/member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Deliberately quiet startup: identity, thought, growth, and earned momentum.
class StartupPage extends ConsumerStatefulWidget {
  const StartupPage({super.key});

  @override
  ConsumerState<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends ConsumerState<StartupPage> {
  late int _quoteIndex;

  @override
  void initState() {
    super.initState();
    _quoteIndex = DateTime.now().day % MotivationalQuotes.values.length;
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider).value;
    final metrics =
        ref.watch(progressControllerProvider).value ??
        ProgressPreviewData.recentWeek;
    final latestWorkout = ref.watch(latestWorkoutProvider).value;
    final score = WellnessScore.calculate(metrics.last);
    final lift = latestWorkout?.momentumLift ?? 0;
    final colors = Theme.of(context).extension<FitPulseColors>()!;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.7, -0.8),
            radius: 1.35,
            colors: [colors.glow.withValues(alpha: 0.24), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final identity = Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Tooltip(
                          message: 'Open FitPulse',
                          child: InkWell(
                            key: const Key('startup-avatar'),
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => context.go(AppRoutes.dashboard),
                            child: MemberAvatar(profile: profile),
                          ),
                        ),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: () => setState(
                            () => _quoteIndex =
                                (_quoteIndex + 1) %
                                MotivationalQuotes.values.length,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: Text(
                              MotivationalQuotes.values[_quoteIndex],
                              key: ValueKey(_quoteIndex),
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    );
                    final growth = Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SimpleGrowthChart(metrics: metrics),
                        const SizedBox(height: 10),
                        Center(
                          child: MomentumNeedle(
                            value: score,
                            lift: lift,
                            compact: true,
                          ),
                        ),
                      ],
                    );
                    if (constraints.maxWidth < 760) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          identity,
                          const SizedBox(height: 36),
                          growth,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 4, child: identity),
                        const SizedBox(width: 54),
                        Expanded(flex: 6, child: growth),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
