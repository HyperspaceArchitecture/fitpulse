import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:fitpulse/core/theme/theme_preferences.dart';

/// Deterministic theme persistence used by unit and widget tests.
class InMemoryThemePreferences implements ThemePreferences {
  /// Creates memory-backed preferences with an optional initial theme.
  InMemoryThemePreferences([this.value = AppThemeVariant.pulseBlue]);

  /// Currently persisted theme.
  AppThemeVariant value;

  @override
  Future<AppThemeVariant> read() async => value;

  @override
  Future<void> write(AppThemeVariant variant) async {
    value = variant;
  }
}
