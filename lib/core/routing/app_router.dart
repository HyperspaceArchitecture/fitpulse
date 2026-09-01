import 'package:fitpulse/features/theme_preview/presentation/pages/theme_preview_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Route paths used by the application.
abstract final class AppRoutes {
  /// Foundation and theme review route.
  static const foundation = '/';
}

/// Owns the router and disposes it with the provider container.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.foundation,
    routes: [
      GoRoute(
        path: AppRoutes.foundation,
        builder: (context, state) => const ThemePreviewPage(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
