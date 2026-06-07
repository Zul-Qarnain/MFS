import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'payments_api.g.dart';

@RestApi()
abstract class PaymentsApi {
  factory PaymentsApi(Dio dio, {String baseUrl}) = _PaymentsApi;

  @GET('/payments/providers')
  Future<ProvidersResponse> listProviders();

  @POST('/payments/initiate')
  Future<InitiateResponse> initiate(@Body() Map<String, dynamic> body);

  @GET('/payments/status')
  Future<StatusResponse> status(@Query('providerTxnId') String providerTxnId);

  @GET('/payments/receipt')
  Future<ReceiptResponse> receipt(@Query('providerTxnId') String providerTxnId);
}

class ProvidersResponse {
  ProvidersResponse({required this.providers});
  final List<String> providers;
  factory ProvidersResponse.fromJson(Map<String, dynamic> json) =>
      ProvidersResponse(providers: List<String>.from(json['providers'] as List));
}

class InitiateResponse {
  InitiateResponse({
    required this.transactionId,
    this.providerTxnId,
    required this.status,
    this.redirectUrl,
    this.expiresAt,
  });
  final String transactionId;
  final String? providerTxnId;
  final String status;
  final String? redirectUrl;
  final String? expiresAt;

  factory InitiateResponse.fromJson(Map<String, dynamic> json) => InitiateResponse(
        transactionId: json['transactionId'] as String,
        providerTxnId: json['providerTxnId'] as String?,
        status: json['status'] as String,
        redirectUrl: json['redirectUrl'] as String?,
        expiresAt: json['expiresAt'] as String?,
      );
}

class StatusResponse {
  StatusResponse({
    required this.transactionId,
    required this.providerTxnId,
    required this.status,
    required this.updatedAt,
  });
  final String transactionId;
  final String providerTxnId;
  final String status;
  final String updatedAt;

  factory StatusResponse.fromJson(Map<String, dynamic> json) => StatusResponse(
        transactionId: json['transactionId'] as String,
        providerTxnId: json['providerTxnId'] as String,
        status: json['status'] as String,
        updatedAt: json['updatedAt'] as String,
      );
}

class ReceiptResponse {
  ReceiptResponse({
    required this.providerTxnId,
    required this.providerId,
    required this.type,
    required this.status,
    required this.amountMinorUnits,
    required this.currency,
  });
  final String providerTxnId;
  final String providerId;
  final String type;
  final String status;
  final int amountMinorUnits;
  final String currency;

  factory ReceiptResponse.fromJson(Map<String, dynamic> json) => ReceiptResponse(
        providerTxnId: json['providerTxnId'] as String,
        providerId: json['providerId'] as String,
        type: json['type'] as String,
        status: json['status'] as String,
        amountMinorUnits: json['amountMinorUnits'] as int,
        currency: json['currency'] as String,
      );
}
