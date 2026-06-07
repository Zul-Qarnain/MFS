import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric prompt wrapper around `local_auth`.
///
/// Biometric templates never cross the Dart bridge — we only receive a
/// boolean success/failure. See SECURITY_REVIEW.md §4.
class BiometricService {
  BiometricService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  Future<bool> isAvailable() async {
    final available = await _localAuth.canCheckBiometrics;
    final deviceSupported = await _localAuth.isDeviceSupported();
    return available && deviceSupported;
  }

  Future<bool> authenticate({String reason = 'Authenticate to access MFS Unified'}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
