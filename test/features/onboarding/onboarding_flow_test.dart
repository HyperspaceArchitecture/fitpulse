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
  testWidgets('creates and persists an offline fitness profile', (
    tester,
  ) async {
    final profiles = InMemoryProfileRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themePreferencesProvider.overrideWithValue(
            InMemoryThemePreferences(),
          ),
          profileRepositoryProvider.overrideWithValue(profiles),
        ],
        child: const FitPulseApp(),
      ),
    );
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.byType(Scaffold))).go('/register');
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Sam Taylor',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
      'sam@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Create password'),
      'StrongPass123',
    );
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.ensureVisible(find.text('Continue to profile'));
    await tester.tap(find.text('Continue to profile'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Build a plan that fits'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('onboarding-name')), 'Sam');

    for (var step = 0; step < 3; step += 1) {
      await tester.ensureVisible(
        find.byKey(const Key('onboarding-primary-action')),
      );
      await tester.tap(find.byKey(const Key('onboarding-primary-action')));
      await tester.pumpAndSettle();
    }

    expect(find.textContaining('Your body is context'), findsOneWidget);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.ensureVisible(find.text('Create my plan'));
    await tester.tap(find.text('Create my plan'));
    await tester.pumpAndSettle();

    expect(find.text('Ready, Sam?'), findsOneWidget);
    expect(profiles.value?.displayName, 'Sam');
    expect(profiles.value?.goal, FitnessGoal.buildStrength);
    expect(profiles.value?.currentWeightKg, 75);
  });
}
