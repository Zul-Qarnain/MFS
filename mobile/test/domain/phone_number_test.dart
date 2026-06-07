import 'package:flutter_test/flutter_test.dart';

import 'package:mfs_unified/domain/value_objects/phone_number.dart';

void main() {
  group('PhoneNumber', () {
    test('accepts E.164 Bangladesh numbers', () {
      final n = PhoneNumber.parse('+8801712345678');
      expect(n.e164, '+8801712345678');
      expect(n.display(), '+880 1712-345678');
    });

    test('converts local format to E.164', () {
      expect(PhoneNumber.parse('01712345678').e164, '+8801712345678');
    });

    test('rejects non-Bangladesh numbers', () {
      expect(() => PhoneNumber.parse('+14155552671'), throwsFormatException);
    });

    test('rejects short numbers', () {
      expect(() => PhoneNumber.parse('+88017123'), throwsFormatException);
    });
  });
}
