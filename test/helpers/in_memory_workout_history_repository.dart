import 'package:fitpulse/features/workout/data/workout_history_repository.dart';
import 'package:fitpulse/features/workout/domain/workout_plan.dart';

/// Deterministic workout history used by engine and widget tests.
class InMemoryWorkoutHistoryRepository implements WorkoutHistoryRepository {
  /// Completed workouts in write order.
  final records = <CompletedWorkout>[];

  @override
  Future<void> save(CompletedWorkout workout) async {
    records.add(workout);
  }
}
