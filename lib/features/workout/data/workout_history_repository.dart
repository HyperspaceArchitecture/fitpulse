import 'dart:convert';

import 'package:fitpulse/features/workout/domain/workout_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for completed workout history.
abstract interface class WorkoutHistoryRepository {
  /// Appends a completed workout record.
  Future<void> save(CompletedWorkout workout);

  /// Returns the newest completed workout, when one exists.
  Future<CompletedWorkout?> latest();
}

/// Stores a bounded offline completion history in platform preferences.
class SharedPreferencesWorkoutHistoryRepository
    implements WorkoutHistoryRepository {
  /// Creates a local workout history repository.
  SharedPreferencesWorkoutHistoryRepository(this._preferences);

  static const _key = 'workout.history.v1';
  static const _maxRecords = 100;
  final SharedPreferencesAsync _preferences;

  @override
  Future<void> save(CompletedWorkout workout) async {
    final existing = await _preferences.getStringList(_key) ?? const [];
    final updated = [
      jsonEncode(workout.toJson()),
      ...existing,
    ].take(_maxRecords).toList(growable: false);
    await _preferences.setStringList(_key, updated);
  }

  @override
  Future<CompletedWorkout?> latest() async {
    final records = await _preferences.getStringList(_key) ?? const [];
    if (records.isEmpty) return null;
    return CompletedWorkout.fromJson(
      (jsonDecode(records.first) as Map).cast<String, Object?>(),
    );
  }
}

/// Provides the production offline workout history implementation.
final workoutHistoryRepositoryProvider = Provider<WorkoutHistoryRepository>(
  (ref) => SharedPreferencesWorkoutHistoryRepository(SharedPreferencesAsync()),
);

/// Exposes the latest completion to the startup encouragement experience.
final latestWorkoutProvider = FutureProvider<CompletedWorkout?>((ref) {
  return ref.watch(workoutHistoryRepositoryProvider).latest();
});
