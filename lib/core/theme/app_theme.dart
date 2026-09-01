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
      AppThemeVariant.pulseBlue => _pulseBlue,
      AppThemeVariant.studioLilac => _studioLilac,
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
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.colors.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      extensions: [palette.colors],
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      cardTheme: CardThemeData(
        color: palette.colors.panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 46,
        height: 0.96,
        fontWeight: FontWeight.w900,
        letterSpacing: -2.2,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -1.1,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  static const _pulseBlue = _ThemePalette(
    brightness: Brightness.light,
    primary: Color(0xFF91F313),
    secondary: Color(0xFFFF8E93),
    tertiary: Color(0xFF34C6D3),
    colors: FitPulseColors(
      background: Color(0xFFF0F0EE),
      panel: Color(0xFFFFFFFF),
      success: Color(0xFF35B86B),
      warning: Color(0xFFFFBF45),
      danger: Color(0xFFE74962),
      glow: Color(0xFF91F313),
    ),
  );

  static const _studioLilac = _ThemePalette(
    brightness: Brightness.light,
    primary: Color(0xFFB69AE8),
    secondary: Color(0xFFF1C9D4),
    tertiary: Color(0xFFEF405F),
    colors: FitPulseColors(
      background: Color(0xFFF1F0EF),
      panel: Color(0xFFFFFFFF),
      success: Color(0xFF78A883),
      warning: Color(0xFFE0A84A),
      danger: Color(0xFFEF405F),
      glow: Color(0xFFDCC8F5),
    ),
  );
}

class _ThemePalette {
  const _ThemePalette({
    required this.brightness,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.colors,
  });

  final Brightness brightness;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final FitPulseColors colors;
}
