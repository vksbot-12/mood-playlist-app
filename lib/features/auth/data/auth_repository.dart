import 'package:dio/dio.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository(this.dio);

  Future<Map<String, dynamic>> socialLogin({required String provider, required String idToken, String? accessToken}) async {
    final res = await dio.post('/api/v1/auth/social/$provider', data: {
      'idToken': idToken,
      'accessToken': accessToken,
    });
    return res.data as Map<String, dynamic>;
  }
}
