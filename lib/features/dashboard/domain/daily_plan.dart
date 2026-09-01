/// A single planned training session shown on the member dashboard.
class PlannedSession {
  /// Creates a planned workout summary.
  const PlannedSession({
    required this.title,
    required this.focus,
    required this.durationMinutes,
    required this.intensity,
  });

  /// Member-facing session name.
  final String title;

  /// Primary physical qualities trained.
  final String focus;

  /// Expected duration in minutes.
  final int durationMinutes;

  /// Plain-language intensity guidance.
  final String intensity;
}

/// The daily signals used to frame a safe, achievable plan.
class DailyPlan {
  /// Creates a complete daily plan.
  const DailyPlan({
    required this.readiness,
    required this.sleepHours,
    required this.steps,
    required this.proteinGrams,
    required this.session,
    required this.recoveryMessage,
  });

  /// Normalized readiness score from 0 to 100.
  final int readiness;

  /// Sleep recorded for the previous night.
  final double sleepHours;

  /// Steps accumulated today.
  final int steps;

  /// Protein logged today.
  final int proteinGrams;

  /// Recommended training session.
  final PlannedSession session;

  /// Coaching explanation for the recommendation.
  final String recoveryMessage;
}
