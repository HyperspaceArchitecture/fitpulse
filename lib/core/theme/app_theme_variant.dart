/// The production visual systems available to FitPulse.
enum AppThemeVariant {
  pulseBlue('Volt Lime', 'Bold, graphic and high energy'),
  studioLilac('Studio Lilac', 'Soft, expressive and editorial');

  const AppThemeVariant(this.label, this.description);

  /// User-facing theme name.
  final String label;

  /// Short description of the theme's emotional character.
  final String description;
}
