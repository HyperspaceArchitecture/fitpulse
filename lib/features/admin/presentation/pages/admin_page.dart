import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/theme_selector.dart';
import 'package:fitpulse/shared/widgets/brand_mark.dart';
import 'package:fitpulse/shared/widgets/glass_panel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Production-safe admin shell with a debug-only local preview.
class AdminPage extends StatefulWidget {
  /// Creates the admin portal.
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _previewUnlocked = false;

  @override
  Widget build(BuildContext context) {
    if (!_previewUnlocked) {
      return _AdminGate(
        onPreview: kDebugMode
            ? () => setState(() => _previewUnlocked = true)
            : null,
      );
    }
    return const _AdminDashboard();
  }
}

class _AdminGate extends StatelessWidget {
  const _AdminGate({required this.onPreview});

  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: GlassPanel(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const BrandMark(),
                    const SizedBox(height: 28),
                    const Icon(Icons.admin_panel_settings_outlined, size: 54),
                    const SizedBox(height: 16),
                    Text(
                      'Administrator access',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'A trusted server must verify administrator roles. FitPulse intentionally denies production access until a backend identity provider is connected.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    if (onPreview != null)
                      FilledButton.icon(
                        onPressed: onPreview,
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('Open debug preview'),
                      )
                    else
                      const Chip(label: Text('ACCESS NOT CONFIGURED')),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.settings),
                      child: const Text('Back to settings'),
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

class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => context.go(AppRoutes.settings),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 12),
                      const BrandMark(),
                      const Spacer(),
                      const Chip(label: Text('DEBUG PREVIEW')),
                      const SizedBox(width: 12),
                      const ThemeSelector(),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'OPERATIONS',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FitPulse control room',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 22),
                  const Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _AdminStat(
                        label: 'ACTIVE MEMBERS',
                        value: '—',
                        detail: 'Backend required',
                      ),
                      _AdminStat(
                        label: 'WORKOUTS TODAY',
                        value: '—',
                        detail: 'Backend required',
                      ),
                      _AdminStat(
                        label: 'COACH SAFETY FLAGS',
                        value: '0',
                        detail: 'Local preview',
                      ),
                      _AdminStat(
                        label: 'CONTENT REVIEWS',
                        value: '6',
                        detail: 'Exercise videos',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'System readiness',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        const _StatusRow(
                          label: 'Offline member experience',
                          ready: true,
                        ),
                        const _StatusRow(
                          label: 'Local privacy controls',
                          ready: true,
                        ),
                        const _StatusRow(
                          label: 'Exercise content library',
                          ready: true,
                        ),
                        const _StatusRow(
                          label: 'Server authentication and roles',
                          ready: false,
                        ),
                        const _StatusRow(
                          label: 'Cross-device data sync',
                          ready: false,
                        ),
                        const _StatusRow(
                          label: 'Push messaging delivery',
                          ready: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  const _AdminStat({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: GlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(detail, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.ready});

  final String label;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        ready ? Icons.check_circle_rounded : Icons.pending_outlined,
        color: ready ? Colors.green : Theme.of(context).colorScheme.tertiary,
      ),
      title: Text(label),
      trailing: Text(ready ? 'Ready' : 'Needs backend'),
    );
  }
}
