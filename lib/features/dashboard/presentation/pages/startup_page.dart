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
    final previousScore = WellnessScore.calculate(metrics[metrics.length - 2]);
    final firstScore = WellnessScore.calculate(metrics.first);
    final yesterdayGain = (score - previousScore) / previousScore * 100;
    final weeklyGain = (score - firstScore) / firstScore * 100;
    final lift = latestWorkout?.momentumLift ?? 0;
    final memberName = profile?.displayName.trim();
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
                    final phone = constraints.maxWidth < 760;
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
                        SizedBox(height: phone ? 16 : 24),
                        Text(
                          memberName == null || memberName.isEmpty
                              ? 'WELCOME'
                              : memberName.toUpperCase(),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                              ),
                        ),
                        SizedBox(height: phone ? 10 : 14),
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
                              style:
                                  (phone
                                          ? Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                          : Theme.of(context)
                                                .textTheme
                                                .displaySmall)
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        height: 1.16,
                                        letterSpacing: -0.4,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    );
                    final growth = Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SimpleGrowthChart(
                          metrics: metrics,
                          height: phone ? 150 : 210,
                        ),
                        SizedBox(height: phone ? 4 : 10),
                        Center(
                          child: MomentumNeedle(
                            value: score,
                            lift: lift,
                            center: _ImprovementPulse(
                              yesterday: yesterdayGain,
                              week: weeklyGain,
                              compact: phone,
                            ),
                            compact: phone,
                          ),
                        ),
                      ],
                    );
                    if (phone) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          identity,
                          const SizedBox(height: 24),
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

class _ImprovementPulse extends StatefulWidget {
  const _ImprovementPulse({
    required this.yesterday,
    required this.week,
    required this.compact,
  });

  final double yesterday;
  final double week;
  final bool compact;

  @override
  State<_ImprovementPulse> createState() => _ImprovementPulseState();
}

class _ImprovementPulseState extends State<_ImprovementPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _opacity = Tween(
      begin: 0.62,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true, count: 2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FitPulseColors>()!;
    final badge = Container(
      width: widget.compact ? 86 : 116,
      height: widget.compact ? 86 : 116,
      padding: EdgeInsets.all(widget.compact ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.success.withValues(alpha: 0.18),
            blurRadius: 24,
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: widget.compact ? 72 : 94,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GainLine(value: widget.yesterday, label: 'SINCE YESTERDAY'),
              const SizedBox(height: 5),
              _GainLine(value: widget.week, label: 'THIS WEEK'),
            ],
          ),
        ),
      ),
    );
    if (MediaQuery.disableAnimationsOf(context)) return badge;
    return FadeTransition(opacity: _opacity, child: badge);
  }
}

class _GainLine extends StatelessWidget {
  const _GainLine({required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final success = Theme.of(context).extension<FitPulseColors>()!.success;
    return Column(
      children: [
        Text(
          '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: success, fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.black87,
            fontSize: 8,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
