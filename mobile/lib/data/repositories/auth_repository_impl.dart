import '../../core/security/biometric_service.dart';
import '../../core/security/pin_hasher.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/secure/secure_key_value_store.dart';

/// Placeholder auth repository — wires secure storage, PIN hashing, and
/// biometrics. The full backend round-trip (register → verify-otp →
/// set-pin → login) will be filled in during the validation sprint.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required SecureKeyValueStore secureStore,
    required PinHasher pinHasher,
    required BiometricService biometric,
  })  : _secureStore = secureStore,
        _pinHasher = pinHasher,
        _biometric = biometric;

  final SecureKeyValueStore _secureStore;
  final PinHasher _pinHasher;
  final BiometricService _biometric;

  @override
  Future<bool> isOnboarded() => _secureStore.isOnboarded();

  @override
  Future<bool> hasPin() async => (await _secureStore.readPinHash()) != null;

  @override
  Future<void> register({required String phone, required String name}) async {
    // TODO(validation sprint): call AuthApi.register, store sessionId in memory.
    await _secureStore.setOnboarded(true);
  }

  @override
  Future<void> verifyOtp({
    required String sessionId,
    required String phone,
    required String otp,
    required String purpose,
  }) async {
    // TODO(validation sprint): call AuthApi.verifyOtp.
  }

  @override
  Future<void> setPin(String pin) async {
    final hash = await _pinHasher.hash(pin);
    await _secureStore.writePinHash(hash);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final stored = await _secureStore.readPinHash();
    if (stored == null) return false;
    return _pinHasher.verify(pin, stored);
  }

  @override
  Future<void> loginWithBiometric() async {
    final enabled = await _secureStore.isBiometricEnabled();
    if (!enabled) throw StateError('Biometric login not enabled');
    final ok = await _biometric.authenticate();
    if (!ok) throw StateError('Biometric authentication failed');
  }

  @override
  Future<void> logout() async {
    await _secureStore.clearAll();
  }
}
