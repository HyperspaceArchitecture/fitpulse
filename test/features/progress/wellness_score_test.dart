import 'package:fitpulse/features/progress/domain/wellness_metric.dart';
import 'package:fitpulse/features/progress/domain/wellness_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('combines exercise, sleep, and nutrition with transparent weights', () {
    final metric = WellnessMetric(
      date: DateTime(2026, 9, 1),
      exercise: 80,
      sleep: 70,
      nutrition: 60,
      weightKg: 90,
    );

    expect(WellnessScore.calculate(metric), 71.5);
  });

  test('weight does not reduce the behavioral wellness score', () {
    final first = WellnessMetric(
      date: DateTime(2026, 9, 1),
      exercise: 80,
      sleep: 80,
      nutrition: 80,
      weightKg: 80,
    );
    final second = WellnessMetric(
      date: DateTime(2026, 9, 2),
      exercise: 80,
      sleep: 80,
      nutrition: 80,
      weightKg: 82,
    );

    expect(WellnessScore.calculate(first), WellnessScore.calculate(second));
  });
}
