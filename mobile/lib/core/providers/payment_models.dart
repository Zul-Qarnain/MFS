import 'package:freezed_annotation/freezed_annotation.dart';

import 'provider_id.dart';

part 'payment_models.freezed.dart';

/// Payment request sent from the client to the Provider Integration
/// Service. MUST NOT contain a provider PIN (see SECURITY_REVIEW.md §2).
@freezed
class PaymentRequest with _$PaymentRequest {
  const factory PaymentRequest({
    required ProviderId providerId,
    required String type,
    required int amountMinorUnits,
    required String currency,
    required String idempotencyKey,
    String? recipientPhone,
    String? merchantName,
    String? deviceFingerprint,
  }) = _PaymentRequest;
}

@freezed
class PaymentInitiation with _$PaymentInitiation {
  const factory PaymentInitiation({
    String? providerTxnId,
    String? redirectUrl,
    required String status,
    String? expiresAt,
    PaymentInstructions? instructions,
  }) = _PaymentInitiation;
}

@freezed
class PaymentInstructions with _$PaymentInstructions {
  const factory PaymentInstructions({
    required String method, // API | DIALER_PASS_THROUGH | PROVIDER_APP
    String? ussdString,
  }) = _PaymentInstructions;
}

@freezed
class PaymentStatus with _$PaymentStatus {
  const factory PaymentStatus({
    required String providerTxnId,
    required String status,
    required String updatedAt,
  }) = _PaymentStatus;
}

@freezed
class PaymentReceipt with _$PaymentReceipt {
  const factory PaymentReceipt({
    required String providerTxnId,
    required ProviderId providerId,
    required String type,
    required String status,
    required int amountMinorUnits,
    required String currency,
    String? recipientPhone,
    String? merchantName,
    int? feeMinorUnits,
    String? completedAt,
  }) = _PaymentReceipt;
}
