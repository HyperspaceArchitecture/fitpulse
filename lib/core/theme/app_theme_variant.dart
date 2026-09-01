/// The production visual systems available to FitPulse.
enum AppThemeVariant {
  pulseBlue('Pulse Blue', 'Cool, focused and energetic'),
  ochre('Ochre', 'Warm, grounded and resilient');

  const AppThemeVariant(this.label, this.description);

  /// User-facing theme name.
  final String label;

  /// Short description of the theme's emotional character.
  final String description;
}
