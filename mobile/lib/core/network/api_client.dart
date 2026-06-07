import 'package:dio/dio.dart';

/// Shared Dio HTTP client for the Flutter ↔ backend channel.
///
/// Base URL is read from the `API_BASE_URL` environment variable at
/// runtime (see [AppConfig]). Interceptors add the auth token and
/// correlation ID headers.
class ApiClient {
  ApiClient({required String baseUrl, this.accessTokenProvider})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),) {
    _dio.interceptors.add(_correlationIdInterceptor);
    _dio.interceptors.add(_authInterceptor);
    if (kDebugLog) _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  final Dio _dio;
  final String? Function()? accessTokenProvider;

  Dio get dio => _dio;

  Interceptor get _correlationIdInterceptor => InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-Correlation-Id'] = _uuid();
          handler.next(options);
        },
      );

  Interceptor get _authInterceptor => InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = accessTokenProvider?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      );

  static String _uuid() {
    final now = DateTime.now().microsecondsSinceEpoch.toRadixString(16).padLeft(12, '0');
    final rand = (DateTime.now().millisecondsSinceEpoch ^ 0xABCDEF).toRadixString(16);
    return '$now-$rand';
  }

  static const bool kDebugLog = bool.fromEnvironment('MFS_DEBUG_HTTP', defaultValue: false);
}
