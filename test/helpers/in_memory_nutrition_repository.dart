import 'package:fitpulse/features/nutrition/data/nutrition_repository.dart';
import 'package:fitpulse/features/nutrition/domain/nutrition_day.dart';

/// Deterministic nutrition persistence used by tests.
class InMemoryNutritionRepository implements NutritionRepository {
  /// Creates an empty in-memory repository.
  InMemoryNutritionRepository();

  /// Most recently persisted day.
  NutritionDay? value;

  @override
  Future<NutritionDay> read(DateTime date) async {
    return value ??
        NutritionDay(date: DateTime(date.year, date.month, date.day));
  }

  @override
  Future<void> save(NutritionDay day) async {
    value = day;
  }
}
