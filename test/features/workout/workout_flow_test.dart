import 'package:fitpulse/app.dart';
import 'package:fitpulse/core/theme/theme_preferences.dart';
import 'package:fitpulse/features/onboarding/data/profile_repository.dart';
import 'package:fitpulse/features/workout/data/workout_history_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/in_memory_profile_repository.dart';
import '../../helpers/in_memory_theme_preferences.dart';
import '../../helpers/in_memory_workout_history_repository.dart';

void main() {
  testWidgets('opens a plan and completes the first set', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themePreferencesProvider.overrideWithValue(
            InMemoryThemePreferences(),
          ),
          profileRepositoryProvider.overrideWithValue(
            InMemoryProfileRepository(),
          ),
          workoutHistoryRepositoryProvider.overrideWithValue(
            InMemoryWorkoutHistoryRepository(),
          ),
        ],
        child: const FitPulseApp(),
      ),
    );
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.byType(Scaffold))).go('/workouts');
    await tester.pumpAndSettle();

    expect(find.text('Session plan'), findsOneWidget);
    expect(find.text('Goblet squat'), findsOneWidget);

    await tester.ensureVisible(find.text('Start workout'));
    await tester.tap(find.text('Start workout'));
    await tester.pumpAndSettle();
    expect(find.text('8–10 reps'), findsOneWidget);

    await tester.ensureVisible(find.text('Begin first set'));
    await tester.tap(find.text('Begin first set'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('complete-set')));
    await tester.tap(find.byKey(const Key('complete-set')));
    await tester.pump();

    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('1/16 sets'), findsOneWidget);
    expect(find.text('Skip rest'), findsOneWidget);
  });
}
