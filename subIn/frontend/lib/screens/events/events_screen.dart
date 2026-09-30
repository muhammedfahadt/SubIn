import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/models/event.dart';
import 'package:sub_in/providers/event_provider.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Now using typed Event objects
    final eventsAsync = ref.watch(nearByEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Events & Games')),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index]; // ✅ Typed as Event, not dynamic
              return _EventListCard(event: event);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-event'),
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.add),
        label: const Text('Host Game'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'No events found nearby.',
            style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/create-event'),
            child: const Text('Host a Game'),
          ),
        ],
      ),
    );
  }
}

class _EventListCard extends StatelessWidget {
  final Event event; // ✅ Strongly typed

  const _EventListCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final sportColor = AppTheme.sportColors[event.sport] ?? AppTheme.primaryColor;
    final spotsLeft = event.spotsRemaining ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Now you have full type safety
          Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${event.currentPlayers}/${event.maxPlayers} players'),
          Text(event.customLocation ?? 'Location TBD'),
          // ... rest of your UI
        ],
      ),
    );
  }
}