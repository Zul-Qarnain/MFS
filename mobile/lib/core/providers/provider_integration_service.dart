import 'bkash_adapter.dart';
import 'nagad_adapter.dart';
import 'payment_models.dart';
import 'provider_adapter.dart';
import 'provider_id.dart';
import 'rocket_adapter.dart';

/// Single entry-point into the three MFS providers.
///
/// Screens and Riverpod providers depend only on this service; they
/// never import a concrete adapter. See SYSTEM_ARCHITECTURE.md §3.
class ProviderIntegrationService {
  ProviderIntegrationService()
      : _adapters = {
          ProviderId.bkash: BkashAdapter(),
          ProviderId.nagad: NagadAdapter(),
          ProviderId.rocket: RocketAdapter(),
        };

  final Map<ProviderId, ProviderAdapter> _adapters;

  ProviderAdapter _resolve(ProviderId id) {
    final adapter = _adapters[id];
    if (adapter == null) {
      throw StateError('No adapter registered for $id');
    }
    return adapter;
  }

  List<ProviderId> get available => _adapters.keys.toList(growable: false);

  Future<PaymentInitiation> initiate(PaymentRequest req) => _resolve(req.providerId).initiate(req);

  Future<PaymentStatus> pollStatus(ProviderId id, String providerTxnId) =>
      _resolve(id).pollStatus(providerTxnId);

  Future<PaymentReceipt> fetchReceipt(ProviderId id, String providerTxnId) =>
      _resolve(id).fetchReceipt(providerTxnId);

  Future<PaymentInitiation> launchDialerPassThrough(PaymentRequest req) =>
      _resolve(req.providerId).launchDialerPassThrough(req);
}
