import 'package:fitpulse/features/nutrition/domain/nutrition_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('totals meals and restores persisted values', () {
    final day = NutritionDay(
      date: DateTime(2026, 9, 2),
      waterMillilitres: 750,
      entries: [
        NutritionEntry(
          id: 'meal-1',
          name: 'Tofu grain bowl',
          meal: 'Lunch',
          energyKcal: 620,
          proteinGrams: 34,
          fibreGrams: 12,
          loggedAt: DateTime(2026, 9, 2, 12, 30),
          photoBase64: 'aW1hZ2U=',
          estimateConfidence: 'Low-confidence photo estimate',
        ),
        NutritionEntry(
          id: 'meal-2',
          name: 'Yoghurt and berries',
          meal: 'Snack',
          energyKcal: 240,
          proteinGrams: 18,
          fibreGrams: 6,
          loggedAt: DateTime(2026, 9, 2, 15),
        ),
      ],
    );

    expect(day.energyKcal, 860);
    expect(day.proteinGrams, 52);
    expect(day.fibreGrams, 18);

    final restored = NutritionDay.fromJson(day.toJson());
    expect(restored.entries, hasLength(2));
    expect(restored.waterMillilitres, 750);
    expect(restored.entries.last.name, 'Yoghurt and berries');
    expect(restored.entries.first.photoBase64, 'aW1hZ2U=');
    expect(
      restored.entries.first.estimateConfidence,
      'Low-confidence photo estimate',
    );
  });
}
