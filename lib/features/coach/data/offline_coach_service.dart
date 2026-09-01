import 'package:fitpulse/features/coach/domain/coach_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Deterministic, privacy-preserving coaching fallback available offline.
class OfflineCoachService implements CoachService {
  @override
  Future<String> respond(String message) async {
    final normalized = message.toLowerCase();

    if (_containsAny(normalized, [
      'chest pain',
      'can’t breathe',
      'cannot breathe',
    ])) {
      return 'Stop exercising now. Seek urgent medical help, and contact local emergency services if symptoms are severe or worsening.';
    }
    if (_containsAny(normalized, ['pain', 'injury', 'hurt', 'dizzy'])) {
      return 'Pause the movement rather than pushing through pain. Choose a pain-free alternative and speak with a qualified clinician if it persists. FitPulse cannot diagnose injuries.';
    }
    if (_containsAny(normalized, ['tired', 'sleep', 'recovery', 'sore'])) {
      return 'Make today easier: reduce load by about 10–20%, keep two or three reps in reserve, and prioritize a regular bedtime. Consistency includes recovery days.';
    }
    if (_containsAny(normalized, ['food', 'nutrition', 'protein', 'meal'])) {
      return 'Build the next meal around a protein source, a colorful plant, a useful carbohydrate, and water. One balanced meal is more valuable than chasing a perfect day.';
    }
    if (_containsAny(normalized, [
      'motivation',
      'skip',
      'don’t want',
      'do not want',
    ])) {
      return 'Lower the starting line: commit to five minutes of the warm-up. You can stop after that, but starting usually creates the momentum you need.';
    }
    if (_containsAny(normalized, ['weight', 'scale', 'fat loss'])) {
      return 'Use the scale as one signal, not the verdict. Also watch waist, strength, sleep, resting heart rate, energy, and weekly consistency over several weeks.';
    }
    return 'Keep today simple: follow the planned session at a controlled effort, leave two reps in reserve, and note how you feel afterward so the next plan can adapt.';
  }

  bool _containsAny(String message, List<String> terms) {
    return terms.any(message.contains);
  }
}

/// Provides the currently selected coaching implementation.
final coachServiceProvider = Provider<CoachService>(
  (ref) => OfflineCoachService(),
);
