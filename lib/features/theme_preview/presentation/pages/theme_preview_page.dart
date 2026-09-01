import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:fitpulse/core/theme/theme_controller.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/readiness_ring.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/theme_selector.dart';
import 'package:fitpulse/shared/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Production foundation screen for reviewing FitPulse design systems.
class ThemePreviewPage extends ConsumerWidget {
  /// Creates the responsive foundation screen.
  const ThemePreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<FitPulseColors>()!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -180,
            right: -120,
            child: _AmbientGlow(color: colors.glow),
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
                          const _Header(),
                          const SizedBox(height: 36),
                          _Overview(wide: constraints.maxWidth >= 760),
                          const SizedBox(height: 20),
                          const _Metrics(),
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
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 24,
      runSpacing: 20,
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
            Text('FITPULSE', style: theme.textTheme.titleLarge),
          ],
        ),
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const ThemeSelector(),
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.progress),
              icon: const Icon(Icons.insights_rounded),
              label: const Text('Progress'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Overview extends ConsumerWidget {
  const _Overview({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant =
        ref.watch(themeControllerProvider).value ?? AppThemeVariant.graphite;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          variant.description.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Text('Ready to move?', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 16),
        Text(
          'Your foundation is strong. Build momentum with a focused session tailored to today.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
    const ring = ReadinessRing(progress: 0.87);

    return GlassPanel(
      padding: const EdgeInsets.all(32),
      child: wide
          ? Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 48),
                ring,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [content, const SizedBox(height: 32), ring],
            ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 720
            ? (constraints.maxWidth - 40) / 3
            : constraints.maxWidth;
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _MetricCard(
              width: width,
              icon: Icons.favorite_rounded,
              label: 'RECOVERY',
              value: '82%',
              detail: 'Optimal range',
            ),
            _MetricCard(
              width: width,
              icon: Icons.local_fire_department_rounded,
              label: 'WEEKLY LOAD',
              value: '4.8',
              detail: 'Balanced',
            ),
            _MetricCard(
              width: width,
              icon: Icons.bedtime_rounded,
              label: 'SLEEP',
              value: '7h 42m',
              detail: '+28m this week',
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 28),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              detail,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color});

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
        child: const SizedBox.square(dimension: 520),
      ),
    );
  }
}
