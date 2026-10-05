import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_in/providers/auth_provider.dart'; // Adjust path if needed

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // 1. Call the logout method
              await ref.read(authNotifierProvider.notifier).logout();
              // 2. Force router back to login
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
          IconButton(
          icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: () {
              // Navigate to the home screen
               
              context.go('/venues');
            },
          ),
          IconButton(
            icon: const Icon(Icons.event),
            onPressed: () async {
              final created = await context.push<bool>('/create-event');
              if (created == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event created successfully!')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.event_available),
            onPressed: () {
              // Navigate to the home screen
              context.go('/events/1'); // Replace '1' with the actual event ID you want to view
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text(
              'Login Successful!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('The token is safely stored in SharedPreferences.'),
          ],
        ),
      ),
    );
  }
}
