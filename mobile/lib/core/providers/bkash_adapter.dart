import 'payment_models.dart';
import 'provider_adapter.dart';
import 'provider_id.dart';

/// Mock bKash adapter.
///
/// Phase B scope: LIVE for Tokenized Checkout merchant payments via the
/// backend; MOCK + dialer pass-through for P2P and Cash Out.
class BkashAdapter implements ProviderAdapter {
  @override
  ProviderId get id => ProviderId.bkash;

  @override
  Future<PaymentInitiation> initiate(PaymentRequest req) async {
    if (req.type == 'MERCHANT_PAYMENT') {
      return PaymentInitiation(
        providerTxnId: 'BKASH-M-${DateTime.now().millisecondsSinceEpoch}',
        redirectUrl: 'https://checkout.sandbox.bka.sh/mock?id=${req.idempotencyKey}',
        status: 'INITIATED',
        expiresAt: DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
      );
    }
    return launchDialerPassThrough(req);
  }

  @override
  Future<PaymentInitiation> launchDialerPassThrough(PaymentRequest req) async {
    final taka = req.amountMinorUnits ~/ 100;
    final ussd = '*247*1*${req.recipientPhone ?? ''}*$taka#';
    return PaymentInitiation(
      providerTxnId: 'BKASH-D-${DateTime.now().millisecondsSinceEpoch}',
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
        providerId: ProviderId.bkash,
        type: 'MERCHANT_PAYMENT',
        status: 'SUCCESS',
        amountMinorUnits: 0,
        currency: 'BDT',
        feeMinorUnits: 0,
        completedAt: DateTime.now().toIso8601String(),
      );
}
