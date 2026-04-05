import 'package:dio/dio.dart';
import 'package:mood_playlist_app/core/security/auth_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final AuthSecureStorage storage;
  final Dio authDio;

  AuthInterceptor({required this.storage, required this.authDio});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && err.requestOptions.path != '/api/v1/auth/refresh') {
      final refresh = await storage.readRefreshToken();
      if (refresh != null && refresh.isNotEmpty) {
        try {
          final res = await authDio.post('/api/v1/auth/refresh', data: {'refreshToken': refresh});
          final accessToken = res.data['data']['accessToken'] as String;
          final refreshToken = res.data['data']['refreshToken'] as String;
          await storage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);

          final cloned = await authDio.fetch(err.requestOptions..headers['Authorization'] = 'Bearer $accessToken');
          return handler.resolve(cloned);
        } catch (_) {
          await storage.clear();
        }
      }
    }
    handler.next(err);
  }
}
