abstract class AuthRepository {
  Future<bool> isOnboarded();

  Future<bool> hasPin();

  Future<void> register({required String phone, required String name});

  Future<void> verifyOtp({
    required String sessionId,
    required String phone,
    required String otp,
    required String purpose,
  });

  Future<void> setPin(String pin);

  Future<bool> verifyPin(String pin);

  Future<void> loginWithBiometric();

  Future<void> logout();
}
