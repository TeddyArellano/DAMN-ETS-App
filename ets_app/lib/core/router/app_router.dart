import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/ets/presentation/ets_home_screen.dart';
import '../../features/ets/presentation/favorite_ets_screen.dart';

import '../../features/location/presentation/screens/salon_map_screen.dart';
import '../../features/location/presentation/screens/escom_location_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/loading',
    redirect: (context, state) {
      final path = state.uri.path;

      if (authState.isLoading) {
        return path == '/loading' ? null : '/loading';
      }

      final user = authState.asData?.value;
      final isAuthPath = path == '/login' || path == '/register';

      if (user == null) {
        return isAuthPath ? null : '/login';
      }

      if (path == '/loading' || isAuthPath) {
        return user.isAdmin ? '/admin' : '/ets';
      }

      if (path.startsWith('/admin') && !user.isAdmin) {
        return '/ets';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const _LoadingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];

          return LoginScreen(
            initialEmail: email,
          );
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/ets',
        builder: (context, state) => const EtsHomeScreen(),
      ),
      GoRoute(
        path: '/ets/favorites',
        builder: (context, state) => const FavoriteEtsScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // Mapa interno del salón
      GoRoute(
        path: '/mapa-salon',
        builder: (context, state) {
          final salon = state.extra as String?;

          return SalonMapScreen(
            salon: salon ?? '',
          );
        },
      ),

      // Geolocalización hacia ESCOM
      GoRoute(
        path: '/ubicacion-escom',
        builder: (context, state) {
          return const EscomLocationScreen();
        },
      ),
    ],
  );
});

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}