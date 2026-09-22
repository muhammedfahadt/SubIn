import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_in/providers/auth_provider.dart';
import 'package:sub_in/screens/auth/login_screen.dart';
import 'package:sub_in/screens/splash_screen.dart';
import 'package:sub_in/screens/venues/venue_map_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authIsLoggedInProvider);

  return GoRouter(
    initialLocation: '/', // Default starting point
    redirect: (context, state) {
      final isAuthenticated = isLoggedIn;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/';

   // Prevent authenticated users from seeing splash or login
      if (isAuthenticated && (isSplash || isLoggingIn)) {
        return '/home';
      }

      // Prevent unauthenticated users from seeing home
      if (!isAuthenticated && state.matchedLocation == '/home') {
        return '/login';
      }

      // No redirect needed
      return null;
    },
    routes: [
       GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>  const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>  const VenueMapScreen(),
        // Add nested routes here easily:
        // routes: [ GoRoute(path: 'settings', builder: ...) ]
      ),
    ],
  );
}
);