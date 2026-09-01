import 'package:fitpulse/app.dart';
import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:fitpulse/core/theme/theme_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_theme_preferences.dart';

void main() {
  testWidgets('switches from Pulse Blue to Ochre and persists the choice', (
    tester,
  ) async {
    final preferences = InMemoryThemePreferences();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [themePreferencesProvider.overrideWithValue(preferences)],
        child: const FitPulseApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ready to move?'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).colorScheme.primary,
      const Color(0xFF2E7DFF),
    );

    await tester.tap(find.text('Ochre'));
    await tester.pumpAndSettle();

    expect(preferences.value, AppThemeVariant.ochre);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).colorScheme.primary,
      const Color(0xFFD9A441),
    );
  });
}
