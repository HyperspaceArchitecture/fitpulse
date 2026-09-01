import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FitPulseTheme', () {
    test('builds the requested Pulse Blue palette', () {
      final theme = FitPulseTheme.forVariant(AppThemeVariant.pulseBlue);
      final colors = theme.extension<FitPulseColors>()!;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, const Color(0xFF2E7DFF));
      expect(colors.background, const Color(0xFF101214));
    });

    test('builds a distinct ochre palette', () {
      final theme = FitPulseTheme.forVariant(AppThemeVariant.ochre);
      final colors = theme.extension<FitPulseColors>()!;

      expect(theme.colorScheme.primary, const Color(0xFFD9A441));
      expect(colors.background, const Color(0xFF14110C));
      expect(colors.glow, const Color(0xFF9A6820));
    });
  });
}
