import 'package:fitpulse/features/onboarding/domain/fitness_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips a complete fitness profile', () {
    final profile = FitnessProfile(
      displayName: 'Sam',
      goal: FitnessGoal.improveFitness,
      experience: TrainingExperience.intermediate,
      trainingDaysPerWeek: 4,
      sessionMinutes: 45,
      equipment: const {Equipment.bodyweight, Equipment.dumbbells},
      heightCm: 172,
      currentWeightKg: 78.4,
      targetWeightKg: 74,
      sleepHours: 7.5,
      completedAt: DateTime.utc(2026, 9, 2),
      avatarId: 4,
    );

    final restored = FitnessProfile.fromJson(profile.toJson());

    expect(restored.displayName, 'Sam');
    expect(restored.goal, FitnessGoal.improveFitness);
    expect(restored.experience, TrainingExperience.intermediate);
    expect(restored.equipment, containsAll(profile.equipment));
    expect(restored.currentWeightKg, 78.4);
    expect(restored.completedAt, DateTime.utc(2026, 9, 2));
    expect(restored.avatarId, 4);
  });
}
