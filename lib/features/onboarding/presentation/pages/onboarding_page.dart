import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/features/onboarding/application/profile_controller.dart';
import 'package:fitpulse/features/onboarding/domain/fitness_profile.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/theme_selector.dart';
import 'package:fitpulse/shared/widgets/brand_mark.dart';
import 'package:fitpulse/shared/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Four-step offline-first fitness profile onboarding.
class OnboardingPage extends ConsumerStatefulWidget {
  /// Creates the onboarding flow.
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  static const _stepTitles = ['Goal', 'Training', 'Schedule', 'Body context'];

  final _nameController = TextEditingController();
  final _heightController = TextEditingController(text: '170');
  final _weightController = TextEditingController(text: '75');
  final _targetWeightController = TextEditingController();

  var _step = 0;
  var _goal = FitnessGoal.buildStrength;
  var _experience = TrainingExperience.beginner;
  var _equipment = <Equipment>{Equipment.bodyweight};
  var _days = 3;
  var _sessionMinutes = 45;
  var _sleepHours = 7.5;
  var _acceptedSafety = false;
  var _showErrors = false;

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  bool _isStepValid() {
    if (_step == 0) return _nameController.text.trim().length >= 2;
    if (_step == 1) return _equipment.isNotEmpty;
    if (_step < 3) return true;

    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final targetText = _targetWeightController.text.trim();
    final target = targetText.isEmpty ? null : double.tryParse(targetText);
    return height != null &&
        height >= 100 &&
        height <= 250 &&
        weight != null &&
        weight >= 30 &&
        weight <= 350 &&
        (targetText.isEmpty ||
            (target != null && target >= 30 && target <= 350)) &&
        _acceptedSafety;
  }

