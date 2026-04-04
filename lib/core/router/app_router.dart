import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_playlist_app/features/auth/presentation/login_page.dart';
import 'package:mood_playlist_app/features/calendar/presentation/calendar_page.dart';
import 'package:mood_playlist_app/features/home/presentation/home_page.dart';
import 'package:mood_playlist_app/features/subscription/presentation/subscription_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
      GoRoute(path: '/calendar', builder: (_, __) => const CalendarPage()),
      GoRoute(path: '/subscription', builder: (_, __) => const SubscriptionPage()),
    ],
  );
});
