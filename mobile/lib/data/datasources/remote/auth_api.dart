import 'package:dio/dio.dart';

class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;

  Future<RegisterResponse> register(Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/register', data: body);
    return RegisterResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<VerifyOtpResponse> verifyOtp(Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/verify-otp', data: body);
    return VerifyOtpResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SetPinResponse> setPin(Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/set-pin', data: body);
    return SetPinResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LoginResponse> login(Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/login', data: body);
    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RefreshResponse> refresh(Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/refresh', data: body);
    return RefreshResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

class RegisterResponse {
  RegisterResponse({required this.sessionId, required this.expiresIn, this.devOtp});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        sessionId: json['sessionId'] as String,
        expiresIn: json['expiresIn'] as int,
        devOtp: json['__devOtp'] as String?,
      );

  final String sessionId;
  final int expiresIn;
  final String? devOtp;
}

class VerifyOtpResponse {
  VerifyOtpResponse({required this.sessionId, required this.verified, this.phone});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) => VerifyOtpResponse(
        sessionId: json['sessionId'] as String,
        verified: json['verified'] as bool,
        phone: json['phone'] as String?,
      );

  final String sessionId;
  final bool verified;
  final String? phone;
}

class SetPinResponse {
  SetPinResponse({required this.pinSet});

  factory SetPinResponse.fromJson(Map<String, dynamic> json) =>
      SetPinResponse(pinSet: json['pinSet'] as bool);

  final bool pinSet;
}

class LoginResponse {
  LoginResponse({required this.sessionId, required this.expiresIn, this.devOtp, this.requiresPin});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        sessionId: json['sessionId'] as String,
        expiresIn: json['expiresIn'] as int,
        devOtp: json['__devOtp'] as String?,
        requiresPin: json['requiresPin'] as bool?,
      );

  final String sessionId;
  final int expiresIn;
  final String? devOtp;
  final bool? requiresPin;
}

class RefreshResponse {
  RefreshResponse({required this.accessToken, required this.expiresIn});

  factory RefreshResponse.fromJson(Map<String, dynamic> json) => RefreshResponse(
        accessToken: json['accessToken'] as String,
        expiresIn: json['expiresIn'] as int,
      );

  final String accessToken;
  final int expiresIn;
}
