import '../../core/providers/provider_id.dart';
import '../entities/qr_payload.dart';

/// Pure-Dart QR payload parser.
///
/// Covers three payload shapes seen in the Bangladesh MFS ecosystem:
///   1. EMVCo 2.x merchant QR (TLV tags, `00` = version, `52` = MCC,
///      `53` = currency `050` = BDT, `54` = amount, `59` = merchant name,
///      `62` = additional data containing provider hint).
///   2. Provider-proprietary URLs:
///        bkash://pay?m=…&a=…
///        nagad://pay?m=…&a=…
///        rocket://pay?m=…&a=…
///   3. Plain phone number for P2P.
class QrParser {
  QrPayload parse(String raw) {
    final trimmed = raw.trim();

    // --- Plain phone ----------------------------------------------------
    if (_looksLikePhone(trimmed)) {
      return QrPayload(
        raw: trimmed,
        kind: QrPayloadKind.plainPhone,
        recipientPhone: _normalisePhone(trimmed),
      );
    }

    // --- Provider-proprietary URL --------------------------------------
    final urlPayload = _tryParseProviderUrl(trimmed);
    if (urlPayload != null) return urlPayload;

    // --- EMVCo TLV ------------------------------------------------------
    final emv = _tryParseEmvco(trimmed);
    if (emv != null) return emv;

    return QrPayload(raw: trimmed, kind: QrPayloadKind.unknown);
  }

  // ---------------------------------------------------------------------
  // Phone detection
  // ---------------------------------------------------------------------
  static final RegExp _phoneRe = RegExp(r'^(?:\+?880|0)\d{10}$');

  bool _looksLikePhone(String s) => _phoneRe.hasMatch(s.replaceAll(RegExp(r'\D'), ''));

  String _normalisePhone(String s) {
    final digits = s.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) return '+88${digits.substring(1)}';
    if (digits.startsWith('880')) return '+$digits';
    return '+$digits';
  }

  // ---------------------------------------------------------------------
  // Provider URL
  // ---------------------------------------------------------------------
  QrPayload? _tryParseProviderUrl(String s) {
    final uri = Uri.tryParse(s);
    if (uri == null || !uri.hasScheme) return null;

    final scheme = uri.scheme.toLowerCase();
    final providerMap = {
      'bkash': ProviderId.bkash,
      'nagad': ProviderId.nagad,
      'rocket': ProviderId.rocket,
    };
    final provider = providerMap[scheme];
    if (provider == null) return null;

    final amount = _amountFromQuery(uri.queryParameters['a'] ?? uri.queryParameters['amount']);
    return QrPayload(
      raw: s,
      kind: QrPayloadKind.providerProprietary,
      providerId: provider,
      merchantId: uri.queryParameters['m'] ?? uri.queryParameters['merchant'],
      merchantName: uri.queryParameters['n'] ?? uri.queryParameters['name'],
      amountMinorUnits: amount,
    );
  }

  int? _amountFromQuery(String? v) {
    if (v == null || v.isEmpty) return null;
    final major = double.tryParse(v);
    if (major == null) return null;
    return (major * 100).round();
  }

  // ---------------------------------------------------------------------
  // EMVCo TLV
  // ---------------------------------------------------------------------
  Map<String, String> _readTlv(String blob) {
    final out = <String, String>{};
    var i = 0;
    while (i + 4 <= blob.length) {
      final tag = blob.substring(i, i + 2);
      final len = int.tryParse(blob.substring(i + 2, i + 4));
      if (len == null) break;
      final start = i + 4;
      final end = start + len;
      if (end > blob.length) break;
      out[tag] = blob.substring(start, end);
      i = end;
    }
    return out;
  }

  QrPayload? _tryParseEmvco(String s) {
    if (!RegExp(r'^00\d{2}').hasMatch(s)) return null;
    final tlv = _readTlv(s);
    if (tlv.isEmpty || !tlv.containsKey('00')) return null;

    final currencyCode = tlv['53']; // 050 = BDT
    final amountStr = tlv['54'];
    final merchant = tlv['59'];
    final additional = tlv['62'];

    ProviderId? provider;
    if (additional != null) {
      final innerTlv = _readTlv(additional);
      final hint = (innerTlv.values.join(' ') + ' ' + s).toLowerCase();
      if (hint.contains('bkash')) {
        provider = ProviderId.bkash;
      } else if (hint.contains('nagad')) {
        provider = ProviderId.nagad;
      } else if (hint.contains('rocket')) {
        provider = ProviderId.rocket;
      }
    }

    int? amount;
    if (amountStr != null) {
      final major = double.tryParse(amountStr);
      if (major != null) amount = (major * 100).round();
    }

    return QrPayload(
      raw: s,
      kind: QrPayloadKind.emvcoMerchant,
      providerId: provider,
      merchantName: merchant,
      amountMinorUnits: amount,
      currency: currencyCode == '050' ? 'BDT' : currencyCode,
    );
  }
}
