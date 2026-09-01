import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/readiness_ring.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/theme_selector.dart';
import 'package:fitpulse/shared/widgets/brand_mark.dart';
import 'package:fitpulse/shared/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Premium first-run destination that introduces the FitPulse experience.
class LandingPage extends StatelessWidget {
  /// Creates the responsive landing page.
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FitPulseColors>()!;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -220,
            right: -100,
            child: _LandingGlow(color: colors.glow),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth < 600 ? 20 : 48,
                    vertical: 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _LandingHeader(),
                          SizedBox(height: wide ? 84 : 52),
                          wide
                              ? const Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: _HeroCopy()),
                                    SizedBox(width: 64),
                                    Expanded(child: _TodayCard()),
                                  ],
                                )
                              : const Column(
                                  children: [
                                    _HeroCopy(),
                                    SizedBox(height: 40),
                                    _TodayCard(),
                                  ],
                                ),
                          const SizedBox(height: 56),
                          const _ValueStrip(),
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

class _LandingHeader extends StatelessWidget {
  const _LandingHeader();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const BrandMark(),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const ThemeSelector(),
            TextButton(
              onPressed: () => context.go(AppRoutes.signIn),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR BODY. BETTER UNDERSTOOD.',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Train smarter.\nRecover stronger.',
          style: theme.textTheme.displaySmall?.copyWith(fontSize: 58),
        ),
        const SizedBox(height: 24),
        Text(
          'One intelligent fitness companion that adapts training, recovery, and nutrition to your real life.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.register),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Create your plan'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.today),
              icon: const Icon(Icons.visibility_rounded),
              label: const Text('Explore preview'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Wrap(
          spacing: 20,
          runSpacing: 10,
          children: [
            _TrustItem(icon: Icons.lock_rounded, label: 'Private by design'),
            _TrustItem(
              icon: Icons.offline_bolt_rounded,
              label: 'Offline ready',
            ),
            _TrustItem(
              icon: Icons.auto_awesome_rounded,
              label: 'Adaptive coaching',
            ),
          ],
        ),
      ],
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassPanel(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TODAY', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text('You are ready', style: theme.textTheme.headlineMedium),
                ],
              ),
              const ReadinessRing(progress: 0.87, size: 96),
            ],
          ),
          const SizedBox(height: 28),
          const _SessionRow(
            icon: Icons.directions_run_rounded,
            title: 'Strength + mobility',
            detail: '42 min · Moderate',
          ),
          const SizedBox(height: 12),
          const _SessionRow(
            icon: Icons.restaurant_rounded,
            title: 'Fuel your session',
            detail: 'Protein-forward breakfast',
          ),
          const SizedBox(height: 12),
          const _SessionRow(
            icon: Icons.bedtime_rounded,
            title: 'Recovery target',
            detail: '8h 10m sleep tonight',
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueStrip extends StatelessWidget {
  const _ValueStrip();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.spaceAround,
      runSpacing: 24,
      children: [
        _Value(value: '24/7', label: 'adaptive guidance'),
        _Value(value: '360°', label: 'health context'),
        _Value(value: '1', label: 'clear daily plan'),
      ],
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 7),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _LandingGlow extends StatelessWidget {
  const _LandingGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0)],
          ),
        ),
        child: const SizedBox.square(dimension: 620),
      ),
    );
  }
}
