import '../entities/transaction.dart';

/// Abstract transaction repository. Concrete implementation lives in
/// `data/repositories/` and talks to Isar + the backend.
abstract class TransactionRepository {
  Future<List<Transaction>> getRecent({int limit = 20});

  Future<Transaction?> findById(String id);

  Future<Transaction?> findByProviderTxnId(String providerTxnId);

  Future<Transaction> save(Transaction transaction);

  Future<void> delete(String id);

  Stream<List<Transaction>> watchAll();
}
