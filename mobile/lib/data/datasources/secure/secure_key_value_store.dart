import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure key-value store backed by Android Keystore.
///
/// Used for: auth refresh tokens, hashed app-unlock PIN, per-install
/// device-binding salt. NEVER used for provider PINs (architecturally
/// excluded — see SECURITY_REVIEW.md §2).
class SecureKeyValueStore {
  SecureKeyValueStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'mfs_access_token_v1';
  static const String _refreshTokenKey = 'mfs_refresh_token_v1';
  static const String _pinHashKey = 'mfs_pin_hash_v1';
  static const String _onboardedKey = 'mfs_onboarded_v1';
  static const String _biometricEnabledKey = 'mfs_bio_v1';

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);
  Future<void> writeAccessToken(String token) => _storage.write(key: _accessTokenKey, value: token);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);
  Future<void> writeRefreshToken(String token) => _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> readPinHash() => _storage.read(key: _pinHashKey);
  Future<void> writePinHash(String hash) => _storage.write(key: _pinHashKey, value: hash);

  Future<bool> isOnboarded() async => (await _storage.read(key: _onboardedKey)) == 'true';
  Future<void> setOnboarded(bool value) =>
      _storage.write(key: _onboardedKey, value: value ? 'true' : 'false');

  Future<bool> isBiometricEnabled() async =>
      (await _storage.read(key: _biometricEnabledKey)) == 'true';
  Future<void> setBiometricEnabled(bool value) =>
      _storage.write(key: _biometricEnabledKey, value: value ? 'true' : 'false');

  Future<void> clearAll() => _storage.deleteAll();
}
