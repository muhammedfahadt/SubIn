import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_in/providers/auth_provider.dart'; // Adjust path if needed
import 'package:sub_in/providers/event_provider.dart';
import 'package:sub_in/screens/home/home_sport_filter_provider.dart';
import 'package:sub_in/screens/home/widgets/events_preview_section.dart';
import 'package:sub_in/screens/home/widgets/home_bottom_nav.dart';
import 'package:sub_in/screens/home/widgets/home_empty_state.dart';
import 'package:sub_in/screens/home/widgets/home_header.dart';
import 'package:sub_in/screens/home/widgets/home_stats_strip.dart';
import 'package:sub_in/screens/home/widgets/host_game_card.dart';
import 'package:sub_in/screens/home/widgets/sport_filter_chips.dart';
import 'package:sub_in/screens/home/widgets/venues_preview_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(nearByEventsProvider);
    final selectedSport = ref.watch(homeSelectedSportProvider);
    final showEmptyState = eventsAsync.maybeWhen(
      data: (events) => events
          .where((e) => homeSportMatchesEvent(e.sport, selectedSport))
          .isEmpty,
      orElse: () => false,
    );
    return Scaffold(
      appBar: AppBar(
        
        actions: [
          IconButton(
            tooltip: 'Logout',
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
            tooltip: 'Open venues',
            icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: () {
              context.go('/venues');
            },
          ),
          IconButton(
            tooltip: 'Create event',
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
            tooltip: 'Open event details',
            onPressed: () {
              context.push('/events/1');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeHeader(
              onNotificationTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications')),
                );
              },
              onLocationTap: () => context.go('/venues'),
              onProfileTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile is not available yet')),
                );
              },
            ),
            const SizedBox(height: 12),
            const SportFilterChips(),
            const SizedBox(height: 16),
            if (showEmptyState) ...[
              const HomeEmptyStateCard(),
              const SizedBox(height: 16),
            ],
            const EventsPreviewSection(),
            const SizedBox(height: 16),
            const VenuesPreviewSection(),
            const SizedBox(height: 16),
            const HostGameCard(),
            const SizedBox(height: 16),
            const HomeStatsStrip(),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }
}
