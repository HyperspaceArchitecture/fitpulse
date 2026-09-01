import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:fitpulse/core/theme/theme_controller.dart';
import 'package:fitpulse/core/theme/theme_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_theme_preferences.dart';

void main() {
  test('loads and persists the selected theme', () async {
    final preferences = InMemoryThemePreferences();
    final container = ProviderContainer(
      overrides: [themePreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(themeControllerProvider.future),
      AppThemeVariant.pulseBlue,
    );

    await container
        .read(themeControllerProvider.notifier)
        .select(AppThemeVariant.ochre);

    expect(
      container.read(themeControllerProvider).value,
      AppThemeVariant.ochre,
    );
    expect(preferences.value, AppThemeVariant.ochre);
  });
}
