import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'cached_contact.dart';
import 'cached_transaction.dart';

/// Opens (or reuses) the single Isar instance for the app.
///
/// Schema migrations are handled via [Isar.open]'s built-in diffing;
/// explicit `schemaVersion` and migration tasks can be added later if
/// a breaking change occurs. See SYSTEM_ARCHITECTURE.md §4.
Future<Isar> openIsar() async {
  if (Isar.instanceNames.isNotEmpty) {
    return Isar.getInstance()!;
  }

  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [CachedTransactionSchema, CachedContactSchema],
    directory: dir.path,
    name: 'mfs_unified',
    inspector: false,
  );
}
