import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/countries_screen.dart';
import '../screens/downloads_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/movies_screen.dart';
import '../screens/search_screen.dart';
import '../screens/series_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/app_shell.dart';

CustomTransitionPage<void> _buildPageWithTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.012, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/movies',
  routes: <RouteBase>[
    GoRoute(path: '/', redirect: (_, __) => '/movies'),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return AppShell(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/movies',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const MoviesScreen(),
          ),
        ),
        GoRoute(
          path: '/series',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const SeriesScreen(),
          ),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const SearchScreen(),
          ),
        ),
        GoRoute(
          path: '/favorites',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const FavoritesScreen(),
          ),
        ),
        GoRoute(
          path: '/downloads',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const DownloadsScreen(),
          ),
        ),
        GoRoute(
          path: '/countries',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const CountriesScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
