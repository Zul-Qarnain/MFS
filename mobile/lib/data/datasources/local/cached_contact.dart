import 'package:isar/isar.dart';

part 'cached_contact.g.dart';

@collection
class CachedContact {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String localId = '';

  String name = '';

  @Index()
  String phoneNumber = '';

  String? providerId;

  @Index()
  bool isFavorite = false;

  DateTime? lastUsedAt;
  DateTime createdAt = DateTime.now();
}
