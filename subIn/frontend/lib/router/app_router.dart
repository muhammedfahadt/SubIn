import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import 'package:subIn/screens/splash_screen.dart';

// import your screens here

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
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        // Add nested routes here easily:
        // routes: [ GoRoute(path: 'settings', builder: ...) ]
      ),
    ],
  );
});
