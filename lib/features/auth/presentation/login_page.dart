import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_playlist_app/features/auth/presentation/viewmodel/auth_view_model.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authViewModelProvider);

    Future<void> login(String provider) async {
      await ref.read(authViewModelProvider.notifier).socialLogin(provider);
      if (context.mounted && !state.hasError) {
        context.go('/home');
      }
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Mood Playlist', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('감정으로 음악을 찾는 가장 빠른 방법'),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => login('google'), child: const Text('Google로 시작')),
              ElevatedButton(onPressed: () => login('apple'), child: const Text('Apple로 시작')),
              ElevatedButton(onPressed: () => login('kakao'), child: const Text('Kakao로 시작')),
              if (state.isLoading) const Padding(padding: EdgeInsets.only(top: 16), child: CircularProgressIndicator()),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('로그인 실패: ${state.error}', style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
