import 'package:fitpulse/app.dart';
import 'package:fitpulse/core/theme/theme_preferences.dart';
import 'package:fitpulse/features/onboarding/data/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/in_memory_profile_repository.dart';
import '../../helpers/in_memory_theme_preferences.dart';

void main() {
  testWidgets('opens private coach and responds to a recovery question', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themePreferencesProvider.overrideWithValue(
            InMemoryThemePreferences(),
          ),
          profileRepositoryProvider.overrideWithValue(
            InMemoryProfileRepository(),
          ),
        ],
        child: const FitPulseApp(),
      ),
    );
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.byType(Scaffold))).go('/coach');
    await tester.pumpAndSettle();

    expect(find.text('AI Coach'), findsOneWidget);
    expect(find.textContaining('Offline guidance'), findsOneWidget);
    expect(find.text('PRIVATE'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('coach-message-field')),
      'I feel tired and need recovery help',
    );
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();

    expect(find.text('I feel tired and need recovery help'), findsOneWidget);
    expect(find.textContaining('reduce load by about 10–20%'), findsOneWidget);
  });
}
