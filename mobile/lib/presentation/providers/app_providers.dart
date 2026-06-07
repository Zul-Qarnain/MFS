import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

part 'app_providers.g.dart';

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
// Repositories (wait for Isar via async providers)
// -----------------------------------------------------------------------------

@Riverpod(keepAlive: true)
Future<TransactionRepository> transactionRepository(Ref ref) async {
  final isar = await ref.watch(isarClientProvider.future);
  return TransactionRepositoryImpl(isar);
}

@Riverpod(keepAlive: true)
Future<ContactRepository> contactRepository(Ref ref) async {
  final isar = await ref.watch(isarClientProvider.future);
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

@riverpod
class IsOnboarded extends _$IsOnboarded {
  @override
  Future<bool> build() => ref.watch(authRepositoryProvider).isOnboarded();
}

@riverpod
class HasPin extends _$HasPin {
  @override
  Future<bool> build() => ref.watch(authRepositoryProvider).hasPin();
}
