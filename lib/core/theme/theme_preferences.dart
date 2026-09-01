import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for the user's selected visual system.
abstract interface class ThemePreferences {
  /// Reads the saved theme, falling back to Volt Lime.
  Future<AppThemeVariant> read();

  /// Persists [variant] for future launches.
  Future<void> write(AppThemeVariant variant);
}

/// Stores the theme selection in platform-backed shared preferences.
class SharedPreferencesThemePreferences implements ThemePreferences {
  /// Creates a theme preference repository.
  SharedPreferencesThemePreferences(this._preferences);

  static const _key = 'appearance.theme_variant';
  final SharedPreferencesAsync _preferences;

  @override
  Future<AppThemeVariant> read() async {
    final storedValue = await _preferences.getString(_key);
    if (storedValue == 'ochre') return AppThemeVariant.studioLilac;
    return AppThemeVariant.values.firstWhere(
      (variant) => variant.name == storedValue,
      orElse: () => AppThemeVariant.pulseBlue,
    );
  }

  @override
  Future<void> write(AppThemeVariant variant) {
    return _preferences.setString(_key, variant.name);
  }
}

/// Provides the production theme persistence implementation.
final themePreferencesProvider = Provider<ThemePreferences>(
  (ref) => SharedPreferencesThemePreferences(SharedPreferencesAsync()),
);
