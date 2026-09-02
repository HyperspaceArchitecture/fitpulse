import 'package:fitpulse/app.dart';
import 'package:fitpulse/core/theme/theme_preferences.dart';
import 'package:fitpulse/features/onboarding/data/profile_repository.dart';
import 'package:fitpulse/features/onboarding/domain/fitness_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/in_memory_profile_repository.dart';
import '../../helpers/in_memory_theme_preferences.dart';

void main() {
  testWidgets('shows a personalized dashboard and progress navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final profile = FitnessProfile(
      displayName: 'Sam',
      goal: FitnessGoal.buildStrength,
      experience: TrainingExperience.intermediate,
      trainingDaysPerWeek: 4,
      sessionMinutes: 45,
      equipment: const {Equipment.dumbbells},
      heightCm: 170,
      currentWeightKg: 75,
      targetWeightKg: null,
      sleepHours: 7.5,
      completedAt: DateTime.utc(2026, 9, 2),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themePreferencesProvider.overrideWithValue(
            InMemoryThemePreferences(),
          ),
          profileRepositoryProvider.overrideWithValue(
            InMemoryProfileRepository(profile),
          ),
        ],
        child: const FitPulseApp(),
      ),
    );
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.byType(Scaffold))).go('/dashboard');
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Train'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Coach'), findsOneWidget);
    expect(find.text('Ready, Sam?'), findsOneWidget);
    expect(find.text('Strength + mobility'), findsOneWidget);
    expect(find.text('Today’s signals'), findsOneWidget);
    expect(find.text('Your week'), findsOneWidget);

    await tester.ensureVisible(find.text('View all progress'));
    await tester.tap(find.text('View all progress'));
    await tester.pumpAndSettle();
    expect(find.text('Progress is more than the scale.'), findsOneWidget);
  });
}
