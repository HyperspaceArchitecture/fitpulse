/// Pure validation rules shared by authentication forms.
abstract final class AuthValidators {
  static final _emailPattern = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
  );

  /// Validates a human-readable name.
  static String? name(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return 'Enter your name';
    if (normalized.length < 2) return 'Name must contain at least 2 characters';
    return null;
  }

  /// Validates a conventional email address without altering it.
  static String? email(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return 'Enter your email address';
    if (!_emailPattern.hasMatch(normalized)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Enforces a reasonable client-side password baseline.
  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter your password';
    if (password.length < 10) return 'Use at least 10 characters';
    if (!password.contains(RegExp('[A-Z]'))) return 'Add an uppercase letter';
    if (!password.contains(RegExp('[0-9]'))) return 'Add a number';
    return null;
  }
}
