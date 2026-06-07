import '../../core/providers/payment_models.dart';
import '../../core/providers/provider_id.dart';
import '../../core/providers/provider_integration_service.dart';
import '../../domain/repositories/provider_repository.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  ProviderRepositoryImpl(this._service);

  final ProviderIntegrationService _service;

  @override
  List<ProviderId> get available => _service.available;

  @override
  Future<PaymentInitiation> initiate(PaymentRequest req) => _service.initiate(req);

  @override
  Future<PaymentStatus> pollStatus(ProviderId id, String providerTxnId) =>
      _service.pollStatus(id, providerTxnId);

  @override
  Future<PaymentReceipt> fetchReceipt(ProviderId id, String providerTxnId) =>
      _service.fetchReceipt(id, providerTxnId);

  @override
  Future<PaymentInitiation> launchDialerPassThrough(PaymentRequest req) =>
      _service.launchDialerPassThrough(req);
}
