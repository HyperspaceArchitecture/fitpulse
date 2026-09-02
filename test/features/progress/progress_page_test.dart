import 'package:fitpulse/app.dart';
import 'package:fitpulse/core/theme/theme_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/in_memory_theme_preferences.dart';

void main() {
  testWidgets('opens holistic progress and shows scale and non-scale wins', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themePreferencesProvider.overrideWithValue(
            InMemoryThemePreferences(),
          ),
        ],
        child: const FitPulseApp(),
      ),
    );
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.byType(Scaffold))).go('/progress');
    await tester.pumpAndSettle();

    expect(find.text('Progress is more than the scale.'), findsOneWidget);
    expect(find.text('WEIGHT'), findsOneWidget);
    expect(find.text('Wins beyond weight'), findsOneWidget);
    expect(find.text('Strength'), findsOneWidget);
    expect(find.text('Resting HR'), findsOneWidget);
  });
}
