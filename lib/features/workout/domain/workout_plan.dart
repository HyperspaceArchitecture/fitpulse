/// One exercise prescription within a workout.
class WorkoutExercise {
  /// Creates an exercise prescription.
  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.focus,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.coachingCue,
    required this.illustrationAsset,
    required this.videoUrl,
    required this.videoSource,
  });

  /// Stable identifier used by logs and future content updates.
  final String id;

  /// Member-facing movement name.
  final String name;

  /// Primary muscle or movement quality.
  final String focus;

  /// Number of working sets.
  final int sets;

  /// Rep or time prescription.
  final String reps;

  /// Recovery time after each set.
  final int restSeconds;

  /// Short technique cue shown during the set.
  final String coachingCue;

  /// Bundled two-phase motion illustration available offline.
  final String illustrationAsset;

  /// Selected external technique demonstration.
  final String videoUrl;

  /// Publisher displayed before the member opens the external video.
  final String videoSource;
}

/// Ordered exercise plan that can be executed by the workout engine.
class WorkoutPlan {
  /// Creates a workout plan.
  const WorkoutPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.intensity,
    required this.exercises,
  });

  /// Stable plan identifier.
  final String id;

  /// Member-facing plan name.
  final String title;

  /// Purpose and intent of the plan.
  final String description;

  /// Estimated duration.
  final int durationMinutes;

  /// Plain-language effort level.
  final String intensity;

  /// Exercises in execution order.
  final List<WorkoutExercise> exercises;

  /// Total prescribed working sets.
  int get totalSets => exercises.fold(0, (total, item) => total + item.sets);
}

/// Persisted summary of a completed workout.
class CompletedWorkout {
  /// Creates a completed workout record.
  const CompletedWorkout({
    required this.planId,
    required this.completedAt,
    required this.durationSeconds,
    required this.completedSets,
  });

  /// Plan that was completed.
  final String planId;

  /// Completion time in UTC.
  final DateTime completedAt;

  /// Active session duration.
  final int durationSeconds;

  /// Number of completed working sets.
  final int completedSets;

  /// Serializes the record for local persistence.
  Map<String, Object> toJson() => {
    'planId': planId,
    'completedAt': completedAt.toIso8601String(),
    'durationSeconds': durationSeconds,
    'completedSets': completedSets,
  };
}
