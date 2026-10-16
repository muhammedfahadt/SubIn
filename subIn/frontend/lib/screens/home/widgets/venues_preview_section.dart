import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/providers/venue_provider.dart';
import 'package:sub_in/screens/home/home_sport_filter_provider.dart';

class VenuesPreviewSection extends ConsumerWidget {
  const VenuesPreviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(nearbyVenuesProvider);
    final selectedSport = ref.watch(homeSelectedSportProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Venues near you', style: Theme.of(context).textTheme.titleMedium)),
            TextButton(onPressed: () => context.go('/venues'), child: const Text('See all')),
          ],
        ),
        venuesAsync.when(
          data: (venues) {
            final filtered = venues.where((venue) => homeSportMatchesVenue(venue.sports, selectedSport)).take(3).toList();
            if (filtered.isEmpty) return const Text('No nearby venues found.');
            return Column(
              children: [
                for (final venue in filtered)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined, color: AppTheme.lime),
                    title: Text(venue.name),
                    subtitle: Text('${venue.city} · ${venue.sports.join(', ')}'),
                    onTap: () => context.go('/venues'),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => const Text('Could not load venues.'),
        ),
      ],
    );
  }
}