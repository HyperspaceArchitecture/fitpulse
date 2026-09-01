import 'package:fitpulse/features/onboarding/data/profile_repository.dart';
import 'package:fitpulse/features/onboarding/domain/fitness_profile.dart';

/// Deterministic profile persistence used by unit and widget tests.
class InMemoryProfileRepository implements ProfileRepository {
  /// Creates an in-memory repository with an optional initial profile.
  InMemoryProfileRepository([this.value]);

  /// Most recently persisted profile.
  FitnessProfile? value;

  @override
  Future<FitnessProfile?> read() async => value;

  @override
  Future<void> save(FitnessProfile profile) async {
    value = profile;
  }
}
