import 'package:fitpulse/features/admin/presentation/pages/admin_page.dart';
import 'package:fitpulse/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:fitpulse/features/auth/presentation/pages/register_page.dart';
import 'package:fitpulse/features/auth/presentation/pages/sign_in_page.dart';
import 'package:fitpulse/features/coach/presentation/pages/coach_page.dart';
import 'package:fitpulse/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:fitpulse/features/landing/presentation/pages/landing_page.dart';
import 'package:fitpulse/features/nutrition/presentation/pages/nutrition_page.dart';
import 'package:fitpulse/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:fitpulse/features/progress/presentation/pages/progress_page.dart';
import 'package:fitpulse/features/settings/presentation/pages/settings_page.dart';
import 'package:fitpulse/features/theme_preview/presentation/pages/theme_preview_page.dart';
import 'package:fitpulse/features/workout/presentation/pages/workout_plan_page.dart';
import 'package:fitpulse/features/workout/presentation/pages/workout_session_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Route paths used by the application.
abstract final class AppRoutes {
  /// Member startup screen.
  static const landing = '/';

  /// Public product introduction and authentication entry.
  static const welcome = '/welcome';

  /// Sign-in screen.
  static const signIn = '/sign-in';

  /// Account-creation screen.
  static const register = '/register';

  /// Password-recovery screen.
  static const forgotPassword = '/forgot-password';

  /// Offline-first fitness profile setup.
  static const onboarding = '/onboarding';

  /// Personalized daily member dashboard.
  static const dashboard = '/dashboard';

  /// Interactive Today experience preview.
  static const today = '/today';

  /// Holistic progress and body-trend screen.
  static const progress = '/progress';

  /// Today's workout plan overview.
  static const workouts = '/workouts';

  /// Active set-by-set workout session.
  static const workoutSession = '/workouts/session';

  /// Privacy-first coaching conversation.
  static const coach = '/coach';

  /// Offline nutrition and hydration journal.
  static const nutrition = '/nutrition';

  /// Local member preferences and privacy controls.
  static const settings = '/settings';

  /// Administrator portal with deny-by-default production access.
  static const admin = '/admin';
}

/// Owns the router and disposes it with the provider container.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.landing,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
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
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.today,
        builder: (context, state) => const ThemePreviewPage(),
      ),
      GoRoute(
        path: AppRoutes.progress,
        builder: (context, state) => const ProgressPage(),
      ),
      GoRoute(
        path: AppRoutes.workouts,
        builder: (context, state) => const WorkoutPlanPage(),
      ),
      GoRoute(
        path: AppRoutes.workoutSession,
        builder: (context, state) => const WorkoutSessionPage(),
      ),
      GoRoute(
        path: AppRoutes.coach,
        builder: (context, state) => const CoachPage(),
      ),
      GoRoute(
        path: AppRoutes.nutrition,
        builder: (context, state) => const NutritionPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminPage(),
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
