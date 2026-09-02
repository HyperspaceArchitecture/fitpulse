/// A meal or snack logged by the member.
class NutritionEntry {
  /// Creates a nutrition entry.
  const NutritionEntry({
    required this.id,
    required this.name,
    required this.meal,
    required this.energyKcal,
    required this.proteinGrams,
    required this.fibreGrams,
    required this.loggedAt,
  });

  /// Stable identifier used for deletion.
  final String id;

  /// Member-facing meal description.
  final String name;

  /// Meal period, such as Breakfast or Snack.
  final String meal;

  /// Estimated energy in kilocalories.
  final int energyKcal;

  /// Estimated protein in grams.
  final int proteinGrams;

  /// Estimated fibre in grams.
  final int fibreGrams;

  /// Local time at which the entry was recorded.
  final DateTime loggedAt;

  /// Serializes this entry for offline persistence.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'meal': meal,
    'energyKcal': energyKcal,
    'proteinGrams': proteinGrams,
    'fibreGrams': fibreGrams,
    'loggedAt': loggedAt.toIso8601String(),
  };

  /// Restores a persisted entry.
  factory NutritionEntry.fromJson(Map<String, Object?> json) {
    return NutritionEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      meal: json['meal'] as String,
      energyKcal: json['energyKcal'] as int,
      proteinGrams: json['proteinGrams'] as int,
      fibreGrams: json['fibreGrams'] as int,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
    );
  }
}

/// All locally recorded nutrition signals for one calendar day.
class NutritionDay {
  /// Creates a nutrition day.
  const NutritionDay({
    required this.date,
    this.entries = const [],
    this.waterMillilitres = 0,
  });

  /// Calendar date represented by this record.
  final DateTime date;

  /// Meals and snacks logged for this day.
  final List<NutritionEntry> entries;

  /// Water recorded in millilitres.
  final int waterMillilitres;

  /// Total energy across logged entries.
  int get energyKcal => entries.fold(0, (sum, item) => sum + item.energyKcal);

  /// Total protein across logged entries.
  int get proteinGrams =>
      entries.fold(0, (sum, item) => sum + item.proteinGrams);

  /// Total fibre across logged entries.
  int get fibreGrams => entries.fold(0, (sum, item) => sum + item.fibreGrams);

  /// Returns a copy with selected values replaced.
  NutritionDay copyWith({
    List<NutritionEntry>? entries,
    int? waterMillilitres,
  }) {
    return NutritionDay(
      date: date,
      entries: entries ?? this.entries,
      waterMillilitres: waterMillilitres ?? this.waterMillilitres,
    );
  }

  /// Serializes this record for offline persistence.
  Map<String, Object?> toJson() => {
    'date': date.toIso8601String(),
    'waterMillilitres': waterMillilitres,
    'entries': entries.map((entry) => entry.toJson()).toList(),
  };

  /// Restores a persisted nutrition day.
  factory NutritionDay.fromJson(Map<String, Object?> json) {
    final rawEntries = json['entries'] as List<Object?>? ?? const [];
    return NutritionDay(
      date: DateTime.parse(json['date'] as String),
      waterMillilitres: json['waterMillilitres'] as int? ?? 0,
      entries: rawEntries
          .map(
            (entry) => NutritionEntry.fromJson(entry! as Map<String, Object?>),
          )
          .toList(growable: false),
    );
  }
}
