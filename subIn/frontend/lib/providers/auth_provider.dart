import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/auth_services.dart'; 


// 1. Define the state (Keep it simple)
class AuthState {
  final bool isLoggedIn;
  const AuthState({required this.isLoggedIn});
}

// 2. The AsyncNotifier
class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // Runs ONCE when the app starts. Perfect for checking existing tokens.
    final storage = ref.read(storageServiceProvider);
    final token = await storage.getToken();
    return AuthState(isLoggedIn: token != null && token.isNotEmpty);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    // AsyncValue.guard automatically catches errors and puts them in state.error
    state = await AsyncValue.guard(() async {
     final authService = ref.read(authServiceProvider);
          await authService.login(email, password);


      return const AuthState(isLoggedIn: true);
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final storage = ref.read(storageServiceProvider);
      await storage.clearToken();
      return const AuthState(isLoggedIn: false);
    });
  }
}

// 3. The Provider
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// 4. The Router Helper (Synchronous, prevents unnecessary router rebuilds)
final authIsLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).value?.isLoggedIn ?? false;
});
