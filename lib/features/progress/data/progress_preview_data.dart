import 'package:fitpulse/features/progress/domain/wellness_metric.dart';

/// Curated local data used only to review the progress presentation safely.
abstract final class ProgressPreviewData {
  /// A representative seven-day wellness series.
  static final recentWeek = <WellnessMetric>[
    WellnessMetric(
      date: DateTime(2026, 8, 26),
      exercise: 58,
      sleep: 72,
      nutrition: 64,
      weightKg: 83.4,
    ),
    WellnessMetric(
      date: DateTime(2026, 8, 27),
      exercise: 70,
      sleep: 76,
      nutrition: 68,
      weightKg: 83.5,
    ),
    WellnessMetric(
      date: DateTime(2026, 8, 28),
      exercise: 66,
      sleep: 61,
      nutrition: 74,
      weightKg: 83.2,
    ),
    WellnessMetric(
      date: DateTime(2026, 8, 29),
      exercise: 82,
      sleep: 79,
      nutrition: 77,
      weightKg: 83.3,
    ),
    WellnessMetric(
      date: DateTime(2026, 8, 30),
      exercise: 74,
      sleep: 86,
      nutrition: 72,
      weightKg: 83.1,
    ),
    WellnessMetric(
      date: DateTime(2026, 8, 31),
      exercise: 88,
      sleep: 81,
      nutrition: 84,
      weightKg: 83.0,
    ),
    WellnessMetric(
      date: DateTime(2026, 9, 1),
      exercise: 84,
      sleep: 89,
      nutrition: 86,
      weightKg: 82.9,
    ),
  ];
}
