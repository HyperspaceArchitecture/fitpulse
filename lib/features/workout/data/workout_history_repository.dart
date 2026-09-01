import 'dart:convert';

import 'package:fitpulse/features/workout/domain/workout_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for completed workout history.
abstract interface class WorkoutHistoryRepository {
  /// Appends a completed workout record.
  Future<void> save(CompletedWorkout workout);
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
}

/// Provides the production offline workout history implementation.
final workoutHistoryRepositoryProvider = Provider<WorkoutHistoryRepository>(
  (ref) => SharedPreferencesWorkoutHistoryRepository(SharedPreferencesAsync()),
);
