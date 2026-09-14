import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_in/screens/auth/login_screen.dart';
import 'package:sub_in/providers/auth_provider.dart';

void main() {
  testWidgets('login button shows loading indicator on tap', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // AsyncNotifierProvider.overrideWith takes () => Notifier, no ref param
          authNotifierProvider.overrideWith(() => FakeAuthNotifier()),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
              GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('Home'))),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });
}

// Must EXTEND AuthNotifier, not AsyncNotifier<AuthState>
class FakeAuthNotifier extends AuthNotifier {
  @override
  Future<AuthState> build() async => const AuthState(isLoggedIn: false);

  @override
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    // Never complete — keeps loading visible for test
  }
}