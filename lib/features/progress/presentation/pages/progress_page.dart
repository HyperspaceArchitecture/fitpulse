import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/features/progress/application/progress_controller.dart';
import 'package:fitpulse/features/progress/data/progress_preview_data.dart';
import 'package:fitpulse/features/progress/domain/wellness_metric.dart';
import 'package:fitpulse/features/progress/domain/wellness_score.dart';
import 'package:fitpulse/features/progress/presentation/widgets/wellness_chart.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/theme_selector.dart';
import 'package:fitpulse/shared/widgets/brand_mark.dart';
import 'package:fitpulse/shared/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Holistic progress screen that balances scale and non-scale outcomes.
class ProgressPage extends ConsumerWidget {
  /// Creates the progress screen.
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics =
        ref.watch(progressControllerProvider).value ??
        ProgressPreviewData.recentWeek;
    final colors = Theme.of(context).extension<FitPulseColors>()!;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -220,
            right: -140,
            child: _ProgressGlow(color: colors.glow),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth < 600 ? 20 : 40,
                    vertical: 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _ProgressHeader(),
                          const SizedBox(height: 42),
                          const _ProgressTitle(),
                          const SizedBox(height: 24),
                          _SummaryStrip(metrics: metrics),
                          const SizedBox(height: 20),
                          GlassPanel(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _ChartHeader(),
                                const SizedBox(height: 18),
                                WellnessChart(metrics: metrics),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const _NonScaleWins(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCheckIn(context, ref, metrics.last),
        icon: const Icon(Icons.add_chart_rounded),
        label: const Text('Log today'),
      ),
    );
  }

  Future<void> _showCheckIn(
    BuildContext context,
    WidgetRef ref,
    WellnessMetric latest,
  ) async {
    var exercise = latest.exercise;
    var sleep = latest.sleep;
    var nutrition = latest.nutrition;
    var weight = latest.weightKg;
    final metric = await showDialog<WellnessMetric>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Today’s check-in'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ScoreSlider(
                    label: 'Exercise quality',
                    value: exercise,
                    onChanged: (value) => setState(() => exercise = value),
                  ),
                  _ScoreSlider(
                    label: 'Sleep and recovery',
                    value: sleep,
                    onChanged: (value) => setState(() => sleep = value),
                  ),
                  _ScoreSlider(
                    label: 'Nutrition balance',
                    value: nutrition,
                    onChanged: (value) => setState(() => nutrition = value),
                  ),
                  _ScoreSlider(
                    label: 'Weight ${weight.toStringAsFixed(1)} kg',
                    value: weight,
                    minimum: 30,
                    maximum: 200,
                    onChanged: (value) => setState(() => weight = value),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Weight is recorded separately and never lowers your overall wellness score.',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                WellnessMetric(
                  date: DateTime.now(),
                  exercise: exercise,
                  sleep: sleep,
                  nutrition: nutrition,
                  weightKg: weight,
                ),
              ),
              child: const Text('Save check-in'),
            ),
          ],
        ),
      ),
    );
    if (metric != null) {
      await ref.read(progressControllerProvider.notifier).save(metric);
    }
  }
}

class _ScoreSlider extends StatelessWidget {
  const _ScoreSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    this.minimum = 0,
    this.maximum = 100,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double minimum;
  final double maximum;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$label · ${value.round()}'),
        Slider(
          value: value.clamp(minimum, maximum),
          min: minimum,
          max: maximum,
          divisions: (maximum - minimum).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filledTonal(
              tooltip: 'Back to landing',
              onPressed: () => context.go(AppRoutes.landing),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 12),
            const BrandMark(),
          ],
        ),
        const ThemeSelector(),
      ],
    );
  }
}

class _ProgressTitle extends StatelessWidget {
  const _ProgressTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'PROGRESS',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 10),
            const Chip(label: Text('PREVIEW DATA')),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Progress is more than the scale.',
          style: theme.textTheme.displaySmall,
        ),
        const SizedBox(height: 12),
        Text(
          'See how movement, sleep, nutrition, weight, and body signals improve together.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.metrics});

  final List<WellnessMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final current = metrics.last;
    final overall = WellnessScore.calculate(current).round();
    final weightChange = current.weightKg - metrics.first.weightKg;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _SummaryCard(
          icon: Icons.auto_graph_rounded,
          label: 'OVERALL',
          value: '$overall',
          detail: '+12 points this week',
        ),
        _SummaryCard(
          icon: Icons.monitor_weight_outlined,
          label: 'WEIGHT',
          value: '${current.weightKg.toStringAsFixed(1)} kg',
          detail: '${weightChange.toStringAsFixed(1)} kg this week',
        ),
        const _SummaryCard(
          icon: Icons.emoji_events_outlined,
          label: 'BEST WIN',
          value: '+8%',
          detail: 'Strength improved',
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: GlassPanel(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(detail, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {
  const _ChartHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FitPulseColors>()!;
    return Wrap(
      spacing: 20,
      runSpacing: 14,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your combined trend', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Last 7 days · tap any point',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _Legend(color: theme.colorScheme.primary, label: 'Overall'),
            _Legend(color: colors.success, label: 'Exercise'),
            _Legend(color: theme.colorScheme.tertiary, label: 'Sleep'),
            _Legend(color: colors.warning, label: 'Nutrition'),
            _Legend(color: theme.colorScheme.onSurface, label: 'Weight kg'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _NonScaleWins extends StatelessWidget {
  const _NonScaleWins();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Wins beyond weight',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Your weight can pause while fitness, recovery, and body composition keep improving.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Win(
                icon: Icons.fitness_center_rounded,
                value: '+8%',
                label: 'Strength',
              ),
              _Win(
                icon: Icons.straighten_rounded,
                value: '-1.2 cm',
                label: 'Waist',
              ),
              _Win(
                icon: Icons.favorite_outline_rounded,
                value: '-3 bpm',
                label: 'Resting HR',
              ),
              _Win(
                icon: Icons.calendar_month_rounded,
                value: '6/7',
                label: 'Consistency',
              ),
              _Win(
                icon: Icons.bedtime_outlined,
                value: '+42 min',
                label: 'Sleep',
              ),
              _Win(
                icon: Icons.energy_savings_leaf_outlined,
                value: '84',
                label: 'Recovery',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Win extends StatelessWidget {
  const _Win({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressGlow extends StatelessWidget {
  const _ProgressGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
          ),
        ),
        child: const SizedBox.square(dimension: 600),
      ),
    );
  }
}
