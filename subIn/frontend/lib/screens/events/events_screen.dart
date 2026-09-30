import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/models/event.dart';
import 'package:sub_in/providers/event_provider.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  Event? _createdEvent;

  @override
  Widget build(BuildContext context) {
    // ✅ Now using typed Event objects
    final eventsAsync = ref.watch(nearByEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Events & Games')),
      body: eventsAsync.when(
        data: (events) {
          final visibleEvents = [...events];
          if (_createdEvent != null &&
              !visibleEvents.any((event) => event.id == _createdEvent!.id)) {
            visibleEvents.insert(0, _createdEvent!);
          }
          if (visibleEvents.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: visibleEvents.length,
            itemBuilder: (context, index) {
              final event = visibleEvents[index];
              return _EventListCard(event: event);
            },
          );
        },
        loading: () => _createdEvent == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [_EventListCard(event: _createdEvent!)],
              ),
        error: (err, _) => _createdEvent == null
            ? Center(child: Text('Error: $err'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [_EventListCard(event: _createdEvent!)],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateEvent,
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
            onPressed: _openCreateEvent,
            child: const Text('Host a Game'),
          ),
        ],
      ),
    );
  }

  Future<void> _openCreateEvent() async {
    final event = await context.push<Event>('/create-event');
    if (!mounted || event == null) return;
    setState(() => _createdEvent = event);
    ref.invalidate(nearByEventsProvider);
  }
}

class _EventListCard extends StatelessWidget {
  final Event event; // ✅ Strongly typed

  const _EventListCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final sportColor =
        AppTheme.sportColors[event.sport] ?? AppTheme.primaryColor;
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
          Text(event.title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${event.currentPlayers}/${event.maxPlayers} players'),
          Text(event.customLocation ?? 'Location TBD'),
          // ... rest of your UI
        ],
      ),
    );
  }
}
