import 'package:fitpulse/features/dashboard/domain/daily_plan.dart';

/// Deterministic local data used until sensor and health integrations are added.
abstract final class DashboardPreviewData {
  /// Today's clearly-labelled preview plan.
  static const today = DailyPlan(
    readiness: 84,
    sleepHours: 7.7,
    steps: 7842,
    proteinGrams: 96,
    session: PlannedSession(
      title: 'Strength + mobility',
      focus: 'Full body · controlled tempo',
      durationMinutes: 42,
      intensity: 'Moderate',
    ),
    recoveryMessage: 'Your sleep and recent consistency support a normal session. Keep two reps in reserve.',
  );
}
