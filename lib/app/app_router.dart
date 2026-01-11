import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/pages/home_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'settings',
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) {
        return Scaffold(
          body: Center(
            child: Text(state.error?.toString() ?? 'Unknown routing error'),
          ),
        );
      },
    );
  }
}
