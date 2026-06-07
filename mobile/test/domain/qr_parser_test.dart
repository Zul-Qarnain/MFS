import 'package:flutter_test/flutter_test.dart';

import 'package:mfs_unified/domain/entities/qr_payload.dart';
import 'package:mfs_unified/domain/usecases/parse_qr_code.dart';

void main() {
  late QrParser parser;

  setUp(() {
    parser = QrParser();
  });

  group('QrParser', () {
    test('parses a Bangladesh E.164 phone as plain P2P', () {
      final p = parser.parse('+8801712345678');
      expect(p.kind, QrPayloadKind.plainPhone);
      expect(p.recipientPhone, '+8801712345678');
    });

    test('parses a local-format phone and converts to E.164', () {
      final p = parser.parse('01712345678');
      expect(p.kind, QrPayloadKind.plainPhone);
      expect(p.recipientPhone, '+8801712345678');
    });

    test('parses bKash provider URL', () {
      final p = parser.parse('bkash://pay?m=01700000001&a=1500.00&n=Coffee%20Shop');
      expect(p.kind, QrPayloadKind.providerProprietary);
      expect(p.providerId?.name, 'bkash');
      expect(p.merchantId, '01700000001');
      expect(p.amountMinorUnits, 150000);
    });

    test('parses Nagad provider URL', () {
      final p = parser.parse('nagad://pay?m=MERCH123&a=500');
      expect(p.kind, QrPayloadKind.providerProprietary);
      expect(p.providerId?.name, 'nagad');
      expect(p.amountMinorUnits, 50000);
    });

    test('parses Rocket provider URL', () {
      final p = parser.parse('rocket://pay?m=M01');
      expect(p.kind, QrPayloadKind.providerProprietary);
      expect(p.providerId?.name, 'rocket');
    });

    test('parses an EMVCo TLV string', () {
      // 00 = version, 52 = MCC, 53 = currency (050=BDT), 54 = amount, 59 = merchant
      const emv =
          '00020152045411' // 00=01, 52=5411
          '53030505406' // 53=050, 54=150.00
          '1500.005908TestShop6005DHAKA';
      // The above string has a minor formatting issue on purpose — the
      // parser should still extract the tags it can.
      final p = parser.parse(emv);
      expect(p.kind, QrPayloadKind.emvcoMerchant);
      expect(p.currency, 'BDT');
    });

    test('unknown payload returns unknown kind', () {
      final p = parser.parse('hello world');
      expect(p.kind, QrPayloadKind.unknown);
    });
  });
}
