import 'package:fitpulse/features/progress/application/progress_controller.dart';
import 'package:fitpulse/features/progress/data/progress_repository.dart';
import 'package:fitpulse/features/progress/domain/wellness_metric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_progress_repository.dart';

void main() {
  test('replaces the same calendar day and persists it', () async {
    final repository = InMemoryProgressRepository();
    final container = ProviderContainer(
      overrides: [progressRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await container.read(progressControllerProvider.future);

    await container
        .read(progressControllerProvider.notifier)
        .save(
          WellnessMetric(
            date: DateTime(2026, 9, 2),
            exercise: 82,
            sleep: 78,
            nutrition: 76,
            weightKg: 82.7,
          ),
        );
    await container
        .read(progressControllerProvider.notifier)
        .save(
          WellnessMetric(
            date: DateTime(2026, 9, 2, 20),
            exercise: 88,
            sleep: 80,
            nutrition: 79,
            weightKg: 82.6,
          ),
        );

    final matching = repository.values.where(
      (metric) => metric.date.day == 2 && metric.date.month == 9,
    );
    expect(matching, hasLength(1));
    expect(matching.single.exercise, 88);
  });
}
