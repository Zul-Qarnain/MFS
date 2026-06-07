import 'package:flutter_test/flutter_test.dart';

import 'package:mfs_unified/core/providers/bkash_adapter.dart';
import 'package:mfs_unified/core/providers/nagad_adapter.dart';
import 'package:mfs_unified/core/providers/payment_models.dart';
import 'package:mfs_unified/core/providers/provider_id.dart';
import 'package:mfs_unified/core/providers/rocket_adapter.dart';

PaymentRequest _merchantReq(ProviderId id) => PaymentRequest(
      providerId: id,
      type: 'MERCHANT_PAYMENT',
      amountMinorUnits: 150000,
      currency: 'BDT',
      idempotencyKey: 'test-key',
    );

PaymentRequest _p2pReq(ProviderId id) => PaymentRequest(
      providerId: id,
      type: 'P2P_SEND',
      amountMinorUnits: 50000,
      currency: 'BDT',
      idempotencyKey: 'test-key',
      recipientPhone: '+8801712345678',
    );

void main() {
  group('BkashAdapter', () {
    final adapter = BkashAdapter();

    test('merchant payment returns INITIATED with redirect', () async {
      final res = await adapter.initiate(_merchantReq(ProviderId.bkash));
      expect(res.status, 'INITIATED');
      expect(res.redirectUrl, isNotNull);
      expect(res.providerTxnId, startsWith('BKASH-M'));
    });

    test('P2P uses dialer pass-through with *247# USSD', () async {
      final res = await adapter.initiate(_p2pReq(ProviderId.bkash));
      expect(res.instructions?.method, 'DIALER_PASS_THROUGH');
      expect(res.instructions?.ussdString, contains('*247'));
      expect(res.instructions?.ussdString, contains('tel:'));
    });

    test('pollStatus returns SUCCESS', () async {
      final s = await adapter.pollStatus('BKASH-M-1');
      expect(s.status, 'SUCCESS');
    });
  });

  group('NagadAdapter', () {
    final adapter = NagadAdapter();

    test('merchant payment returns INITIATED with redirect', () async {
      final res = await adapter.initiate(_merchantReq(ProviderId.nagad));
      expect(res.status, 'INITIATED');
      expect(res.providerTxnId, startsWith('NAGAD-M'));
    });

    test('P2P uses dialer pass-through with *167# USSD', () async {
      final res = await adapter.initiate(_p2pReq(ProviderId.nagad));
      expect(res.instructions?.ussdString, contains('*167'));
    });
  });

  group('RocketAdapter', () {
    final adapter = RocketAdapter();

    test('merchant payment returns INITIATED with redirect', () async {
      final res = await adapter.initiate(_merchantReq(ProviderId.rocket));
      expect(res.providerTxnId, startsWith('ROCKET-M'));
    });

    test('P2P uses dialer pass-through with *322# USSD', () async {
      final res = await adapter.initiate(_p2pReq(ProviderId.rocket));
      expect(res.instructions?.ussdString, contains('*322'));
    });
  });
}
