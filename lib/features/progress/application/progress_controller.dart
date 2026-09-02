import 'package:fitpulse/features/progress/data/progress_preview_data.dart';
import 'package:fitpulse/features/progress/data/progress_repository.dart';
import 'package:fitpulse/features/progress/domain/wellness_metric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads and updates the member's offline progress history.
class ProgressController extends AsyncNotifier<List<WellnessMetric>> {
  @override
  Future<List<WellnessMetric>> build() async {
    final saved = await ref.watch(progressRepositoryProvider).read();
    return saved.isEmpty ? ProgressPreviewData.recentWeek : saved;
  }

  /// Inserts or replaces the measurement for its calendar day.
  Future<void> save(WellnessMetric metric) async {
    final current = [...state.requireValue];
    final index = current.indexWhere(
      (item) => _sameDay(item.date, metric.date),
    );
    if (index == -1) {
      current.add(metric);
    } else {
      current[index] = metric;
    }
    current.sort((a, b) => a.date.compareTo(b.date));
    state = AsyncData(current);
    await ref.read(progressRepositoryProvider).save(current);
  }

  static bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

/// Exposes the locally persisted progress history.
final progressControllerProvider =
    AsyncNotifierProvider<ProgressController, List<WellnessMetric>>(
      ProgressController.new,
    );
