import 'package:fitpulse/features/progress/domain/wellness_metric.dart';

/// Curated local data used only to review the progress presentation safely.
abstract final class ProgressPreviewData {
  /// A representative seven-day wellness series.
  static final recentWeek = <WellnessMetric>[
    WellnessMetric(
      date: DateTime(2026, 8, 26),
      exercise: 72,
      sleep: 75,
      nutrition: 75.8,
      weightKg: 83.4,
    ),
    WellnessMetric(
      date: DateTime(2026, 8, 27),
      exercise: 73,
      sleep: 74,
      nutrition: 76,
      weightKg: 83.5,
    ),
    WellnessMetric(
      date: DateTime(2026, 8, 28),
      exercise: 72,
      sleep: 76,
      nutrition: 76,
      weightKg: 83.2,
    ),
    WellnessMetric(
      date: DateTime(2026, 8, 29),
      exercise: 75,
      sleep: 76,
      nutrition: 75,
      weightKg: 83.3,
    ),
    WellnessMetric(
      date: DateTime(2026, 8, 30),
      exercise: 74,
      sleep: 78,
      nutrition: 76,
      weightKg: 83.1,
    ),
    WellnessMetric(
      date: DateTime(2026, 8, 31),
      exercise: 75,
      sleep: 77,
      nutrition: 76,
      weightKg: 83.0,
    ),
    WellnessMetric(
      date: DateTime(2026, 9, 1),
      exercise: 77,
      sleep: 78,
      nutrition: 76.4,
      weightKg: 82.9,
    ),
  ];
}
