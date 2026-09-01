import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/core/theme/app_theme_variant.dart';
import 'package:fitpulse/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget that composes routing, theming, and application-level state.
class FitPulseApp extends ConsumerWidget {
  /// Creates the FitPulse application root.
  const FitPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final selectedTheme =
        ref.watch(themeControllerProvider).value ?? AppThemeVariant.pulseBlue;

    return MaterialApp.router(
      title: 'FitPulse AI',
      debugShowCheckedModeBanner: false,
      theme: FitPulseTheme.forVariant(selectedTheme),
      darkTheme: FitPulseTheme.forVariant(selectedTheme),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
