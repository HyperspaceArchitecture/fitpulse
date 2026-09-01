import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FitPulseTheme', () {
    test('builds the requested Graphite palette', () {
      final theme = FitPulseTheme.forVariant(AppThemeVariant.graphite);
      final colors = theme.extension<FitPulseColors>()!;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, const Color(0xFF4D8DFF));
      expect(theme.colorScheme.secondary, const Color(0xFF55D6A5));
      expect(theme.colorScheme.tertiary, const Color(0xFFFFB35A));
      expect(colors.background, const Color(0xFF111418));
    });

    test('builds a distinct Studio Lilac palette', () {
      final theme = FitPulseTheme.forVariant(AppThemeVariant.studioLilac);
      final colors = theme.extension<FitPulseColors>()!;

      expect(theme.colorScheme.primary, const Color(0xFFB69AE8));
      expect(theme.colorScheme.secondary, const Color(0xFFF1C9D4));
      expect(colors.background, const Color(0xFFF1F0EF));
      expect(colors.glow, const Color(0xFFDCC8F5));
    });

    test('builds a friendly Cloud Pop palette', () {
      final theme = FitPulseTheme.forVariant(AppThemeVariant.cloudPop);
      final colors = theme.extension<FitPulseColors>()!;

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, const Color(0xFF76B7A3));
      expect(theme.colorScheme.secondary, const Color(0xFFF3B5A7));
      expect(theme.colorScheme.tertiary, const Color(0xFF88B5E4));
      expect(colors.background, const Color(0xFFF3F7F4));
    });
  });
}
