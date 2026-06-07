import 'payment_models.dart';
import 'provider_adapter.dart';
import 'provider_id.dart';

/// Mock Rocket adapter — DBBL has no public developer API, so this
/// adapter returns deterministic mocks until an onboarding contract is
/// in place (RISK_REGISTER.md R-PRV-02).
class RocketAdapter implements ProviderAdapter {
  @override
  ProviderId get id => ProviderId.rocket;

  @override
  Future<PaymentInitiation> initiate(PaymentRequest req) async {
    if (req.type == 'MERCHANT_PAYMENT') {
      return PaymentInitiation(
        providerTxnId: 'ROCKET-M-${DateTime.now().millisecondsSinceEpoch}',
        redirectUrl: 'https://sandbox.rocket.example.com/mock?id=${req.idempotencyKey}',
        status: 'INITIATED',
      );
    }
    return launchDialerPassThrough(req);
  }

  @override
  Future<PaymentInitiation> launchDialerPassThrough(PaymentRequest req) async {
    final taka = req.amountMinorUnits ~/ 100;
    final ussd = '*322*1*${req.recipientPhone ?? ''}*$taka#';
    return PaymentInitiation(
      providerTxnId: 'ROCKET-D-${DateTime.now().millisecondsSinceEpoch}',
      status: 'INITIATED',
      instructions: PaymentInstructions(method: 'DIALER_PASS_THROUGH', ussdString: ussd),
    );
  }

  @override
  Future<PaymentStatus> pollStatus(String providerTxnId) async => PaymentStatus(
        providerTxnId: providerTxnId,
        status: 'SUCCESS',
        updatedAt: DateTime.now().toIso8601String(),
      );

  @override
  Future<PaymentReceipt> fetchReceipt(String providerTxnId) async => PaymentReceipt(
        providerTxnId: providerTxnId,
        providerId: ProviderId.rocket,
        type: 'MERCHANT_PAYMENT',
        status: 'SUCCESS',
        amountMinorUnits: 0,
        currency: 'BDT',
      );
}
