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

    // ⬇️ CRITICAL: Wait for AsyncNotifier.build() to complete
    // Otherwise authState.isLoading is true and button is hidden
    await tester.pumpAndSettle();

    // Now the button should be visible
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Tap login
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Trigger loading state

    // Button gone, loading shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });
}

class FakeAuthNotifier extends AuthNotifier {
  @override
  Future<AuthState> build() async => const AuthState(isLoggedIn: false);

  @override
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    // Intentionally hang to keep loading visible
  }
}