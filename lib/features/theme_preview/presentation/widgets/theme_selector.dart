import 'dart:async';

import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:fitpulse/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Accessible two-option control for testing FitPulse visual systems.
class ThemeSelector extends ConsumerWidget {
  /// Creates the theme selector.
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeControllerProvider);
    final selected = state.value ?? AppThemeVariant.pulseBlue;

    return SegmentedButton<AppThemeVariant>(
      showSelectedIcon: false,
      segments: AppThemeVariant.values
          .map(
            (variant) => ButtonSegment(
              value: variant,
              icon: Icon(
                variant == AppThemeVariant.pulseBlue
                    ? Icons.water_drop_rounded
                    : Icons.wb_sunny_rounded,
              ),
              label: Text(variant.label),
            ),
          )
          .toList(growable: false),
      selected: {selected},
      onSelectionChanged: state.isLoading
          ? null
          : (selection) {
              unawaited(
                ref
                    .read(themeControllerProvider.notifier)
                    .select(selection.single),
              );
            },
    );
  }
}
