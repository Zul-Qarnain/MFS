import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/providers/provider_id.dart';

part 'qr_payload.freezed.dart';

/// Parsed content of a QR code scanned on the QR Scanner screen.
///
/// Supports three payload families:
///   1. **EMVCo merchant** (tag-length-value, used by all BD providers).
///   2. **Provider-proprietary** (URL or compact string).
///   3. **Plain phone** (`+880…` or `01…`) for P2P.
@freezed
class QrPayload with _$QrPayload {
  const factory QrPayload({
    required String raw,
    required QrPayloadKind kind,
    ProviderId? providerId,
    String? recipientPhone,
    int? amountMinorUnits,
    String? merchantName,
    String? merchantId,
    String? currency,
  }) = _QrPayload;
}

enum QrPayloadKind {
  emvcoMerchant,
  providerProprietary,
  plainPhone,
  unknown,
}
