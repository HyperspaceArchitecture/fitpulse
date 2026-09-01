/// The production visual systems available to FitPulse.
enum AppThemeVariant {
  graphite('Graphite', 'Masculine, contemporary and focused'),
  studioLilac('Studio', 'Soft, expressive and editorial'),
  cloudPop('Cloud Pop', 'Calming, friendly and playful');

  const AppThemeVariant(this.label, this.description);

  /// User-facing theme name.
  final String label;

  /// Short description of the theme's emotional character.
  final String description;
}
