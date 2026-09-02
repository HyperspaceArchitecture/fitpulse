/// The outcome the member most wants FitPulse to optimize for.
enum FitnessGoal { buildStrength, loseFat, improveFitness, moveBetter }

/// The member's current training experience.
enum TrainingExperience { beginner, intermediate, advanced }

/// Equipment the member can reliably access.
enum Equipment { bodyweight, dumbbells, bands, fullGym }

/// Presentation labels for [FitnessGoal].
extension FitnessGoalLabel on FitnessGoal {
  /// Human-readable label used in onboarding and summaries.
  String get label => switch (this) {
    FitnessGoal.buildStrength => 'Build strength',
    FitnessGoal.loseFat => 'Lose body fat',
    FitnessGoal.improveFitness => 'Improve fitness',
    FitnessGoal.moveBetter => 'Move better',
  };
}

/// Presentation labels for [TrainingExperience].
extension TrainingExperienceLabel on TrainingExperience {
  /// Human-readable label used in onboarding and summaries.
  String get label => switch (this) {
    TrainingExperience.beginner => 'Beginner',
    TrainingExperience.intermediate => 'Intermediate',
    TrainingExperience.advanced => 'Advanced',
  };
}

/// Presentation labels for [Equipment].
extension EquipmentLabel on Equipment {
  /// Human-readable label used in onboarding and summaries.
  String get label => switch (this) {
    Equipment.bodyweight => 'Bodyweight',
    Equipment.dumbbells => 'Dumbbells',
    Equipment.bands => 'Bands',
    Equipment.fullGym => 'Full gym',
  };
}

/// Non-sensitive fitness preferences stored locally for offline planning.
class FitnessProfile {
  /// Creates a validated member profile.
  const FitnessProfile({
    required this.displayName,
    required this.goal,
    required this.experience,
    required this.trainingDaysPerWeek,
    required this.sessionMinutes,
    required this.equipment,
    required this.heightCm,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.sleepHours,
    required this.completedAt,
    this.avatarId = 0,
  }) : assert(trainingDaysPerWeek >= 1 && trainingDaysPerWeek <= 7),
       assert(sessionMinutes >= 10),
       assert(heightCm >= 100 && heightCm <= 250),
       assert(currentWeightKg >= 30 && currentWeightKg <= 350),
       assert(sleepHours >= 0 && sleepHours <= 16);

  /// Name used to personalize coaching language.
  final String displayName;

  /// Primary coaching goal.
  final FitnessGoal goal;

  /// Self-reported training experience.
  final TrainingExperience experience;

  /// Sustainable weekly training frequency.
  final int trainingDaysPerWeek;

  /// Preferred duration for a normal session.
  final int sessionMinutes;

  /// Equipment available to the member.
  final Set<Equipment> equipment;

  /// Current height in centimetres.
  final double heightCm;

  /// Current weight in kilograms.
  final double currentWeightKg;

  /// Optional weight direction used only as one progress signal.
  final double? targetWeightKg;

  /// Typical nightly sleep duration.
  final double sleepHours;

  /// Timestamp used for schema migration and freshness checks.
  final DateTime completedAt;

  /// Selected local avatar style identifier.
  final int avatarId;

  /// Returns a copy with selected personal presentation values replaced.
  FitnessProfile copyWith({String? displayName, int? avatarId}) {
    return FitnessProfile(
      displayName: displayName ?? this.displayName,
      goal: goal,
      experience: experience,
      trainingDaysPerWeek: trainingDaysPerWeek,
      sessionMinutes: sessionMinutes,
      equipment: equipment,
      heightCm: heightCm,
      currentWeightKg: currentWeightKg,
      targetWeightKg: targetWeightKg,
      sleepHours: sleepHours,
      completedAt: completedAt,
      avatarId: avatarId ?? this.avatarId,
    );
  }

  /// Serializes the profile for the local persistence boundary.
  Map<String, Object?> toJson() => {
    'displayName': displayName,
    'goal': goal.name,
    'experience': experience.name,
    'trainingDaysPerWeek': trainingDaysPerWeek,
    'sessionMinutes': sessionMinutes,
    'equipment': equipment.map((item) => item.name).toList(),
    'heightCm': heightCm,
    'currentWeightKg': currentWeightKg,
    'targetWeightKg': targetWeightKg,
    'sleepHours': sleepHours,
    'completedAt': completedAt.toIso8601String(),
    'avatarId': avatarId,
  };

  /// Restores a profile from trusted local JSON data.
  factory FitnessProfile.fromJson(Map<String, Object?> json) {
    T enumByName<T extends Enum>(List<T> values, String name) =>
        values.firstWhere((value) => value.name == name);

    final equipmentNames = (json['equipment'] as List<Object?>).cast<String>();
    return FitnessProfile(
      displayName: json['displayName'] as String,
      goal: enumByName(FitnessGoal.values, json['goal'] as String),
      experience: enumByName(
        TrainingExperience.values,
        json['experience'] as String,
      ),
      trainingDaysPerWeek: json['trainingDaysPerWeek'] as int,
      sessionMinutes: json['sessionMinutes'] as int,
      equipment: equipmentNames
          .map((name) => enumByName(Equipment.values, name))
          .toSet(),
      heightCm: (json['heightCm'] as num).toDouble(),
      currentWeightKg: (json['currentWeightKg'] as num).toDouble(),
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
      sleepHours: (json['sleepHours'] as num).toDouble(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      avatarId: json['avatarId'] as int? ?? 0,
    );
  }
}
