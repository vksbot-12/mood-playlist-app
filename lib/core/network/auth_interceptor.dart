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
}
