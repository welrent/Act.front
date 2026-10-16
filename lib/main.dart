import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/home.dart';
import 'screens/agreements.dart';
import 'screens/page_detail.dart';
import 'screens/contract_detail.dart';
import 'screens/profile.dart';
import 'screens/portal.dart';
import 'screens/secret_panel.dart';
import 'screens/settings.dart';
import 'screens/editor.dart';

void main() {
  runApp(const WelrentActApp());
}

class WelrentActApp extends StatelessWidget {
  const WelrentActApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp.router(
        title: 'Welrent | Smart Agreements',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}

/// Application routing — mirrors the original Next.js / PHP routes.
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/pages/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return PageDetailScreen(slug: slug);
      },
    ),
    GoRoute(
      path: '/agreements',
      builder: (context, state) => const AgreementsScreen(),
    ),
    GoRoute(
      path: '/contracts/:ref',
      builder: (context, state) {
        final ref = state.pathParameters['ref'] ?? '';
        return ContractDetailScreen(ref: ref);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/portal/:username',
      builder: (context, state) {
        final username = state.pathParameters['username'] ?? '';
        return PortalScreen(username: username);
      },
    ),
    GoRoute(
      path: '/secret-panel',
      builder: (context, state) => const SecretPanelScreen(),
    ),
    GoRoute(
      path: '/secret-panel/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/secret-panel/editor',
      builder: (context, state) => const EditorScreen(),
    ),
  ],
);
