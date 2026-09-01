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
  /// Returns a dark, premium theme for [variant].
  static ThemeData forVariant(AppThemeVariant variant) {
    final palette = switch (variant) {
      AppThemeVariant.pulseBlue => _pulseBlue,
      AppThemeVariant.ochre => _ochre,
    };
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: Brightness.dark,
      primary: palette.primary,
      secondary: palette.secondary,
      surface: palette.colors.panel,
      error: palette.colors.danger,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
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
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
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
        fontSize: 42,
        height: 1.02,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.6,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  static const _pulseBlue = _ThemePalette(
    primary: Color(0xFF2E7DFF),
    secondary: Color(0xFF00C853),
    colors: FitPulseColors(
      background: Color(0xFF101214),
      panel: Color(0xFF171A1F),
      success: Color(0xFF00C853),
      warning: Color(0xFFFF9800),
      danger: Color(0xFFE53935),
      glow: Color(0xFF166FC1),
    ),
  );

  static const _ochre = _ThemePalette(
    primary: Color(0xFFD9A441),
    secondary: Color(0xFFF0C96A),
    colors: FitPulseColors(
      background: Color(0xFF14110C),
      panel: Color(0xFF211B12),
      success: Color(0xFF94B67A),
      warning: Color(0xFFE3A33B),
      danger: Color(0xFFE15B45),
      glow: Color(0xFF9A6820),
    ),
  );
}

class _ThemePalette {
  const _ThemePalette({
    required this.primary,
    required this.secondary,
    required this.colors,
  });

  final Color primary;
  final Color secondary;
  final FitPulseColors colors;
}
