import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_in/services/storage_service.dart';
import 'package:sub_in/services/auth_services.dart'; 


// 1. Define the state (Keep it simple)
class AuthState {
  final bool isLoggedIn;
  final String? userName;
  final int? userId;
  const AuthState({required this.isLoggedIn, this.userName, this.userId});
}

// 2. The AsyncNotifier
class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // Runs ONCE when the app starts. Perfect for checking existing tokens.
    final storage = ref.read(storageServiceProvider);
    final token = await storage.getToken();
    final userName = await storage.getUserName();
    final userId = await storage.getUserId();
    return AuthState(
      isLoggedIn: token != null && token.isNotEmpty,
      userName: userName,
      userId: userId,
    );
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    // AsyncValue.guard automatically catches errors and puts them in state.error
    state = await AsyncValue.guard(() async {
     final authService = ref.read(authServiceProvider);
          await authService.login(email, password);
      final storage = ref.read(storageServiceProvider);
      final userName = await storage.getUserName();
      final userId = await storage.getUserId();


      return AuthState(isLoggedIn: true, userName: userName, userId: userId);
    });
  }
  Future<void> register(String email, String password, String name, {String? phone}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.register(email, password, name, phone: phone);
      final storage = ref.read(storageServiceProvider);
      final userName = await storage.getUserName();
      final userId = await storage.getUserId();

      return AuthState(isLoggedIn: true, userName: userName, userId: userId);
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
