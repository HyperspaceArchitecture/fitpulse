import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/theme_selector.dart';
import 'package:fitpulse/shared/widgets/brand_mark.dart';
import 'package:fitpulse/shared/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Responsive visual shell shared by all authentication screens.
class AuthScaffold extends StatelessWidget {
  /// Creates an authentication screen shell.
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  /// Primary screen heading.
  final String title;

  /// Supporting screen description.
  final String subtitle;

  /// Form or confirmation content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FitPulseColors>()!;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: -180,
            bottom: -220,
            child: _AuthGlow(color: colors.glow),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton.filledTonal(
                            tooltip: 'Back to landing',
                            onPressed: () => context.go(AppRoutes.landing),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const ThemeSelector(),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Center(child: BrandMark()),
                      const SizedBox(height: 32),
                      GlassPanel(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 28),
                            child,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Consistent field styling for authentication data entry.
class AuthTextField extends StatelessWidget {
  /// Creates a validated authentication field.
  const AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.autofillHints,
    super.key,
  });

  /// Owns the field's editable value.
  final TextEditingController controller;

  /// Visible field label.
  final String label;

  /// Leading semantic icon.
  final IconData icon;

  /// Pure validation callback.
  final FormFieldValidator<String> validator;

  /// Optimizes the platform keyboard.
  final TextInputType? keyboardType;

  /// Selects the platform keyboard action.
  final TextInputAction? textInputAction;

  /// Hides sensitive text when true.
  final bool obscureText;

  /// Optional trailing control.
  final Widget? suffixIcon;

  /// Platform autofill categories.
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// Honest status notice shown while no authentication backend is selected.
class AuthConnectionNotice extends StatelessWidget {
  /// Creates the backend status notice.
  const AuthConnectionNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.shield_outlined, color: scheme.primary, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Screen preview only. No credentials leave this device.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthGlow extends StatelessWidget {
  const _AuthGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.24), color.withValues(alpha: 0)],
          ),
        ),
        child: const SizedBox.square(dimension: 560),
      ),
    );
  }
}
