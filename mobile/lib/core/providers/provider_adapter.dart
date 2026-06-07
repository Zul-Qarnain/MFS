import 'payment_models.dart';
import 'provider_id.dart';

/// Abstract adapter contract. Each provider (bKash / Nagad / Rocket)
/// implements this interface. Swapping a mock for a live adapter
/// requires no changes to screens or repositories — see
/// ARCHITECTURE_DECISIONS.md AD-001.
abstract class ProviderAdapter {
  ProviderId get id;

  Future<PaymentInitiation> initiate(PaymentRequest req);

  Future<PaymentStatus> pollStatus(String providerTxnId);

  Future<PaymentReceipt> fetchReceipt(String providerTxnId);

  /// Build a dialer pass-through intent for transaction types without a
  /// public provider API (P2P, Cash Out).
  Future<PaymentInitiation> launchDialerPassThrough(PaymentRequest req);
}
