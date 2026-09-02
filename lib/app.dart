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
        ref.watch(themeControllerProvider).value ?? AppThemeVariant.graphite;

    return MaterialApp.router(
      title: 'FitPulse AI',
      debugShowCheckedModeBanner: false,
      theme: FitPulseTheme.forVariant(selectedTheme),
      darkTheme: FitPulseTheme.forVariant(selectedTheme),
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        if (Uri.base.queryParameters['preview'] != 'phone' || child == null) {
          return child ?? const SizedBox.shrink();
        }
        return _PhonePreviewFrame(child: child);
      },
    );
  }
}

class _PhonePreviewFrame extends StatelessWidget {
  const _PhonePreviewFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const previewSize = Size(390, 844);
    final media = MediaQuery.of(context);
    return ColoredBox(
      color: const Color(0xFFE9E7E3),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: SizedBox.fromSize(
              size: previewSize,
              child: MediaQuery(
                data: media.copyWith(size: previewSize),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
