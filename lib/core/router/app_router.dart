import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/counter/presentation/screens/counter_screen.dart';
import '../../features/home/presentation/screens/main_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

class AppRouter {
  static const String main = '/';
  static const String counter = '/counter';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: main,
    routes: [
      GoRoute(
        path: main,
        name: 'main',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: counter,
        name: 'counter',
        builder: (context, state) => const CounterScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '페이지를 찾을 수 없습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${state.error}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(main),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
}
