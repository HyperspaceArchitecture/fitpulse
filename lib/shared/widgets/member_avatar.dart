import 'package:fitpulse/features/onboarding/domain/fitness_profile.dart';
import 'package:flutter/material.dart';

/// Consistent member avatar used across home and settings.
class MemberAvatar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final avatarId = (profile?.avatarId ?? 0).clamp(0, icons.length - 1);
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      child: Icon(icons[avatarId], size: radius),
    );
  }
}
