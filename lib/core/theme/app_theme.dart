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
      AppThemeVariant.graphite => _graphite,
      AppThemeVariant.studioLilac => _studioLilac,
      AppThemeVariant.softArcade => _softArcade,
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

  static const _graphite = _ThemePalette(
    brightness: Brightness.dark,
    primary: Color(0xFF4D8DFF),
    secondary: Color(0xFF55D6A5),
    tertiary: Color(0xFFFFB35A),
    friendly: false,
    colors: FitPulseColors(
      background: Color(0xFF111418),
      panel: Color(0xFF1B2027),
      success: Color(0xFF55D6A5),
      warning: Color(0xFFFFB35A),
      danger: Color(0xFFFF6577),
      glow: Color(0xFF244F91),
    ),
  );

  static const _studioLilac = _ThemePalette(
    brightness: Brightness.light,
    primary: Color(0xFFB69AE8),
    secondary: Color(0xFFF1C9D4),
    tertiary: Color(0xFFEF405F),
    friendly: false,
    colors: FitPulseColors(
      background: Color(0xFFF1F0EF),
      panel: Color(0xFFFFFFFF),
      success: Color(0xFF78A883),
      warning: Color(0xFFE0A84A),
      danger: Color(0xFFEF405F),
      glow: Color(0xFFDCC8F5),
    ),
  );

  static const _softArcade = _ThemePalette(
    brightness: Brightness.light,
    primary: Color(0xFF6F63D9),
    secondary: Color(0xFFFF9B86),
    tertiary: Color(0xFF68C4BF),
    friendly: true,
    fontFamily: 'Fredoka',
    colors: FitPulseColors(
      background: Color(0xFFFFF9F3),
      panel: Color(0xFFFFFFFF),
      success: Color(0xFF55B99D),
      warning: Color(0xFFF5C15B),
      danger: Color(0xFFE96F79),
      glow: Color(0xFFD8D1FF),
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
