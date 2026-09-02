import 'dart:convert';

import 'package:fitpulse/features/progress/domain/wellness_metric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for member-entered progress measurements.
abstract interface class ProgressRepository {
  /// Reads chronological measurements.
  Future<List<WellnessMetric>> read();

  /// Saves a bounded chronological history.
  Future<void> save(List<WellnessMetric> metrics);
}

/// Stores progress locally for offline access.
class SharedPreferencesProgressRepository implements ProgressRepository {
  /// Creates a local progress repository.
  SharedPreferencesProgressRepository(this._preferences);

  static const _key = 'progress.metrics.v1';
  static const _maxDays = 365;
  final SharedPreferencesAsync _preferences;

  @override
  Future<List<WellnessMetric>> read() async {
    final values = await _preferences.getStringList(_key) ?? const [];
    try {
      return values
          .map(
            (value) => WellnessMetric.fromJson(
              jsonDecode(value) as Map<String, Object?>,
            ),
          )
          .toList(growable: false);
    } on Object {
      return const [];
    }
  }

  @override
  Future<void> save(List<WellnessMetric> metrics) {
    final bounded = metrics.length <= _maxDays
        ? metrics
        : metrics.sublist(metrics.length - _maxDays);
    return _preferences.setStringList(
      _key,
      bounded.map((metric) => jsonEncode(metric.toJson())).toList(),
    );
  }
}

/// Provides production offline progress storage.
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => SharedPreferencesProgressRepository(SharedPreferencesAsync()),
);
