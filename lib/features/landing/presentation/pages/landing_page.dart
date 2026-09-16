import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:fitpulse/core/theme/theme_controller.dart';
import 'package:fitpulse/features/onboarding/application/profile_controller.dart';
import 'package:fitpulse/features/progress/data/progress_preview_data.dart';
import 'package:fitpulse/features/progress/domain/wellness_metric.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Algorithm for Pulse Score: composite growth metric (not weight-based).
/// Combines exercise, nutrition, and consistency into one encouraging metric.
abstract final class PulseScoreAlgorithm {
  /// Exercise contribution (consistency + intensity matter most).
  static const exerciseWeight = 0.50;

  /// Nutrition contribution (meal logging + adherence).
  static const nutritionWeight = 0.30;

  /// Sleep contribution (recovery enables progress).
  static const sleepWeight = 0.20;

  /// Calculate Pulse Score (0-100) for a single day.
  static double calculateDaily(WellnessMetric metric) {
    return metric.exercise * exerciseWeight +
        metric.nutrition * nutritionWeight +
        metric.sleep * sleepWeight;
  }

  /// Calculate average Pulse Score over a period.
  static double calculatePeriod(List<WellnessMetric> metrics) {
    if (metrics.isEmpty) return 0;
    final scores = metrics.map(calculateDaily).toList();
    return scores.fold(0, (sum, score) => sum + score) / scores.length;
  }

  /// Compare yesterday vs today — percentage improvement.
  static double dailyImprovement(
    WellnessMetric yesterday,
    WellnessMetric today,
  ) {
    final yScore = calculateDaily(yesterday);
    final tScore = calculateDaily(today);
    if (yScore == 0) return 0;
    return ((tScore - yScore) / yScore) * 100;
  }

  /// Detect milestone: >5 point jump day-over-day.
  static bool isMilestoneDay(WellnessMetric yesterday, WellnessMetric today) {
    final delta = calculateDaily(today) - calculateDaily(yesterday);
    return delta > 5;
  }
}

/// Motivational quotes from famous athletes and coaches.
abstract final class MotivationalQuotes {
  static final list = <String>[
    'The only way to do great work is to love what you do. — Steve Jobs',
    'Don\'t watch the clock; do what it does. Keep going. — Sam Levenson',
    'Your body can stand almost anything. It\'s your mind that you need to convince. — Andrew Murphy',
    'Excellence is not a skill, it\'s an attitude. — Ralph Marston',
    'The pain you feel today will be the strength you feel tomorrow. — Unknown',
    'Discipline is doing something you hate to do, but nonetheless doing it like you love it. — Mike Tyson',
    'Success is not final, failure is not fatal. It\'s the courage to continue that counts. — Winston Churchill',
    'You miss 100% of the shots you don\'t take. — Wayne Gretzky',
    'Push yourself, because no one else is going to do it for you. — Unknown',
    'The difference between ordinary and extraordinary is that little "extra". — Jimmy Johnson',
  ];

  static String random() => list[(DateTime.now().millisecond % list.length)];
}

