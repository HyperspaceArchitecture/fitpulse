import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for the user's selected visual system.
abstract interface class ThemePreferences {
  /// Reads the saved theme, falling back to Athletic Dark.
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
    // Migrate legacy theme identifiers from earlier builds.
    const legacy = <String, AppThemeVariant>{
      'ochre': AppThemeVariant.illustratedSoft,
      'pulseBlue': AppThemeVariant.athleticDark,
      'cloudPop': AppThemeVariant.illustratedSoft,
      'graphite': AppThemeVariant.athleticDark,
      'studioLilac': AppThemeVariant.illustratedSoft,
      'softArcade': AppThemeVariant.illustratedSoft,
      'cosmicPulse': AppThemeVariant.proAthlete,
    };
    final migrated = legacy[storedValue];
    if (migrated != null) return migrated;
    return AppThemeVariant.values.firstWhere(
      (variant) => variant.name == storedValue,
      orElse: () => AppThemeVariant.athleticDark,
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
