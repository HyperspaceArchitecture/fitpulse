import 'package:fitpulse/features/nutrition/data/nutrition_repository.dart';
import 'package:fitpulse/features/nutrition/domain/nutrition_day.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads and updates today's offline nutrition journal.
class NutritionController extends AsyncNotifier<NutritionDay> {
  @override
  Future<NutritionDay> build() {
    return ref.watch(nutritionRepositoryProvider).read(DateTime.now());
  }

  /// Adds [entry] to today's journal.
  Future<void> addEntry(NutritionEntry entry) async {
    final current = state.requireValue;
    await _persist(current.copyWith(entries: [...current.entries, entry]));
  }

  /// Removes an entry by stable identifier.
  Future<void> removeEntry(String id) async {
    final current = state.requireValue;
    await _persist(
      current.copyWith(
        entries: current.entries.where((entry) => entry.id != id).toList(),
      ),
    );
  }

  /// Adds one standard 250 ml glass of water.
  Future<void> addWater() async {
    final current = state.requireValue;
    await _persist(
      current.copyWith(
        waterMillilitres: (current.waterMillilitres + 250).clamp(0, 5000),
      ),
    );
  }

  Future<void> _persist(NutritionDay updated) async {
    final previous = state;
    state = AsyncData(updated);
    try {
      await ref.read(nutritionRepositoryProvider).save(updated);
    } on Object catch (error, stackTrace) {
      state = previous;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

/// Exposes today's persisted nutrition journal.
final nutritionControllerProvider =
    AsyncNotifierProvider<NutritionController, NutritionDay>(
      NutritionController.new,
    );
