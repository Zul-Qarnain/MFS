import 'package:dio/dio.dart';

class PaymentsApi {
  PaymentsApi(this._dio);
  final Dio _dio;

  Future<ProvidersResponse> listProviders() async {
    final response = await _dio.get('/payments/providers');
    return ProvidersResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<InitiateResponse> initiate(Map<String, dynamic> body) async {
    final response = await _dio.post('/payments/initiate', data: body);
    return InitiateResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<StatusResponse> status(String providerTxnId) async {
    final response = await _dio.get(
      '/payments/status',
      queryParameters: {'providerTxnId': providerTxnId},
    );
    return StatusResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ReceiptResponse> receipt(String providerTxnId) async {
    final response = await _dio.get(
      '/payments/receipt',
      queryParameters: {'providerTxnId': providerTxnId},
    );
    return ReceiptResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

class ProvidersResponse {
  ProvidersResponse({required this.providers});

  factory ProvidersResponse.fromJson(Map<String, dynamic> json) =>
      ProvidersResponse(providers: List<String>.from(json['providers'] as List));

  final List<String> providers;
}

class InitiateResponse {
  InitiateResponse({
    required this.transactionId,
    this.providerTxnId,
    required this.status,
    this.redirectUrl,
    this.expiresAt,
  });

  factory InitiateResponse.fromJson(Map<String, dynamic> json) => InitiateResponse(
        transactionId: json['transactionId'] as String,
        providerTxnId: json['providerTxnId'] as String?,
        status: json['status'] as String,
        redirectUrl: json['redirectUrl'] as String?,
        expiresAt: json['expiresAt'] as String?,
      );

  final String transactionId;
  final String? providerTxnId;
  final String status;
  final String? redirectUrl;
  final String? expiresAt;
}

class StatusResponse {
  StatusResponse({
    required this.transactionId,
    required this.providerTxnId,
    required this.status,
    required this.updatedAt,
  });

  factory StatusResponse.fromJson(Map<String, dynamic> json) => StatusResponse(
        transactionId: json['transactionId'] as String,
        providerTxnId: json['providerTxnId'] as String,
        status: json['status'] as String,
        updatedAt: json['updatedAt'] as String,
      );

  final String transactionId;
  final String providerTxnId;
  final String status;
  final String updatedAt;
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

  factory ReceiptResponse.fromJson(Map<String, dynamic> json) => ReceiptResponse(
        providerTxnId: json['providerTxnId'] as String,
        providerId: json['providerId'] as String,
        type: json['type'] as String,
        status: json['status'] as String,
        amountMinorUnits: json['amountMinorUnits'] as int,
        currency: json['currency'] as String,
      );

  final String providerTxnId;
  final String providerId;
  final String type;
  final String status;
  final int amountMinorUnits;
  final String currency;
}
