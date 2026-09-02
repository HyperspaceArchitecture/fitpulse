import 'package:fitpulse/features/nutrition/application/nutrition_controller.dart';
import 'package:fitpulse/features/nutrition/data/nutrition_repository.dart';
import 'package:fitpulse/features/nutrition/domain/nutrition_day.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_nutrition_repository.dart';

void main() {
  test('adds food and hydration through the repository boundary', () async {
    final repository = InMemoryNutritionRepository();
    final container = ProviderContainer(
      overrides: [nutritionRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await container.read(nutritionControllerProvider.future);

    await container
        .read(nutritionControllerProvider.notifier)
        .addEntry(
          NutritionEntry(
            id: 'entry',
            name: 'Eggs on toast',
            meal: 'Breakfast',
            energyKcal: 420,
            proteinGrams: 28,
            fibreGrams: 5,
            loggedAt: DateTime(2026, 9, 2, 8),
          ),
        );
    await container.read(nutritionControllerProvider.notifier).addWater();

    final state = container.read(nutritionControllerProvider).requireValue;
    expect(state.entries.single.name, 'Eggs on toast');
    expect(state.waterMillilitres, 250);
    expect(repository.value?.proteinGrams, 28);
  });
}
