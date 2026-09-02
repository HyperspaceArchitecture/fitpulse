import 'dart:convert';

import 'package:fitpulse/features/nutrition/domain/nutrition_day.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for a member's daily nutrition journal.
abstract interface class NutritionRepository {
  /// Reads the journal for [date].
  Future<NutritionDay> read(DateTime date);

  /// Replaces the saved journal for its calendar day.
  Future<void> save(NutritionDay day);
}

/// Stores nutrition journals locally without transmitting health information.
class SharedPreferencesNutritionRepository implements NutritionRepository {
  /// Creates an offline nutrition repository.
  SharedPreferencesNutritionRepository(this._preferences);

  static const _prefix = 'nutrition.day.v1.';
  final SharedPreferencesAsync _preferences;

  String _key(DateTime date) =>
      '$_prefix${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Future<NutritionDay> read(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final encoded = await _preferences.getString(_key(normalized));
    if (encoded == null) return NutritionDay(date: normalized);
    try {
      return NutritionDay.fromJson(jsonDecode(encoded) as Map<String, Object?>);
    } on Object {
      return NutritionDay(date: normalized);
    }
  }

  @override
  Future<void> save(NutritionDay day) {
    return _preferences.setString(_key(day.date), jsonEncode(day.toJson()));
  }
}

/// Provides the production nutrition persistence implementation.
final nutritionRepositoryProvider = Provider<NutritionRepository>(
  (ref) => SharedPreferencesNutritionRepository(SharedPreferencesAsync()),
);
