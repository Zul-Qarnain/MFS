/// Strongly-typed provider identifier.
enum ProviderId {
  bkash,
  nagad,
  rocket;

  String get displayName {
    switch (this) {
      case ProviderId.bkash:
        return 'bKash';
      case ProviderId.nagad:
        return 'Nagad';
      case ProviderId.rocket:
        return 'Rocket';
    }
  }
}
