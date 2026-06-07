import 'package:flutter_test/flutter_test.dart';

import 'package:mfs_unified/domain/value_objects/money.dart';

void main() {
  group('Money', () {
    test('formats BDT with taka symbol and grouping', () {
      const m = Money(minorUnits: 150000, currency: 'BDT');
      expect(m.toMajor(), 1500.0);
      expect(m.format(), contains('1,500'));
      expect(m.format(), contains('৳'));
    });

    test('addition preserves currency', () {
      const a = Money(minorUnits: 100);
      const b = Money(minorUnits: 200);
      expect((a + b).minorUnits, 300);
    });

    test('fromMajor round-trip', () {
      expect(Money.fromMajor(12.34).minorUnits, 1234);
    });
  });
}
