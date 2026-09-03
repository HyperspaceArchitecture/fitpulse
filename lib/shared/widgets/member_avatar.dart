import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:fitpulse/core/theme/theme_controller.dart';
import 'package:fitpulse/features/onboarding/domain/fitness_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Consistent member avatar used across home and settings.
class MemberAvatar extends ConsumerWidget {
  /// Creates a member avatar.
  const MemberAvatar({required this.profile, this.radius = 46, super.key});

  /// Profile supplying the avatar style.
  final FitnessProfile? profile;

  /// Circle radius.
  final double radius;

  /// Available friendly avatar glyphs.
  static const icons = <IconData>[
    Icons.person_rounded,
    Icons.sentiment_satisfied_alt_rounded,
    Icons.face_rounded,
    Icons.sports_gymnastics_rounded,
    Icons.hiking_rounded,
    Icons.self_improvement_rounded,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider).value;
    final defaultIcon = switch (theme) {
      AppThemeVariant.graphite => Icons.person_rounded,
      AppThemeVariant.studioLilac => Icons.face_rounded,
      AppThemeVariant.softArcade => Icons.face_3_rounded,
      null => Icons.person_rounded,
    };
    final avatarId = profile?.avatarId ?? 0;
    final icon = avatarId == 0
        ? defaultIcon
        : icons[avatarId.clamp(0, icons.length - 1)];
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      child: Icon(icon, size: radius),
    );
  }
}
