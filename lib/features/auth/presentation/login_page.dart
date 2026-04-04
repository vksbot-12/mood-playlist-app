import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Google로 시작')),
              ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Apple로 시작')),
              ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Kakao로 시작')),
            ],
          ),
        ),
      ),
    );
  }
}
