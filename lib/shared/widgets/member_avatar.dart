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
    final avatarId = profile?.avatarId ?? 0;
    if (avatarId == 0) {
      final portraitIndex = switch (theme) {
        AppThemeVariant.graphite => 0,
        AppThemeVariant.studioLilac => 1,
        AppThemeVariant.softArcade => 2,
        AppThemeVariant.cosmicPulse => 1,
        null => 0,
      };
      return _ThemePortrait(radius: radius, index: portraitIndex);
    }
    final icon = icons[avatarId.clamp(0, icons.length - 1)];
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      child: Icon(icon, size: radius),
    );
  }
}

class _ThemePortrait extends StatelessWidget {
  const _ThemePortrait({required this.radius, required this.index});

  final double radius;
  final int index;

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    return SizedBox(
      width: diameter,
      height: diameter,
      child: ClipOval(
        child: OverflowBox(
          alignment: Alignment(index - 1, 0),
          maxWidth: diameter * 3,
          maxHeight: diameter * 1.5,
          child: Image.asset(
            'assets/avatars/theme-portraits.png',
            width: diameter * 3,
            height: diameter * 1.5,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
