import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:fitpulse/core/theme/theme_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads, applies, and persists the active FitPulse visual system.
class ThemeController extends AsyncNotifier<AppThemeVariant> {
  @override
  Future<AppThemeVariant> build() {
    return ref.watch(themePreferencesProvider).read();
  }

  /// Applies and saves [variant] with immediate optimistic feedback.
  Future<void> select(AppThemeVariant variant) async {
    if (state.value == variant) return;

    final previous = state;
    state = AsyncData(variant);
    try {
      await ref.read(themePreferencesProvider).write(variant);
    } on Object catch (error, stackTrace) {
      state = previous;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

/// Exposes the selected theme and its persistence operations.
final themeControllerProvider =
    AsyncNotifierProvider<ThemeController, AppThemeVariant>(
      ThemeController.new,
    );
