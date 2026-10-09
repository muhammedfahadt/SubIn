import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/models/event.dart';
import 'package:sub_in/providers/event_provider.dart';
import 'package:sub_in/services/event_service.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  Event? _createdEvent;

  @override
  Widget build(BuildContext context) {
    // ✅ Watch the typed Event objects from Riverpod
    final eventsAsync = ref.watch(nearByEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events & Games'),
        backgroundColor: AppTheme.surface,
      ),
      body: eventsAsync.when(
        data: (events) {
          final visibleEvents = [...events];
          
          // Temporarily show the newly created event at the top while the list refreshes
          if (_createdEvent != null && !visibleEvents.any((event) => event.id == _createdEvent!.id)) {
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
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Host Game', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_handball, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          const Text(
            'No events found nearby.',
            style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _openCreateEvent,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
            child: const Text('Host a Game', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _openCreateEvent() async {
    // Using go_router's context.push
    final event = await context.push<Event>('/create-event');
    if (!mounted || event == null) return;
    
    setState(() => _createdEvent = event);
    // Invalidate to fetch fresh data from backend in the background
    ref.invalidate(nearByEventsProvider);
  }
}

// ✅ Changed to ConsumerWidget to access 'ref' for joining events
class _EventListCard extends ConsumerWidget {
  final Event event;

  const _EventListCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sportColor = AppTheme.sportColors[event.sport] ?? AppTheme.primaryColor;
    final spotsLeft = event.spotsRemaining ?? 0;
    final isUrgent = spotsLeft <= 2 && spotsLeft > 0;

    return InkWell(
      onTap: () {
        // ✅ Using go_router navigation with 'extra' parameter
        context.push('/event-detail', extra: event.id);
         print('🎯 Navigating to Event ID: ${event.id}'); 
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUrgent ? AppTheme.accentColor.withOpacity(0.3) : Colors.transparent,
            width: isUrgent ? 1.5 : 0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sportColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(_getSportIcon(event.sport), color: sportColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.customLocation ?? 'Location TBD',
                          style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Filling Fast!',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.calendar_today, _formatDate(event.startTime)),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.access_time, _formatTime(event.startTime, event.endTime)),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.people, '${event.currentPlayers}/${event.maxPlayers} players'),
                  if (!event.isFree && event.costPerPlayer != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.attach_money, '\$${event.costPerPlayer!.toStringAsFixed(2)} per player'),
                  ],
                ],
              ),
            ),
            
            // Action Bar (Join Button)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: spotsLeft > 0 ? () => _joinEvent(context, ref) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: spotsLeft > 0 ? AppTheme.primaryColor : AppTheme.textMuted,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        spotsLeft > 0 ? 'Join • $spotsLeft left' : 'Full',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
      ],
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'football': return Icons.sports_soccer;
      case 'basketball': return Icons.sports_basketball;
      case 'tennis': return Icons.sports_tennis;
      case 'cricket': return Icons.sports_cricket;
      case 'volleyball': return Icons.sports_volleyball;
      case 'badminton': return Icons.sports_tennis_outlined;
      default: return Icons.sports;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  String _formatTime(DateTime start, DateTime end) {
    final startStr = DateFormat('h:mm a').format(start);
    final endStr = DateFormat('h:mm a').format(end);
    return '$startStr - $endStr';
  }

  Future<void> _joinEvent(BuildContext context, WidgetRef ref) async {
    try {
      final eventService = ref.read(eventServiceProvider);
      await eventService.joinEvent(event.id);
      
      // Refresh the nearby events list to update player counts
      ref.invalidate(nearByEventsProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the event!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining event: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}