import 'package:fitpulse/features/workout/domain/workout_plan.dart';

/// Offline workout content bundled with the first production slice.
abstract final class WorkoutCatalog {
  /// Balanced full-body plan used by today's dashboard.
  static const strengthMobility = WorkoutPlan(
    id: 'strength_mobility_a',
    title: 'Strength + mobility',
    description: 'A controlled full-body session that builds usable strength without exhausting recovery.',
    durationMinutes: 42,
    intensity: 'Moderate',
    exercises: [
      WorkoutExercise(
        id: 'goblet_squat',
        name: 'Goblet squat',
        focus: 'Legs + trunk',
        sets: 3,
        reps: '8–10 reps',
        restSeconds: 60,
        coachingCue: 'Keep your ribs stacked and drive the floor away.',
      ),
      WorkoutExercise(
        id: 'incline_push_up',
        name: 'Incline push-up',
        focus: 'Chest + shoulders',
        sets: 3,
        reps: '8–12 reps',
        restSeconds: 60,
        coachingCue: 'Move as one strong line; finish with long arms.',
      ),
      WorkoutExercise(
        id: 'split_stance_row',
        name: 'Split-stance row',
        focus: 'Back + posture',
        sets: 3,
        reps: '10 each side',
        restSeconds: 60,
        coachingCue: 'Pull your elbow toward your back pocket.',
      ),
      WorkoutExercise(
        id: 'romanian_deadlift',
        name: 'Romanian deadlift',
        focus: 'Hips + hamstrings',
        sets: 3,
        reps: '8–10 reps',
        restSeconds: 75,
        coachingCue: 'Send the hips back and keep the weight close.',
      ),
      WorkoutExercise(
        id: 'dead_bug',
        name: 'Dead bug',
        focus: 'Core control',
        sets: 2,
        reps: '6 each side',
        restSeconds: 45,
        coachingCue: 'Exhale fully and keep your lower back quiet.',
      ),
      WorkoutExercise(
        id: 'hip_flexor_flow',
        name: 'Hip flexor flow',
        focus: 'Mobility + breathing',
        sets: 2,
        reps: '45 sec each side',
        restSeconds: 30,
        coachingCue: 'Stay tall and breathe into the stretch.',
      ),
    ],
  );
}
