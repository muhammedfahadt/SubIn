import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_in/providers/auth_provider.dart';
import 'package:sub_in/screens/auth/login_screen.dart';
import 'package:sub_in/screens/auth/registration_screen.dart';
import 'package:sub_in/screens/events/create_event_screen.dart';
import 'package:sub_in/screens/events/event_detail_screen.dart';
import 'package:sub_in/screens/events/events_screen.dart';
import 'package:sub_in/screens/home/home_screen.dart';
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
        path: '/register',
        builder: (context, state) =>  const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>  const HomeScreen(),
      ),
      GoRoute(
        path: '/venues',
        builder: (context, state) =>  const VenueMapScreen(),
      ),
      GoRoute(
        path: '/create-event',
        builder: (context, state) =>  const CreateEventScreen(),
    ),  
       GoRoute(
        path: '/events/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) return const EventsScreen();
          return EventDetailScreen(eventId: id);
        },
      ),
      GoRoute(
      path: '/event-detail',
      builder: (context, state) {
        final extra = state.extra;
        final eventId = extra is int ? extra : int.tryParse('$extra');
        if (eventId == null) return const EventsScreen();
    return EventDetailScreen(eventId: eventId);
  },
),
      

    ],
  );
}
);