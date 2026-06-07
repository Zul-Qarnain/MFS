import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String providerId,
    required String type,
    required String status,
    required int amountMinorUnits,
    required String currency,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? providerTxnId,
    String? recipientPhone,
    String? merchantName,
    int? feeMinorUnits,
  }) = _Transaction;
}
