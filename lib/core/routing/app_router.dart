import 'package:fitpulse/core/routing/app_routes.dart';
import 'package:fitpulse/core/routing/app_shell.dart';
import 'package:fitpulse/features/admin/presentation/pages/admin_page.dart';
import 'package:fitpulse/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:fitpulse/features/auth/presentation/pages/register_page.dart';
import 'package:fitpulse/features/auth/presentation/pages/sign_in_page.dart';
import 'package:fitpulse/features/coach/presentation/pages/coach_page.dart';
import 'package:fitpulse/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:fitpulse/features/dashboard/presentation/pages/startup_page.dart';
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

export 'app_routes.dart';

/// Owns the router and disposes it with the provider container.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    // The product always opens on the quiet progress welcome screen.
    // The member dashboard is entered from the avatar on that screen.
    initialLocation: AppRoutes.landing,
    routes: [
      GoRoute(
        path: AppRoutes.landing,
        builder: (context, state) => const StartupPage(),
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
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardPage(),
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
            path: AppRoutes.coach,
            builder: (context, state) => const CoachPage(),
          ),
          GoRoute(
            path: AppRoutes.nutrition,
            builder: (context, state) => const NutritionPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.today,
        builder: (context, state) => const ThemePreviewPage(),
      ),
      GoRoute(
        path: AppRoutes.workoutSession,
        builder: (context, state) => const WorkoutSessionPage(),
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
