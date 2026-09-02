import 'dart:convert';
import 'dart:typed_data';

import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/features/nutrition/application/nutrition_controller.dart';
import 'package:fitpulse/features/nutrition/domain/nutrition_day.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/theme_selector.dart';
import 'package:fitpulse/shared/widgets/brand_mark.dart';
import 'package:fitpulse/shared/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Offline-first nutrition and hydration journal.
class NutritionPage extends ConsumerWidget {
  /// Creates the nutrition page.
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journal = ref.watch(nutritionControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Back to dashboard',
                        onPressed: () => context.go(AppRoutes.dashboard),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 12),
                      const BrandMark(),
                      const Spacer(),
                      const ThemeSelector(),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'NOURISH',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fuel the life you’re building.',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Track useful signals, not perfection. Estimates are for awareness and are not medical advice.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 26),
                  journal.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stackTrace) => _ErrorPanel(
                      onRetry: () =>
                          ref.invalidate(nutritionControllerProvider),
                    ),
                    data: (day) => _NutritionContent(day: day),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: journal.hasValue
          ? FloatingActionButton.extended(
              onPressed: () => _chooseLogMethod(context, ref),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add meal'),
            )
          : null,
    );
  }

  Future<void> _chooseLogMethod(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<_MealLogAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a dish photo'),
              subtitle: const Text('Create an editable visual estimate'),
              onTap: () => Navigator.pop(context, _MealLogAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose a dish photo'),
              subtitle: const Text('Use a photo already on this device'),
              onTap: () => Navigator.pop(context, _MealLogAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note_rounded),
              title: const Text('Log without a photo'),
              onTap: () => Navigator.pop(context, _MealLogAction.manual),
            ),
          ],
        ),
      ),
    );
    if (action == null) return;
    if (!context.mounted) return;
    if (action == _MealLogAction.manual) {
      await _showAddMeal(context, ref);
      return;
    }
    try {
      final image = await ImagePicker().pickImage(
        source: action == _MealLogAction.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 65,
      );
      if (image == null || !context.mounted) return;
      final bytes = await image.readAsBytes();
      if (!context.mounted) return;
      if (bytes.lengthInBytes > 1500000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('That photo is too large. Choose a smaller image.'),
          ),
        );
        return;
      }
      await _showAddMeal(context, ref, photoBytes: bytes);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The camera or photo picker is not available on this device.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _showAddMeal(
    BuildContext context,
    WidgetRef ref, {
    Uint8List? photoBytes,
  }) async {
    final entry = await showModalBottomSheet<NutritionEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _AddMealSheet(photoBytes: photoBytes),
    );
    if (entry != null) {
      await ref.read(nutritionControllerProvider.notifier).addEntry(entry);
    }
  }
}

enum _MealLogAction { camera, gallery, manual }

class _NutritionContent extends ConsumerWidget {
  const _NutritionContent({required this.day});

