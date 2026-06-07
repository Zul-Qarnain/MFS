import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../core/network/api_client.dart';
import '../../core/providers/provider_integration_service.dart';
import '../../core/security/biometric_service.dart';
import '../../core/security/device_fingerprint.dart';
import '../../core/security/pin_hasher.dart';
import '../../data/datasources/local/isar_client.dart';
import '../../data/datasources/secure/secure_key_value_store.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/contact_repository_impl.dart';
import '../../data/repositories/provider_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/contact_repository.dart';
import '../../domain/repositories/provider_repository.dart';
import '../../domain/repositories/transaction_repository.dart';

const String kApiBaseUrl = String.fromEnvironment(
  'MFS_API_BASE_URL',
  defaultValue: 'http://10.0.2.2:4000',
);

// -----------------------------------------------------------------------------
// Infrastructure
// -----------------------------------------------------------------------------

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient(baseUrl: kApiBaseUrl);
}

@Riverpod(keepAlive: true)
SecureKeyValueStore secureStore(Ref ref) => SecureKeyValueStore();

@Riverpod(keepAlive: true)
PinHasher pinHasher(Ref ref) => PinHasher();

@Riverpod(keepAlive: true)
BiometricService biometricService(Ref ref) => BiometricService();

@Riverpod(keepAlive: true)
DeviceFingerprint deviceFingerprint(Ref ref) => DeviceFingerprint();

@Riverpod(keepAlive: true)
ProviderIntegrationService providerIntegrationService(Ref ref) => ProviderIntegrationService();

// -----------------------------------------------------------------------------
// Isar — async initialisation
// -----------------------------------------------------------------------------

@Riverpod(keepAlive: true)
Future<Isar> isarClient(Ref ref) => openIsar();

// -----------------------------------------------------------------------------
// Repositories (wait for Isar via AsyncValue.whenData)
// -----------------------------------------------------------------------------

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  final isar = ref.watch(isarClientProvider).valueOrNull;
  if (isar == null) throw StateError('Isar not yet open');
  return TransactionRepositoryImpl(isar);
}

@Riverpod(keepAlive: true)
ContactRepository contactRepository(Ref ref) {
  final isar = ref.watch(isarClientProvider).valueOrNull;
  if (isar == null) throw StateError('Isar not yet open');
  return ContactRepositoryImpl(isar);
}

@Riverpod(keepAlive: true)
ProviderRepository providerRepository(Ref ref) {
  final service = ref.watch(providerIntegrationServiceProvider);
  return ProviderRepositoryImpl(service);
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
      secureStore: ref.watch(secureStoreProvider),
      pinHasher: ref.watch(pinHasherProvider),
      biometric: ref.watch(biometricServiceProvider),
    );

// -----------------------------------------------------------------------------
// Auth state queries
// -----------------------------------------------------------------------------

@Riverpod
Future<bool> isOnboarded(Ref ref) => ref.watch(authRepositoryProvider).isOnboarded();

@Riverpod
Future<bool> hasPin(Ref ref) => ref.watch(authRepositoryProvider).hasPin();
