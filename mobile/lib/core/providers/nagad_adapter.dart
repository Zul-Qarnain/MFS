import 'payment_models.dart';
import 'provider_adapter.dart';
import 'provider_id.dart';

/// Mock Nagad adapter — returns deterministic responses conforming to the
/// same DTOs the live adapter will. Swap to live endpoints when merchant
/// credentials are onboarded (RISK_REGISTER.md R-PRV-01).
class NagadAdapter implements ProviderAdapter {
  @override
  ProviderId get id => ProviderId.nagad;

  @override
  Future<PaymentInitiation> initiate(PaymentRequest req) async {
    if (req.type == 'MERCHANT_PAYMENT') {
      return PaymentInitiation(
        providerTxnId: 'NAGAD-M-${DateTime.now().millisecondsSinceEpoch}',
        redirectUrl: 'https://sandbox.mynagad.com/mock?id=${req.idempotencyKey}',
        status: 'INITIATED',
      );
    }
    return launchDialerPassThrough(req);
  }

  @override
  Future<PaymentInitiation> launchDialerPassThrough(PaymentRequest req) async {
    final taka = req.amountMinorUnits ~/ 100;
    final ussd = '*167*1*${req.recipientPhone ?? ''}*$taka#';
    return PaymentInitiation(
      providerTxnId: 'NAGAD-D-${DateTime.now().millisecondsSinceEpoch}',
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
        providerId: ProviderId.nagad,
        type: 'MERCHANT_PAYMENT',
        status: 'SUCCESS',
        amountMinorUnits: 0,
        currency: 'BDT',
      );
}
