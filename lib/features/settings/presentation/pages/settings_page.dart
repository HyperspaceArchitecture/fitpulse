import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/features/onboarding/application/profile_controller.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/theme_selector.dart';
import 'package:fitpulse/shared/widgets/brand_mark.dart';
import 'package:fitpulse/shared/widgets/glass_panel.dart';
import 'package:fitpulse/shared/widgets/member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Local member preferences and privacy controls.
class SettingsPage extends ConsumerWidget {
  /// Creates the settings page.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider).value;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
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
                    'SETTINGS',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make FitPulse yours.',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 24),
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Your avatar',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          profile == null
                              ? 'Complete your profile first, then choose the avatar shown on your home screen.'
                              : 'Choose the character that greets you on the home screen.',
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: List.generate(MemberAvatar.icons.length, (
                            index,
                          ) {
                            final selected = profile?.avatarId == index;
                            return InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: profile == null
                                  ? null
                                  : () => ref
                                        .read(
                                          profileControllerProvider.notifier,
                                        )
                                        .save(
                                          profile.copyWith(avatarId: index),
                                        ),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  child: Icon(MemberAvatar.icons[index]),
                                ),
                              ),
                            );
                          }),
                        ),
                        if (profile == null) ...[
                          const SizedBox(height: 18),
                          FilledButton.tonal(
                            onPressed: () => context.go(AppRoutes.onboarding),
                            child: const Text('Create fitness profile'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Privacy',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const _PrivacyRow(
                          title: 'Storage',
                          detail: 'Fitness profile, workouts, nutrition and appearance stay on this device.',
                        ),
                        const _PrivacyRow(
                          title: 'AI Coach',
                          detail: 'Current coaching runs offline and does not transmit conversations.',
                        ),
                        const _PrivacyRow(
                          title: 'Credentials',
                          detail: 'Preview sign-in never stores or sends passwords.',
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: profile == null
                              ? null
                              : () => _confirmClear(context, ref),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Delete local profile'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.admin),
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('Administrator portal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete local profile?'),
        content: const Text(
          'This removes your onboarding profile from this device. Workout and nutrition history are not changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete profile'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(profileControllerProvider.notifier).clear();
    }
  }
}

class _PrivacyRow extends StatelessWidget {
  const _PrivacyRow({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle_outline_rounded),
      title: Text(title),
      subtitle: Text(detail),
    );
  }
}
