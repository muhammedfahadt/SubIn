import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/models/event.dart';
import 'package:sub_in/providers/event_provider.dart';
import 'package:sub_in/screens/home/home_sport_filter_provider.dart';

class EventsPreviewSection extends ConsumerWidget {
  const EventsPreviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(nearByEventsProvider);
    final selectedSport = ref.watch(homeSelectedSportProvider);
    return _PreviewSection(
      title: 'Events near you',
      onSeeAll: () => context.go('/events'),
      child: eventsAsync.when(
        data: (events) {
          final filtered = events.where((event) => homeSportMatchesEvent(event.sport, selectedSport)).take(3).toList();
          if (filtered.isEmpty) return const Text('Try another sport or expand your search radius.');
          return Column(
            children: [
              for (var index = 0; index < filtered.length; index++) ...[
                _EventRow(event: filtered[index]),
                if (index < filtered.length - 1) const Divider(height: 16),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Text('Could not load events.'),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final Event event;

  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/event-detail', extra: event.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.sports, color: AppTheme.lime),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(event.customLocation ?? 'Location TBD', maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${event.currentPlayers}/${event.maxPlayers} players'),
                ],
              ),
            ),
            Text(DateFormat('MMM d').format(event.startTime)),
          ],
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final Widget child;

  const _PreviewSection({required this.title, required this.onSeeAll, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
        child,
      ],
    );
  }
}