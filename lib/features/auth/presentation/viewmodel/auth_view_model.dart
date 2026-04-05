import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mood_playlist_app/core/security/auth_secure_storage.dart';
import 'package:mood_playlist_app/features/auth/data/auth_repository.dart';
import 'package:mood_playlist_app/features/home/presentation/viewmodel/home_view_model.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(ref.watch(apiClientProvider).dio));
final authSecureStorageProvider = Provider((_) => AuthSecureStorage(const FlutterSecureStorage()));

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AsyncValue<void>>(
  (ref) => AuthViewModel(ref.watch(authRepositoryProvider), ref.watch(authSecureStorageProvider)),
);

class AuthViewModel extends StateNotifier<AsyncValue<void>> {
  AuthViewModel(this._authRepository, this._storage) : super(const AsyncValue.data(null));

  final AuthRepository _authRepository;
  final AuthSecureStorage _storage;

  Future<void> socialLogin(String provider) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _authRepository.socialLogin(provider: provider, idToken: 'mock-$provider-token');
      final data = result['data'] as Map<String, dynamic>;
      await _storage.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
    });
  }
}
