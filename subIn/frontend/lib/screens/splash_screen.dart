import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_in/providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider. The build() method already ran and checked storage.
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (state) {
        // State is loaded. Route immediately based on the result.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.isLoggedIn) {
            context.go('/home');
          } else {
            context.go('/login');
          }
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to initialize app'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => ref.invalidate(authNotifierProvider), // Retry
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
