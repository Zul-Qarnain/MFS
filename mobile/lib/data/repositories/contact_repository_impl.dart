import 'package:isar/isar.dart';

import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/local/cached_contact.dart';

class ContactRepositoryImpl implements ContactRepository {
  ContactRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<List<Contact>> getAll() async {
    final rows = await _isar.cachedContacts.where().sortByName().findAll();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<List<Contact>> getFavorites() async {
    final rows = await _isar.cachedContacts.filter().isFavoriteEqualTo(true).findAll();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<Contact?> findById(String id) async {
    final row = await _isar.cachedContacts.filter().localIdEqualTo(id).findFirst();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<Contact?> findByPhone(String phone) async {
    final row = await _isar.cachedContacts.filter().phoneNumberEqualTo(phone).findFirst();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<Contact> save(Contact c) async {
    final existing = await _isar.cachedContacts.filter().localIdEqualTo(c.id).findFirst();
    final cached = existing ?? CachedContact();
    cached
      ..localId = c.id
      ..name = c.name
      ..phoneNumber = c.phoneNumber
      ..providerId = c.providerId
      ..isFavorite = c.isFavorite
      ..lastUsedAt = c.lastUsedAt
      ..createdAt = c.createdAt;

    await _isar.writeTxn(() async {
      await _isar.cachedContacts.put(cached);
    });
    return _toEntity(cached);
  }

  @override
  Future<void> delete(String id) async {
    await _isar.writeTxn(() async {
      await _isar.cachedContacts.filter().localIdEqualTo(id).deleteFirst();
    });
  }

  @override
  Stream<List<Contact>> watchAll() =>
      _isar.cachedContacts.where().sortByName().watch(fireImmediately: true).map(
            (rows) => rows.map(_toEntity).toList(growable: false),
          );

  Contact _toEntity(CachedContact r) => Contact(
        id: r.localId,
        name: r.name,
        phoneNumber: r.phoneNumber,
        providerId: r.providerId,
        isFavorite: r.isFavorite,
        lastUsedAt: r.lastUsedAt,
        createdAt: r.createdAt,
      );
}
