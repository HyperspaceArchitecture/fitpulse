import 'package:fitpulse/features/progress/data/progress_repository.dart';
import 'package:fitpulse/features/progress/domain/wellness_metric.dart';

/// Deterministic progress persistence used by tests.
class InMemoryProgressRepository implements ProgressRepository {
  /// Stored chronological values.
  List<WellnessMetric> values = [];

  @override
  Future<List<WellnessMetric>> read() async => values;

  @override
  Future<void> save(List<WellnessMetric> metrics) async {
    values = [...metrics];
  }
}
