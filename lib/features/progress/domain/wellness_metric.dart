import 'package:flutter/foundation.dart';

/// Immutable daily inputs used to calculate a holistic wellness trend.
@immutable
class WellnessMetric {
  /// Creates a normalized daily wellness measurement.
  const WellnessMetric({
    required this.date,
    required this.exercise,
    required this.sleep,
    required this.nutrition,
    required this.weightKg,
  }) : assert(exercise >= 0 && exercise <= 100),
       assert(sleep >= 0 && sleep <= 100),
       assert(nutrition >= 0 && nutrition <= 100),
       assert(weightKg > 0);

  /// Calendar day represented by this measurement.
  final DateTime date;

  /// Exercise completion and training-quality score from zero to 100.
  final double exercise;

  /// Sleep duration, consistency, and recovery score from zero to 100.
  final double sleep;

  /// Nutrition adherence and balance score from zero to 100.
  final double nutrition;

  /// Scale weight in kilograms, charted independently from wellness scores.
  final double weightKg;

  /// Serializes this measurement for local storage.
  Map<String, Object> toJson() => {
    'date': date.toIso8601String(),
    'exercise': exercise,
    'sleep': sleep,
    'nutrition': nutrition,
    'weightKg': weightKg,
  };

  /// Restores a locally persisted measurement.
  factory WellnessMetric.fromJson(Map<String, Object?> json) {
    return WellnessMetric(
      date: DateTime.parse(json['date'] as String),
      exercise: (json['exercise'] as num).toDouble(),
      sleep: (json['sleep'] as num).toDouble(),
      nutrition: (json['nutrition'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
    );
  }
}
