import 'dart:convert';

import 'package:fitpulse/features/onboarding/domain/fitness_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for the offline member profile.
abstract interface class ProfileRepository {
  /// Returns the saved profile or null for a first-time member.
  Future<FitnessProfile?> read();

  /// Replaces the current profile with [profile].
  Future<void> save(FitnessProfile profile);

  /// Removes the locally stored profile.
  Future<void> clear();
}

/// Stores non-sensitive profile data in platform preferences.
class SharedPreferencesProfileRepository implements ProfileRepository {
  /// Creates the local profile repository.
  SharedPreferencesProfileRepository(this._preferences);

  static const _key = 'profile.onboarding.v1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<FitnessProfile?> read() async {
    final encoded = await _preferences.getString(_key);
    if (encoded == null) return null;

    try {
      final decoded = jsonDecode(encoded) as Map<String, Object?>;
      return FitnessProfile.fromJson(decoded);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(FitnessProfile profile) {
    return _preferences.setString(_key, jsonEncode(profile.toJson()));
  }

  @override
  Future<void> clear() => _preferences.remove(_key);
}

/// Provides the production local profile persistence implementation.
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SharedPreferencesProfileRepository(SharedPreferencesAsync()),
);
