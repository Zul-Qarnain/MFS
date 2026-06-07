/// Bangladesh E.164 phone number value object.
class PhoneNumber {
  PhoneNumber._(this._raw);

  final String _raw;

  static final RegExp _e164 = RegExp(r'^\+880\d{10}$');
  static final RegExp _local = RegExp(r'^0\d{10}$');

  /// Parse and validate a Bangladesh phone number. Accepts `+880…` or
  /// local `0…` (auto-converted to E.164).
  factory PhoneNumber.parse(String input) {
    final trimmed = input.trim();
    if (_e164.hasMatch(trimmed)) return PhoneNumber._(trimmed);
    if (_local.hasMatch(trimmed)) return PhoneNumber._('+88${trimmed.substring(1)}');
    throw FormatException('Invalid Bangladesh phone number: $input');
  }

  String get e164 => _raw;

  /// `+880 1XXX-XXXXXX`
  String display() {
    final digits = _raw.substring(4);
    return '+880 ${digits.substring(0, 4)}-${digits.substring(4)}';
  }

  @override
  String toString() => _raw;

  @override
  bool operator ==(Object other) => other is PhoneNumber && other._raw == _raw;

  @override
  int get hashCode => _raw.hashCode;
}
