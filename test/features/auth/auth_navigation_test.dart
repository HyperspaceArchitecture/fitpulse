import 'package:fitpulse/app.dart';
import 'package:fitpulse/core/theme/theme_preferences.dart';
import 'package:fitpulse/features/onboarding/data/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_profile_repository.dart';
import '../../helpers/in_memory_theme_preferences.dart';

void main() {
  testWidgets('starts at member home then navigates through auth screens', (
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

    expect(find.text('Your momentum'), findsOneWidget);
    expect(find.textContaining('better today'), findsOneWidget);
    await tester.tap(find.byTooltip('Product overview'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Train smarter.'), findsOneWidget);
    await tester.ensureVisible(find.text('Create your plan'));
    await tester.tap(find.text('Create your plan'));
    await tester.pumpAndSettle();

    expect(find.text('Build your plan'), findsOneWidget);
    await tester.ensureVisible(find.text('Sign in').last);
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    await tester.ensureVisible(find.text('Forgot password?'));
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset your password'), findsOneWidget);
    await tester.ensureVisible(find.text('Back to sign in'));
    await tester.tap(find.text('Back to sign in'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue offline'));
    await tester.tap(find.text('Continue offline'));
    await tester.pumpAndSettle();

    expect(find.text('Ready to move?'), findsOneWidget);
  });
}
