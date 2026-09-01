import 'package:fitpulse/features/progress/domain/wellness_metric.dart';

/// Transparent weighting used to combine daily wellness inputs.
abstract final class WellnessScore {
  /// Exercise contribution to the overall score.
  static const exerciseWeight = 0.40;

  /// Sleep contribution to the overall score.
  static const sleepWeight = 0.35;

  /// Nutrition contribution to the overall score.
  static const nutritionWeight = 0.25;

  /// Calculates the weighted overall score for [metric].
  static double calculate(WellnessMetric metric) {
    return metric.exercise * exerciseWeight +
        metric.sleep * sleepWeight +
        metric.nutrition * nutritionWeight;
  }

  /// Calculates the arithmetic mean for a metric selector.
  static double average(
    List<WellnessMetric> metrics,
    double Function(WellnessMetric metric) selector,
  ) {
    if (metrics.isEmpty) return 0;
    final total = metrics.fold<double>(
      0,
      (sum, metric) => sum + selector(metric),
    );
    return total / metrics.length;
  }
}
