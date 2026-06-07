import 'package:isar/isar.dart';

part 'cached_transaction.g.dart';

@collection
class CachedTransaction {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String localId = '';

  @Index()
  String providerId = '';

  String type = '';

  @Index()
  String status = '';

  int amountMinorUnits = 0;
  String currency = 'BDT';

  @Index()
  String? providerTxnId;

  String? recipientPhone;
  String? merchantName;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
