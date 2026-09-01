import 'package:fitpulse/features/auth/domain/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators', () {
    test('accepts valid names and rejects short names', () {
      expect(AuthValidators.name('A'), isNotNull);
      expect(AuthValidators.name('Alex Morgan'), isNull);
    });

    test('accepts valid email addresses and rejects malformed values', () {
      expect(AuthValidators.email('alex@example.com'), isNull);
      expect(AuthValidators.email('alex@invalid'), isNotNull);
    });

    test('requires a strong baseline password', () {
      expect(AuthValidators.password('short'), isNotNull);
      expect(AuthValidators.password('FitPulse2026'), isNull);
    });
  });
}
