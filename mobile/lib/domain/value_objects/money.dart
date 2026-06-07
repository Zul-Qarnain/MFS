import 'package:intl/intl.dart';

/// Immutable monetary value in **minor units** (paisa for BDT).
///
/// All arithmetic stays in integers to avoid floating-point drift.
/// Use [format] to render a user-visible string (`৳1,500.00`).
class Money {
  const Money({required this.minorUnits, this.currency = 'BDT'});

  final int minorUnits;
  final String currency;

  Money operator +(Money other) {
    assert(currency == other.currency, 'Currency mismatch');
    return Money(minorUnits: minorUnits + other.minorUnits, currency: currency);
  }

  Money operator -(Money other) {
    assert(currency == other.currency, 'Currency mismatch');
    return Money(minorUnits: minorUnits - other.minorUnits, currency: currency);
  }

  static Money fromMajor(double major, {String currency = 'BDT'}) =>
      Money(minorUnits: (major * 100).round(), currency: currency);

  double toMajor() => minorUnits / 100;

  String format() {
    final formatter = NumberFormat.currency(
      locale: 'en_BD',
      symbol: currency == 'BDT' ? '৳' : '$currency ',
      decimalDigits: 2,
    );
    return formatter.format(toMajor());
  }
}
