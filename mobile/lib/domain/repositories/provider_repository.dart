import '../../core/providers/payment_models.dart';
import '../../core/providers/provider_id.dart';

/// Thin façade over [ProviderIntegrationService] that exposes use-case
/// semantics for the payment flow.
abstract class ProviderRepository {
  List<ProviderId> get available;

  Future<PaymentInitiation> initiate(PaymentRequest req);

  Future<PaymentStatus> pollStatus(ProviderId id, String providerTxnId);

  Future<PaymentReceipt> fetchReceipt(ProviderId id, String providerTxnId);

  Future<PaymentInitiation> launchDialerPassThrough(PaymentRequest req);
}
