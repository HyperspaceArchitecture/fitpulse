import 'package:fitpulse/features/onboarding/data/profile_repository.dart';
import 'package:fitpulse/features/onboarding/domain/fitness_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads and updates the member's offline fitness profile.
class ProfileController extends AsyncNotifier<FitnessProfile?> {
  @override
  Future<FitnessProfile?> build() {
    return ref.watch(profileRepositoryProvider).read();
  }

  /// Persists a completed onboarding [profile].
  Future<void> save(FitnessProfile profile) async {
    final previous = state;
    state = const AsyncLoading();
    try {
      await ref.read(profileRepositoryProvider).save(profile);
      state = AsyncData(profile);
    } on Object catch (error, stackTrace) {
      state = previous;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

/// Exposes the persisted profile across onboarding and dashboard features.
final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, FitnessProfile?>(
      ProfileController.new,
    );
