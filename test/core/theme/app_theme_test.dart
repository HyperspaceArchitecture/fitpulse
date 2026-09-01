import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FitPulseTheme', () {
    test('builds the requested Volt Lime palette', () {
      final theme = FitPulseTheme.forVariant(AppThemeVariant.pulseBlue);
      final colors = theme.extension<FitPulseColors>()!;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, const Color(0xFF91F313));
      expect(theme.colorScheme.secondary, const Color(0xFFFF8E93));
      expect(theme.colorScheme.tertiary, const Color(0xFF34C6D3));
      expect(colors.background, const Color(0xFFF0F0EE));
    });

    test('builds a distinct Studio Lilac palette', () {
      final theme = FitPulseTheme.forVariant(AppThemeVariant.studioLilac);
      final colors = theme.extension<FitPulseColors>()!;

      expect(theme.colorScheme.primary, const Color(0xFFB69AE8));
      expect(theme.colorScheme.secondary, const Color(0xFFF1C9D4));
      expect(colors.background, const Color(0xFFF1F0EF));
      expect(colors.glow, const Color(0xFFDCC8F5));
    });
  });
}
