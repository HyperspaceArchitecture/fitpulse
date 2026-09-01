import 'package:fitpulse/features/workout/application/workout_engine_controller.dart';
import 'package:fitpulse/features/workout/data/workout_history_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_workout_history_repository.dart';

void main() {
  test('executes every set and persists one completed workout', () async {
    final history = InMemoryWorkoutHistoryRepository();
    final container = ProviderContainer(
      overrides: [workoutHistoryRepositoryProvider.overrideWithValue(history)],
    );
    addTearDown(container.dispose);

    final controller = container.read(workoutEngineProvider.notifier);
    controller.start();
    final totalSets = container.read(workoutEngineProvider).plan.totalSets;

    for (var index = 0; index < totalSets; index += 1) {
      await controller.completeSet();
      controller.skipRest();
    }

    final state = container.read(workoutEngineProvider);
    expect(state.complete, isTrue);
    expect(state.completedSets, totalSets);
    expect(state.progress, 1);
    expect(history.records, hasLength(1));
    expect(history.records.single.completedSets, totalSets);
  });

  test('does not record sets while resting or paused', () async {
    final container = ProviderContainer(
      overrides: [
        workoutHistoryRepositoryProvider.overrideWithValue(
          InMemoryWorkoutHistoryRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(workoutEngineProvider.notifier);
    controller.start();
    await controller.completeSet();
    await controller.completeSet();
    expect(container.read(workoutEngineProvider).completedSets, 1);

    controller.skipRest();
    controller.togglePause();
    await controller.completeSet();
    expect(container.read(workoutEngineProvider).completedSets, 1);
  });
}
