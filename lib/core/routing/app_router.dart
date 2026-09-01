import 'package:fitpulse/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:fitpulse/features/auth/presentation/pages/register_page.dart';
import 'package:fitpulse/features/auth/presentation/pages/sign_in_page.dart';
import 'package:fitpulse/features/landing/presentation/pages/landing_page.dart';
import 'package:fitpulse/features/theme_preview/presentation/pages/theme_preview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Route paths used by the application.
abstract final class AppRoutes {
  /// Public product landing screen.
  static const landing = '/';

  /// Sign-in screen.
  static const signIn = '/sign-in';

  /// Account-creation screen.
  static const register = '/register';

  /// Password-recovery screen.
  static const forgotPassword = '/forgot-password';

  /// Interactive Today experience preview.
  static const today = '/today';
}

/// Owns the router and disposes it with the provider container.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.landing,
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.today,
        builder: (context, state) => const ThemePreviewPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_rounded, size: 48),
            const SizedBox(height: 16),
            Text(
              'Screen not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go(AppRoutes.landing),
              child: const Text('Return home'),
            ),
          ],
        ),
      ),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});