  final NutritionDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _TargetCard(
                icon: Icons.local_fire_department_outlined,
                label: 'Energy',
                value: day.energyKcal,
                target: 2200,
                unit: 'kcal',
              ),
              _TargetCard(
                icon: Icons.fitness_center_rounded,
                label: 'Protein',
                value: day.proteinGrams,
                target: 130,
                unit: 'g',
              ),
              _TargetCard(
                icon: Icons.eco_outlined,
                label: 'Fibre',
                value: day.fibreGrams,
                target: 30,
                unit: 'g',
              ),
            ];
            if (constraints.maxWidth < 760) {
              return Column(
                children: cards
                    .map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: card,
                      ),
                    )
                    .toList(),
              );
            }
            return Row(
              children: cards
                  .map(
                    (card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: card,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 12),
        GlassPanel(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Icon(
                Icons.water_drop_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hydration',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${(day.waterMillilitres / 1000).toStringAsFixed(2)} L recorded',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () =>
                    ref.read(nutritionControllerProvider.notifier).addWater(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('250 ml'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GlassPanel(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Today’s food',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text('${day.entries.length} logged'),
                ],
              ),
              const SizedBox(height: 14),
              if (day.entries.isEmpty)
                const _EmptyJournal()
              else
                ...day.entries.reversed.map(
                  (entry) => _MealTile(
                    entry: entry,
                    onDelete: () => ref
                        .read(nutritionControllerProvider.notifier)
                        .removeEntry(entry.id),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GlassPanel(
          padding: const EdgeInsets.all(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A useful next step',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(_guidanceFor(day)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _guidanceFor(NutritionDay day) {
    if (day.entries.isEmpty) {
      return 'Log one meal to reveal a practical suggestion for today.';
    }
    if (day.fibreGrams < 15) {
      return 'Add a colourful plant, wholegrain, bean, nut, or seed to your next meal.';
    }
    if (day.proteinGrams < 65) {
      return 'A palm-sized protein source could support recovery at your next meal.';
    }
    if (day.waterMillilitres < 1000) {
      return 'Keep water nearby and sip with your next meal or movement break.';
    }
    return 'You have covered several recovery basics today. Consistency matters more than a perfect number.';
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.target,
    required this.unit,
  });

  final IconData icon;
  final String label;
  final int value;
  final int target;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final progress = (value / target).clamp(0.0, 1.0);
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 18),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            '$value / $target $unit',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, minHeight: 7),
        ],
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({required this.entry, required this.onDelete});

  final NutritionEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: entry.photoBase64 == null
          ? CircleAvatar(child: Text(entry.meal.characters.first))
          : CircleAvatar(
              backgroundImage: MemoryImage(base64Decode(entry.photoBase64!)),
            ),
      title: Text(entry.name),
      subtitle: Text(
        [
          entry.meal,
          '${entry.proteinGrams} g protein',
          '${entry.fibreGrams} g fibre',
          if (entry.estimateConfidence != null) entry.estimateConfidence!,
        ].join(' • '),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${entry.energyKcal} kcal'),
          IconButton(
            tooltip: 'Remove ${entry.name}',
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _EmptyJournal extends StatelessWidget {
  const _EmptyJournal();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu_rounded,
            size: 42,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 10),
          Text(
            'Nothing logged yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text('Start with what you remember. Approximate is useful.'),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        children: [
          const Text('Your nutrition journal could not be loaded.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet({this.photoBytes});

  final Uint8List? photoBytes;

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _energyController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fibreController = TextEditingController();
  String _meal = 'Breakfast';

  @override
  void initState() {
    super.initState();
    if (widget.photoBytes != null) {
      _nameController.text = 'Photo meal';
      _energyController.text = '650';
      _proteinController.text = '30';
      _fibreController.text = '8';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _energyController.dispose();
    _proteinController.dispose();
    _fibreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Log food',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                widget.photoBytes == null
                    ? 'Use your best estimate. You can remove the entry at any time.'
                    : 'Low-confidence visual draft: portion size, ingredients and cooking oils cannot be measured from one photo. Review every value before saving.',
              ),
              if (widget.photoBytes != null) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.memory(
                    widget.photoBytes!,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                const Chip(
                  avatar: Icon(Icons.auto_awesome_rounded, size: 17),
                  label: Text('LOW-CONFIDENCE ESTIMATE — CONFIRM BELOW'),
                ),
              ],
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _meal,
                decoration: const InputDecoration(labelText: 'Meal'),
                items: const ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                    .map(
                      (meal) =>
                          DropdownMenuItem(value: meal, child: Text(meal)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _meal = value ?? _meal),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'What did you eat?',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => value == null || value.trim().length < 2
                    ? 'Enter a short description'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      controller: _energyController,
                      label: 'Energy (kcal)',
                      max: 5000,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NumberField(
                      controller: _proteinController,
                      label: 'Protein (g)',
                      max: 300,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NumberField(
                      controller: _fibreController,
                      label: 'Fibre (g)',
                      max: 100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submit,
                child: const Text('Add to today'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    Navigator.of(context).pop(
      NutritionEntry(
        id: now.microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        meal: _meal,
        energyKcal: int.parse(_energyController.text),
        proteinGrams: int.parse(_proteinController.text),
        fibreGrams: int.parse(_fibreController.text),
        loggedAt: now,
        photoBase64: widget.photoBytes == null
            ? null
            : base64Encode(widget.photoBytes!),
        estimateConfidence: widget.photoBytes == null
            ? null
            : 'Low-confidence photo estimate',
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.max,
  });

  final TextEditingController controller;
  final String label;
  final int max;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (value) {
        final parsed = int.tryParse(value ?? '');
        if (parsed == null || parsed < 0 || parsed > max) return '0–$max';
        return null;
      },
    );
  }
}