/// Landing page: motivational entry point with growth graph and action buttons.
class LandingPage extends ConsumerStatefulWidget {
  /// Creates the landing page.
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with SingleTickerProviderStateMixin {
  late PageController _quoteController;
  late int _currentQuoteIndex;
  late TabController _graphTabController;
  late AnimationController _fadeController;

  final _metrics = ProgressPreviewData.recentWeek;

  @override
  void initState() {
    super.initState();
    _quoteController = PageController();
    _currentQuoteIndex = 0;
    _graphTabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _graphTabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextQuote() {
    _fadeController.reverse().then((_) {
      _quoteController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _currentQuoteIndex =
          (_currentQuoteIndex + 1) % MotivationalQuotes.list.length;
      _fadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider).value;
    final theme = ref.watch(themeControllerProvider).value;
    final colors = Theme.of(context).extension<FitPulseColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final isFriendly = theme == AppThemeVariant.illustratedSoft;
    final isAthletic = theme == AppThemeVariant.athleticDark;

    final todayScore = PulseScoreAlgorithm.calculateDaily(_metrics.last);
    final yesterdayScore = _metrics.length > 1
        ? PulseScoreAlgorithm.calculateDaily(_metrics[_metrics.length - 2])
        : todayScore;
    final dailyGain =
        PulseScoreAlgorithm.dailyImprovement(_metrics[_metrics.length - 2], _metrics.last);

    return Scaffold(
      body: Stack(
        children: [
          // Gradient/glow backdrop
          Positioned(
            right: -200,
            top: -100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.glow.withValues(alpha: 0.12),
                    colors.glow.withValues(alpha: 0),
                  ],
                ),
              ),
              child: const SizedBox.square(dimension: 600),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. QUOTE CAROUSEL
                      _QuoteCarousel(
                        controller: _quoteController,
                        onNext: _nextQuote,
                        fadeAnimation: _fadeController,
                        theme: theme,
                      ),
                      const SizedBox(height: 36),

                      // 2. ENCOURAGEMENT MESSAGE
                      _EncouragementCard(
                        todayScore: todayScore,
                        dailyGain: dailyGain,
                        profile: profile,
                        isFriendly: isFriendly,
                        colors: colors,
                        scheme: scheme,
                      ),
                      const SizedBox(height: 28),

                      // 3. GROWTH GRAPH
                      _GrowthGraph(
                        metrics: _metrics,
                        tabController: _graphTabController,
                        isFriendly: isFriendly,
                        colors: colors,
                        scheme: scheme,
                      ),
                      const SizedBox(height: 32),

                      // 4. BOTTOM ACTIONS
                      Row(
                        children: [
                          // AI Coach button
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.go(AppRoutes.coach),
                              child: Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  color: colors.panel,
                                  borderRadius: BorderRadius.circular(isFriendly ? 24 : 16),
                                  border: Border.all(
                                    color: scheme.outlineVariant
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '🤖 Coach',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Go to app button
                          Expanded(
                            child: FilledButton(
                              onPressed: () =>
                                  context.go(AppRoutes.dashboard),
                              child: const Text('Enter App →'),
                            ),
                          ),
                        ],
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

class _QuoteCarousel extends StatelessWidget {
  const _QuoteCarousel({
    required this.controller,
    required this.onNext,
    required this.fadeAnimation,
    required this.theme,
  });

  final PageController controller;
  final VoidCallback onNext;
  final AnimationController fadeAnimation;
  final AppThemeVariant? theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Today\'s Thought',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(
              theme == AppThemeVariant.illustratedSoft ? 28 : 20,
            ),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: MotivationalQuotes.list.length,
                itemBuilder: (context, index) {
                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          MotivationalQuotes.list[index],
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: GestureDetector(
                  onTap: onNext,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EncouragementCard extends StatelessWidget {
  const _EncouragementCard({
    required this.todayScore,
    required this.dailyGain,
    required this.profile,
    required this.isFriendly,
    required this.colors,
    required this.scheme,
  });

  final double todayScore;
  final double dailyGain;
  final dynamic profile;
  final bool isFriendly;
  final FitPulseColors colors;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final name = profile?.displayName ?? 'Friend';
    final gainText = dailyGain >= 0 ? '+${dailyGain.toStringAsFixed(1)}%' : '${dailyGain.toStringAsFixed(1)}%';
    final gainColor = dailyGain >= 0 ? colors.success : colors.warning;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.08),
            scheme.primary.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(isFriendly ? 28 : 20),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You\'re doing amazing, $name! 🎯',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pulse Score Today',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${todayScore.toStringAsFixed(1)}/100',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: gainColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  gainText,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: gainColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Progress isn\'t just the number on the scale. It\'s the effort you\'re putting in every single day.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _GrowthGraph extends StatelessWidget {
  const _GrowthGraph({
    required this.metrics,
    required this.tabController,
    required this.isFriendly,
    required this.colors,
    required this.scheme,
  });

  final List<WellnessMetric> metrics;
  final TabController tabController;
  final bool isFriendly;
  final FitPulseColors colors;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final scores = metrics.map(PulseScoreAlgorithm.calculateDaily).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: '7 Days'),
            Tab(text: '30 Days'),
            Tab(text: 'All Time'),
          ],
          labelStyle: Theme.of(context).textTheme.labelLarge,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: TabBarView(
            controller: tabController,
            children: [
              _GraphView(
                scores: scores,
                metrics: metrics,
                isFriendly: isFriendly,
                colors: colors,
                scheme: scheme,
              ),
              _GraphView(
                scores: scores,
                metrics: metrics,
                isFriendly: isFriendly,
                colors: colors,
                scheme: scheme,
              ),
              _GraphView(
                scores: scores,
                metrics: metrics,
                isFriendly: isFriendly,
                colors: colors,
                scheme: scheme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GraphView extends StatelessWidget {
  const _GraphView({
    required this.scores,
    required this.metrics,
    required this.isFriendly,
    required this.colors,
    required this.scheme,
  });

  final List<double> scores;
  final List<WellnessMetric> metrics;
  final bool isFriendly;
  final FitPulseColors colors;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return Center(
        child: Text(
          'No data yet',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return Stack(
      children: [
        // Grid lines (faint)
        for (var i = 0; i <= 4; i++)
          Positioned(
            left: 0,
            right: 0,
            top: (i * 180 / 4).toDouble(),
            child: Container(
              height: 0.5,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),

        // Y-axis labels
        Positioned(
          left: 0,
          top: 0,
          child: Text(
            '100',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Text(
            '0',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),

        // Bars and milestone markers
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < scores.length; i++)
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Bar
                        Container(
                          width: 24,
                          height: (scores[i] / 100 * 180).toDouble(),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius:
                                BorderRadius.circular(isFriendly ? 8 : 4),
                          ),
                        ),

                        // Milestone marker (↑ if improved >5 points from yesterday)
                        if (i > 0 &&
                            PulseScoreAlgorithm.isMilestoneDay(
                              metrics[i - 1],
                              metrics[i],
                            ))
                          Positioned(
                            bottom: (scores[i] / 100 * 180) + 10,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: colors.success,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
