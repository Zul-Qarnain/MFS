import 'package:isar/isar.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/cached_transaction.dart';

/// Isar-backed transaction repository.
///
/// Phase B writes through to Isar immediately and syncs to the backend
/// asynchronously. Read-through serves from Isar first. Server wins on
/// conflict (see SYSTEM_ARCHITECTURE.md §4.2).
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<List<Transaction>> getRecent({int limit = 20}) async {
    final rows = await _isar.cachedTransactions
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<Transaction?> findById(String id) async {
    final row = await _isar.cachedTransactions.filter().localIdEqualTo(id).findFirst();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<Transaction?> findByProviderTxnId(String providerTxnId) async {
    final row =
        await _isar.cachedTransactions.filter().providerTxnIdEqualTo(providerTxnId).findFirst();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<Transaction> save(Transaction tx) async {
    final existing =
        await _isar.cachedTransactions.filter().localIdEqualTo(tx.id).findFirst();
    final cached = existing ?? CachedTransaction();
    cached
      ..localId = tx.id
      ..providerId = tx.providerId
      ..type = tx.type
      ..status = tx.status
      ..amountMinorUnits = tx.amountMinorUnits
      ..currency = tx.currency
      ..providerTxnId = tx.providerTxnId
      ..recipientPhone = tx.recipientPhone
      ..merchantName = tx.merchantName
      ..createdAt = tx.createdAt
      ..updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.cachedTransactions.put(cached);
    });
    return _toEntity(cached);
  }

  @override
  Future<void> delete(String id) async {
    await _isar.writeTxn(() async {
      await _isar.cachedTransactions.filter().localIdEqualTo(id).deleteFirst();
    });
  }

  @override
  Stream<List<Transaction>> watchAll() =>
      _isar.cachedTransactions.where().sortByCreatedAtDesc().watch(fireImmediately: true).map(
            (rows) => rows.map(_toEntity).toList(growable: false),
          );

  Transaction _toEntity(CachedTransaction r) => Transaction(
        id: r.localId,
        providerId: r.providerId,
        type: r.type,
        status: r.status,
        amountMinorUnits: r.amountMinorUnits,
        currency: r.currency,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        providerTxnId: r.providerTxnId,
        recipientPhone: r.recipientPhone,
        merchantName: r.merchantName,
      );
}
