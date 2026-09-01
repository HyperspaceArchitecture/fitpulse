import 'package:fitpulse/features/coach/data/offline_coach_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final coach = OfflineCoachService();

  test('prioritizes urgent symptoms over training guidance', () async {
    final response = await coach.respond('I have chest pain and feel tired');

    expect(response, contains('Stop exercising now'));
    expect(response, contains('emergency services'));
  });

  test('frames weight as one signal among non-scale outcomes', () async {
    final response = await coach.respond('The scale weight is stuck');

    expect(response, contains('one signal'));
    expect(response, contains('strength'));
    expect(response, contains('sleep'));
  });
}
