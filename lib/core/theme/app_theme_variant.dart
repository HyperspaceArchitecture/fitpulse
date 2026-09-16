/// The production visual systems available to FitPulse.
/// Two primary design directions: athletic dark and illustrated soft.
enum AppThemeVariant {
  /// Athletic, dark, power-focused. Midnight navy (#1A1A2E) with ignite orange (#FF4D00).
  /// Heavy Barlow Condensed typography, ALL CAPS labels, sport character poses.
  /// Left-accent dark panels with illustrated athletes (deadlift, box jump, pull-up, squat).
  athleticDark(
    'Athletic',
    'Power-focused, dark, motivational',
  ),

  /// Soft, illustrated, feminine-coded. Warm cream (#FFF6F0) with rose pulse (#D4537E).
  /// Rounded pills, friendly emoji faces, pastel category cards.
  /// Illustrated characters (yoga, cycling, stretch, HIIT) with expressive faces.
  illustratedSoft(
    'Illustrated',
    'Friendly, approachable, encouraging',
  );

  const AppThemeVariant(this.label, this.description);

  /// User-facing theme name.
  final String label;

  /// Short description of the theme's emotional character.
  final String description;
}
