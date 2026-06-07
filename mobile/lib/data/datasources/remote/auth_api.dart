import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  @POST('/auth/register')
  Future<RegisterResponse> register(@Body() Map<String, dynamic> body);

  @POST('/auth/verify-otp')
  Future<VerifyOtpResponse> verifyOtp(@Body() Map<String, dynamic> body);

  @POST('/auth/set-pin')
  Future<SetPinResponse> setPin(@Body() Map<String, dynamic> body);

  @POST('/auth/login')
  Future<LoginResponse> login(@Body() Map<String, dynamic> body);

  @POST('/auth/refresh')
  Future<RefreshResponse> refresh(@Body() Map<String, dynamic> body);
}

class RegisterResponse {
  RegisterResponse({required this.sessionId, required this.expiresIn, this.devOtp});
  final String sessionId;
  final int expiresIn;
  final String? devOtp;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        sessionId: json['sessionId'] as String,
        expiresIn: json['expiresIn'] as int,
        devOtp: json['__devOtp'] as String?,
      );
}

class VerifyOtpResponse {
  VerifyOtpResponse({required this.sessionId, required this.verified, this.phone});
  final String sessionId;
  final bool verified;
  final String? phone;

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) => VerifyOtpResponse(
        sessionId: json['sessionId'] as String,
        verified: json['verified'] as bool,
        phone: json['phone'] as String?,
      );
}

class SetPinResponse {
  SetPinResponse({required this.pinSet});
  final bool pinSet;
  factory SetPinResponse.fromJson(Map<String, dynamic> json) =>
      SetPinResponse(pinSet: json['pinSet'] as bool);
}

class LoginResponse {
  LoginResponse({required this.sessionId, required this.expiresIn, this.devOtp, this.requiresPin});
  final String sessionId;
  final int expiresIn;
  final String? devOtp;
  final bool? requiresPin;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        sessionId: json['sessionId'] as String,
        expiresIn: json['expiresIn'] as int,
        devOtp: json['__devOtp'] as String?,
        requiresPin: json['requiresPin'] as bool?,
      );
}

class RefreshResponse {
  RefreshResponse({required this.accessToken, required this.expiresIn});
  final String accessToken;
  final int expiresIn;

  factory RefreshResponse.fromJson(Map<String, dynamic> json) => RefreshResponse(
        accessToken: json['accessToken'] as String,
        expiresIn: json['expiresIn'] as int,
      );
}
