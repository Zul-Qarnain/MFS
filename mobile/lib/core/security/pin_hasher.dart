import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Hashes the user's app-unlock PIN with SHA-256(salt + PIN).
///
/// The salt is unique per install and stored in flutter_secure_storage
/// (Android Keystore-backed). Provider PINs are NEVER handled here —
/// see SECURITY_REVIEW.md §2.
class PinHasher {
  PinHasher({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _saltKey = 'mfs_pin_salt_v1';

  Future<String> _loadOrCreateSalt() async {
    final existing = await _storage.read(key: _saltKey);
    if (existing != null) return existing;

    final bytes = List<int>.generate(32, (_) => DateTime.now().microsecondsSinceEpoch & 0xff);
    final encoded = base64Url.encode(bytes);
    await _storage.write(key: _saltKey, value: encoded);
    return encoded;
  }

  Future<String> hash(String pin) async {
    final salt = await _loadOrCreateSalt();
    final digest = sha256.convert(utf8.encode('$salt|$pin'));
    return digest.toString();
  }

  Future<bool> verify(String pin, String expected) async {
    final actual = await hash(pin);
    return actual == expected;
  }
}
