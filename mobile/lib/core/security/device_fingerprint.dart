import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Composes a stable device fingerprint from Android device fields and a
/// per-install salt. Used as `X-Device-Fingerprint` on authenticated
/// requests (see SECURITY_REVIEW.md §5).
class DeviceFingerprint {
  DeviceFingerprint({
    FlutterSecureStorage? storage,
    DeviceInfoPlugin? deviceInfo,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final FlutterSecureStorage _storage;
  final DeviceInfoPlugin _deviceInfo;

  static const String _saltKey = 'mfs_device_salt_v1';

  Future<String> compute() async {
    final android = await _deviceInfo.androidInfo;
    final salt = await _loadOrCreateSalt();

    final parts = [
      android.id,
      android.brand,
      android.model,
      android.manufacturer,
      android.version.release,
      salt,
    ].join('|');

    return sha256.convert(utf8.encode(parts)).toString();
  }

  Future<String> _loadOrCreateSalt() async {
    final existing = await _storage.read(key: _saltKey);
    if (existing != null) return existing;

    final bytes = List<int>.generate(32, (_) => DateTime.now().microsecondsSinceEpoch & 0xff);
    final encoded = base64Url.encode(bytes);
    await _storage.write(key: _saltKey, value: encoded);
    return encoded;
  }
}
