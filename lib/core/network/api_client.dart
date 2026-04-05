import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mood_playlist_app/core/network/auth_interceptor.dart';
import 'package:mood_playlist_app/core/security/auth_secure_storage.dart';

class ApiClient {
  final Dio dio;

  ApiClient(String baseUrl)
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
        )) {
    final storage = AuthSecureStorage(const FlutterSecureStorage());
    final authDio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.interceptors.add(AuthInterceptor(storage: storage, authDio: authDio));
  }
}
