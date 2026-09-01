/// The production visual systems available to FitPulse.
enum AppThemeVariant {
  graphite('Graphite', 'Masculine, contemporary and focused'),
  studioLilac('Studio', 'Soft, expressive and editorial'),
  softArcade('Soft Arcade', 'Clean, polished and playfully rounded');

  const AppThemeVariant(this.label, this.description);

  /// User-facing theme name.
  final String label;

  /// Short description of the theme's emotional character.
  final String description;
}
