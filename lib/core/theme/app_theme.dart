import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:flutter/material.dart';

/// Semantic colors that extend Material's standard color scheme.
@immutable
class FitPulseColors extends ThemeExtension<FitPulseColors> {
  /// Creates FitPulse semantic colors.
  const FitPulseColors({
    required this.background,
    required this.panel,
    required this.success,
    required this.warning,
    required this.danger,
    required this.glow,
  });

  /// Deepest application canvas color.
  final Color background;

  /// Elevated glass panel base color.
  final Color panel;

  /// Positive state and completion color.
  final Color success;

  /// Attention state color.
  final Color warning;

  /// Destructive or critical state color.
  final Color danger;

  /// Atmospheric accent used for subtle background light.
  final Color glow;

  @override
  FitPulseColors copyWith({
    Color? background,
    Color? panel,
    Color? success,
    Color? warning,
    Color? danger,
    Color? glow,
  }) {
    return FitPulseColors(
      background: background ?? this.background,
      panel: panel ?? this.panel,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      glow: glow ?? this.glow,
    );
  }

  @override
  FitPulseColors lerp(covariant FitPulseColors? other, double t) {
    if (other == null) return this;
    return FitPulseColors(
      background: Color.lerp(background, other.background, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }
}

/// Builds the complete Material 3 design system for each FitPulse theme.
abstract final class FitPulseTheme {
  /// Returns the premium editorial theme for [variant].
  static ThemeData forVariant(AppThemeVariant variant) {
    final palette = switch (variant) {
      AppThemeVariant.athleticDark => _athleticDark,
      AppThemeVariant.illustratedSoft => _illustratedSoft,
      AppThemeVariant.proAthlete => _proAthlete,
    };
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: palette.brightness,
      primary: palette.primary,
      secondary: palette.secondary,
      tertiary: palette.tertiary,
      surface: palette.colors.panel,
      error: palette.colors.danger,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      fontFamily: palette.fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.colors.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      extensions: [palette.colors],
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, friendly: palette.friendly),
      cardTheme: CardThemeData(
        color: palette.colors.panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(palette.friendly ? 30 : 24),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(palette.friendly ? 24 : 16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.68),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(palette.friendly ? 22 : 16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(palette.friendly ? 22 : 16),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(palette.friendly ? 22 : 16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(palette.friendly ? 24 : 16),
          ),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, {required bool friendly}) {
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontSize: friendly ? 42 : 46,
        height: friendly ? 1.05 : 0.96,
        fontWeight: friendly ? FontWeight.w800 : FontWeight.w900,
        letterSpacing: friendly ? -1.1 : -2.2,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: friendly ? FontWeight.w800 : FontWeight.w900,
        letterSpacing: friendly ? -0.5 : -1.1,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: friendly ? FontWeight.w800 : FontWeight.w900,
        letterSpacing: friendly ? -0.2 : -0.5,
      ),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  /// Athletic Dark Theme
  /// Midnight navy canvas with ignite orange primary.
  /// Heavy Barlow Condensed typography, ALL CAPS labels.
  /// Dark panels with left accent bands + sport character poses.
  static const _athleticDark = _ThemePalette(
    brightness: Brightness.dark,
    primary: Color(0xFFFF4D00), // Ignite Orange
    secondary: Color(0xFF55D6A5), // Pulse Green
    tertiary: Color(0xFFFFB35A), // Warm Amber
    friendly: false,
    fontFamily: 'BarlowCondensed',
    colors: FitPulseColors(
      background: Color(0xFF1A1A2E), // Midnight Navy
      panel: Color(0xFF252540), // Dark Panel
      success: Color(0xFF55D6A5), // Pulse Green
      warning: Color(0xFFFFB35A), // Warm Amber (recovery)
      danger: Color(0xFFFF6B7A), // Alert Red
      glow: Color(0xFFFF4D00), // Ignite Orange glow
    ),
  );

  /// Illustrated Soft Theme
  /// Warm cream background with rose pulse primary.
  /// Rounded pills, emoji faces, pastel category cards.
  /// Illustrated characters with expressive faces.
  static const _illustratedSoft = _ThemePalette(
    brightness: Brightness.light,
    primary: Color(0xFFD4537E), // Rose Pulse (cardio/energy)
    secondary: Color(0xFF7F77DD), // Lavender Lift (strength)
    tertiary: Color(0xFF1D9E75), // Mint Growth (nutrition)
    friendly: true,
    fontFamily: 'Fredoka',
    colors: FitPulseColors(
      background: Color(0xFFFFF6F0), // Warm Cream
      panel: Color(0xFFFFFFFF), // White card
      success: Color(0xFF1D9E75), // Mint Growth
      warning: Color(0xFFEF9F27), // Sun Energy (recovery)
      danger: Color(0xFFE96B7A), // Coral Red
      glow: Color(0xFFD4537E), // Rose Pulse glow
    ),
  );

  /// Pro Athlete Theme
  /// Deep green-black canvas with emerald primary.
  /// Tight geometry, clinical metric readouts, instrument-panel iconography.
  /// Performance data over motivation: HRV, readiness, RPE, session load.
  static const _proAthlete = _ThemePalette(
    brightness: Brightness.dark,
    primary: Color(0xFF10B981), // Emerald
    secondary: Color(0xFF5EEAD4), // Aqua Signal
    tertiary: Color(0xFF84CC16), // Lime Readout
    friendly: false,
    fontFamily: 'BarlowCondensed',
    colors: FitPulseColors(
      background: Color(0xFF07100D), // Deep Green-Black
      panel: Color(0xFF0E2621), // Instrument Panel
      success: Color(0xFF10B981), // Emerald
      warning: Color(0xFFFBBF24), // Caution Amber
      danger: Color(0xFFF87171), // Alert Red
      glow: Color(0xFF10B981), // Emerald glow
    ),
  );
}

class _ThemePalette {
  const _ThemePalette({
    required this.brightness,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.friendly,
    required this.colors,
    this.fontFamily,
  });

  final Brightness brightness;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final bool friendly;
  final FitPulseColors colors;
  final String? fontFamily;
}