  void _continue() {
    if (!_isStepValid()) {
      setState(() => _showErrors = true);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _showErrors = false;
      _step += 1;
    });
  }

  Future<void> _finish() async {
    if (!_isStepValid()) {
      setState(() => _showErrors = true);
      return;
    }

    final targetText = _targetWeightController.text.trim();
    final profile = FitnessProfile(
      displayName: _nameController.text.trim(),
      goal: _goal,
      experience: _experience,
      trainingDaysPerWeek: _days,
      sessionMinutes: _sessionMinutes,
      equipment: Set.unmodifiable(_equipment),
      heightCm: double.parse(_heightController.text),
      currentWeightKg: double.parse(_weightController.text),
      targetWeightKg: targetText.isEmpty ? null : double.parse(targetText),
      sleepHours: _sleepHours,
      completedAt: DateTime.now().toUtc(),
    );

    try {
      await ref.read(profileControllerProvider.notifier).save(profile);
      if (mounted) context.go(AppRoutes.today);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your profile. Try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FitPulseColors>()!;
    final saving = ref.watch(profileControllerProvider).isLoading;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            right: -240,
            top: -260,
            child: _OnboardingGlow(color: colors.glow),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton.filledTonal(
                            tooltip: _step == 0
                                ? 'Back to account'
                                : 'Previous step',
                            onPressed: saving
                                ? null
                                : () {
                                    if (_step == 0) {
                                      context.go(AppRoutes.register);
                                    } else {
                                      setState(() {
                                        _step -= 1;
                                        _showErrors = false;
                                      });
                                    }
                                  },
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 14),
                          const BrandMark(),
                          const Spacer(),
                          const ThemeSelector(),
                        ],
                      ),
                      const SizedBox(height: 34),
                      Text(
                        'LET’S PERSONALIZE FITPULSE',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _step == 3
                            ? 'Your body is context, not a score.'
                            : 'Build a plan that fits your real life.',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Step ${_step + 1} of ${_stepTitles.length} · ${_stepTitles[_step]}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: (_step + 1) / _stepTitles.length,
                        ),
                      ),
                      const SizedBox(height: 26),
                      GlassPanel(
                        padding: const EdgeInsets.all(28),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          child: KeyedSubtree(
                            key: ValueKey(_step),
                            child: _buildStep(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        key: const Key('onboarding-primary-action'),
                        onPressed: saving
                            ? null
                            : _step == _stepTitles.length - 1
                            ? _finish
                            : _continue,
                        icon: saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _step == _stepTitles.length - 1
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                              ),
                        label: Text(
                          saving
                              ? 'Saving locally…'
                              : _step == _stepTitles.length - 1
                              ? 'Create my plan'
                              : 'Continue',
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

  Widget _buildStep(BuildContext context) => switch (_step) {
    0 => _GoalStep(
      nameController: _nameController,
      goal: _goal,
      showErrors: _showErrors,
      onGoalChanged: (goal) => setState(() => _goal = goal),
    ),
    1 => _TrainingStep(
      experience: _experience,
      equipment: _equipment,
      showErrors: _showErrors,
      onExperienceChanged: (value) => setState(() => _experience = value),
      onEquipmentChanged: (value) => setState(() => _equipment = value),
    ),
    2 => _ScheduleStep(
      days: _days,
      sessionMinutes: _sessionMinutes,
      onDaysChanged: (value) => setState(() => _days = value),
      onSessionChanged: (value) => setState(() => _sessionMinutes = value),
    ),
    _ => _BodyContextStep(
      heightController: _heightController,
      weightController: _weightController,
      targetWeightController: _targetWeightController,
      sleepHours: _sleepHours,
      acceptedSafety: _acceptedSafety,
      showErrors: _showErrors,
      onSleepChanged: (value) => setState(() => _sleepHours = value),
      onSafetyChanged: (value) => setState(() => _acceptedSafety = value),
    ),
  };
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({
    required this.nameController,
    required this.goal,
    required this.showErrors,
    required this.onGoalChanged,
  });

  final TextEditingController nameController;
  final FitnessGoal goal;
  final bool showErrors;
  final ValueChanged<FitnessGoal> onGoalChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What should we call you?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        TextField(
          key: const Key('onboarding-name'),
          controller: nameController,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.name],
          decoration: InputDecoration(
            labelText: 'First name or nickname',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            errorText: showErrors && nameController.text.trim().length < 2
                ? 'Enter at least 2 characters'
                : null,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Your primary goal',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: FitnessGoal.values
              .map(
                (item) => ChoiceChip(
                  label: Text(item.label),
                  selected: item == goal,
                  onSelected: (_) => onGoalChanged(item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _TrainingStep extends StatelessWidget {
  const _TrainingStep({
    required this.experience,
    required this.equipment,
    required this.showErrors,
    required this.onExperienceChanged,
    required this.onEquipmentChanged,
  });

  final TrainingExperience experience;
  final Set<Equipment> equipment;
  final bool showErrors;
  final ValueChanged<TrainingExperience> onExperienceChanged;
  final ValueChanged<Set<Equipment>> onEquipmentChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Training experience',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: TrainingExperience.values
              .map(
                (item) => ChoiceChip(
                  label: Text(item.label),
                  selected: item == experience,
                  onSelected: (_) => onExperienceChanged(item),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 28),
        Text(
          'Equipment you can use',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Choose all that apply.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: Equipment.values
              .map(
                (item) => FilterChip(
                  label: Text(item.label),
                  selected: equipment.contains(item),
                  onSelected: (selected) {
                    final next = {...equipment};
                    selected ? next.add(item) : next.remove(item);
                    onEquipmentChanged(next);
                  },
                ),
              )
              .toList(),
        ),
        if (showErrors && equipment.isEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Choose at least one option',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}

class _ScheduleStep extends StatelessWidget {
  const _ScheduleStep({
    required this.days,
    required this.sessionMinutes,
    required this.onDaysChanged,
    required this.onSessionChanged,
  });

  final int days;
  final int sessionMinutes;
  final ValueChanged<int> onDaysChanged;
  final ValueChanged<int> onSessionChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$days training days each week',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Slider(
          value: days.toDouble(),
          min: 1,
          max: 7,
          divisions: 6,
          label: '$days days',
          onChanged: (value) => onDaysChanged(value.round()),
        ),
        const SizedBox(height: 24),
        Text(
          'Typical session length',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [20, 30, 45, 60, 75]
              .map(
                (minutes) => ChoiceChip(
                  label: Text('$minutes min'),
                  selected: minutes == sessionMinutes,
                  onSelected: (_) => onSessionChanged(minutes),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        const _PrivacyNote(
          icon: Icons.auto_awesome_rounded,
          text: 'FitPulse will use this schedule to favor consistency over unrealistic volume.',
        ),
      ],
    );
  }
}

class _BodyContextStep extends StatelessWidget {
  const _BodyContextStep({
    required this.heightController,
    required this.weightController,
    required this.targetWeightController,
    required this.sleepHours,
    required this.acceptedSafety,
    required this.showErrors,
    required this.onSleepChanged,
    required this.onSafetyChanged,
  });

  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController targetWeightController;
  final double sleepHours;
  final bool acceptedSafety;
  final bool showErrors;
  final ValueChanged<double> onSleepChanged;
  final ValueChanged<bool> onSafetyChanged;

  String? _numberError(
    TextEditingController controller,
    double min,
    double max,
  ) {
    final value = double.tryParse(controller.text);
    return value == null || value < min || value > max
        ? 'Enter $min–$max'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final targetText = targetWeightController.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PrivacyNote(
          icon: Icons.lock_outline_rounded,
          text: 'Stored only on this device. Weight informs trends but never defines your wellness score.',
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final fields = [
              _MetricField(
                key: const Key('onboarding-height'),
                controller: heightController,
                label: 'Height',
                suffix: 'cm',
                errorText: showErrors
                    ? _numberError(heightController, 100, 250)
                    : null,
              ),
              _MetricField(
                key: const Key('onboarding-weight'),
                controller: weightController,
                label: 'Current weight',
                suffix: 'kg',
                errorText: showErrors
                    ? _numberError(weightController, 30, 350)
                    : null,
              ),
              _MetricField(
                key: const Key('onboarding-target-weight'),
                controller: targetWeightController,
                label: 'Target weight (optional)',
                suffix: 'kg',
                errorText: showErrors && targetText.isNotEmpty
                    ? _numberError(targetWeightController, 30, 350)
                    : null,
              ),
            ];
            if (constraints.maxWidth < 620) {
              return Column(
                children: fields
                    .map(
                      (field) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: field,
                      ),
                    )
                    .toList(),
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fields
                  .map(
                    (field) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: field,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 18),
        Text(
          '${sleepHours.toStringAsFixed(1)} hours of sleep',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: sleepHours,
          min: 4,
          max: 10,
          divisions: 12,
          label: '${sleepHours.toStringAsFixed(1)} h',
          onChanged: onSleepChanged,
        ),
        Material(
          type: MaterialType.transparency,
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: acceptedSafety,
            onChanged: (value) => onSafetyChanged(value ?? false),
            title: const Text(
              'I understand FitPulse provides fitness guidance, not medical advice.',
            ),
            subtitle: showErrors && !acceptedSafety
                ? Text(
                    'Required to continue',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _MetricField extends StatelessWidget {
  const _MetricField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.errorText,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        errorText: errorText,
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

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
            Icon(icon, color: scheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _OnboardingGlow extends StatelessWidget {
  const _OnboardingGlow({required this.color});

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
        child: const SizedBox.square(dimension: 680),
      ),
    );
  }
}
