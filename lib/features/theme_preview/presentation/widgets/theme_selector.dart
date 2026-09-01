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
    final selected = state.value ?? AppThemeVariant.graphite;

    void select(AppThemeVariant variant) {
      unawaited(ref.read(themeControllerProvider.notifier).select(variant));
    }

    if (MediaQuery.sizeOf(context).width < 1100) {
      return PopupMenuButton<AppThemeVariant>(
        tooltip: 'Choose visual theme',
        enabled: !state.isLoading,
        initialValue: selected,
        onSelected: select,
        itemBuilder: (context) => AppThemeVariant.values
            .map(
              (variant) => PopupMenuItem(
                value: variant,
                child: Row(
                  children: [
                    Icon(_iconFor(variant)),
                    const SizedBox(width: 10),
                    Text(variant.label),
                  ],
                ),
              ),
            )
            .toList(growable: false),
        child: Chip(
          avatar: Icon(_iconFor(selected), size: 18),
          label: Text(selected.label),
        ),
      );
    }

    return SegmentedButton<AppThemeVariant>(
      showSelectedIcon: false,
      segments: AppThemeVariant.values
          .map(
            (variant) => ButtonSegment(
              value: variant,
              icon: Icon(_iconFor(variant)),
              label: Text(variant.label),
            ),
          )
          .toList(growable: false),
      selected: {selected},
      onSelectionChanged: state.isLoading
          ? null
          : (selection) => select(selection.single),
    );
  }

  IconData _iconFor(AppThemeVariant variant) => switch (variant) {
    AppThemeVariant.graphite => Icons.bolt_rounded,
    AppThemeVariant.studioLilac => Icons.auto_awesome_rounded,
    AppThemeVariant.softArcade => Icons.bubble_chart_rounded,
  };
}
