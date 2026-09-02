import 'dart:async';

import 'package:fitpulse/features/workout/data/workout_catalog.dart';
import 'package:fitpulse/features/workout/data/workout_history_repository.dart';
import 'package:fitpulse/features/workout/domain/workout_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable state for an active workout session.
class WorkoutSessionState {
  /// Creates workout session state.
  const WorkoutSessionState({
    required this.plan,
    required this.exerciseIndex,
    required this.setIndex,
    required this.completedSets,
    required this.elapsedSeconds,
    required this.restRemaining,
    required this.started,
    required this.paused,
    required this.complete,
  });

  /// Creates an idle session for [plan].
  factory WorkoutSessionState.idle(WorkoutPlan plan) => WorkoutSessionState(
    plan: plan,
    exerciseIndex: 0,
    setIndex: 0,
    completedSets: 0,
    elapsedSeconds: 0,
    restRemaining: 0,
    started: false,
    paused: false,
    complete: false,
  );

  final WorkoutPlan plan;
  final int exerciseIndex;
  final int setIndex;
  final int completedSets;
  final int elapsedSeconds;
  final int restRemaining;
  final bool started;
  final bool paused;
  final bool complete;

  /// Currently displayed exercise.
  WorkoutExercise get exercise => plan.exercises[exerciseIndex];

  /// Overall working-set progress from 0 to 1.
  double get progress => completedSets / plan.totalSets;

  /// Whether the engine is counting down between sets.
  bool get resting => restRemaining > 0;

  WorkoutSessionState copyWith({
    int? exerciseIndex,
    int? setIndex,
    int? completedSets,
    int? elapsedSeconds,
    int? restRemaining,
    bool? started,
    bool? paused,
    bool? complete,
  }) => WorkoutSessionState(
    plan: plan,
    exerciseIndex: exerciseIndex ?? this.exerciseIndex,
    setIndex: setIndex ?? this.setIndex,
    completedSets: completedSets ?? this.completedSets,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    restRemaining: restRemaining ?? this.restRemaining,
    started: started ?? this.started,
    paused: paused ?? this.paused,
    complete: complete ?? this.complete,
  );
}

/// Executes workout sets, rest periods, timing, and completion persistence.
class WorkoutEngineController extends Notifier<WorkoutSessionState> {
  Timer? _timer;

  @override
  WorkoutSessionState build() {
    ref.onDispose(() => _timer?.cancel());
    return WorkoutSessionState.idle(WorkoutCatalog.strengthMobility);
  }

  /// Starts or resumes the session clock.
  void start() {
    if (state.complete) return;
    state = state.copyWith(started: true, paused: false);
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// Pauses or resumes the active clock.
  void togglePause() {
    if (!state.started || state.complete) return;
    state = state.copyWith(paused: !state.paused);
  }

  /// Records the current set and advances the prescription.
  Future<void> completeSet() async {
    if (!state.started || state.paused || state.complete || state.resting) {
      return;
    }

    final exercise = state.exercise;
    final completedSets = state.completedSets + 1;
    final finishedExercise = state.setIndex + 1 >= exercise.sets;
    final finishedWorkout =
        finishedExercise &&
        state.exerciseIndex + 1 >= state.plan.exercises.length;

    if (finishedWorkout) {
      state = state.copyWith(
        setIndex: exercise.sets,
        completedSets: completedSets,
        complete: true,
        paused: false,
        restRemaining: 0,
      );
      _timer?.cancel();
      _timer = null;
      await ref
          .read(workoutHistoryRepositoryProvider)
          .save(
            CompletedWorkout(
              planId: state.plan.id,
              completedAt: DateTime.now().toUtc(),
              durationSeconds: state.elapsedSeconds,
              completedSets: completedSets,
            ),
          );
      ref.invalidate(latestWorkoutProvider);
      return;
    }

    state = state.copyWith(
      exerciseIndex: finishedExercise
          ? state.exerciseIndex + 1
          : state.exerciseIndex,
      setIndex: finishedExercise ? 0 : state.setIndex + 1,
      completedSets: completedSets,
      restRemaining: exercise.restSeconds,
    );
  }

  /// Ends the current rest period without changing set progress.
  void skipRest() {
    if (!state.resting) return;
    state = state.copyWith(restRemaining: 0);
  }

  /// Clears all session progress.
  void reset() {
    _timer?.cancel();
    _timer = null;
    state = WorkoutSessionState.idle(state.plan);
  }

  void _tick() {
    if (state.paused || state.complete || !state.started) return;
    state = state.copyWith(
      elapsedSeconds: state.elapsedSeconds + 1,
      restRemaining: state.restRemaining > 0 ? state.restRemaining - 1 : 0,
    );
  }
}

/// Owns the current workout session.
final workoutEngineProvider =
    NotifierProvider<WorkoutEngineController, WorkoutSessionState>(
      WorkoutEngineController.new,
    );
