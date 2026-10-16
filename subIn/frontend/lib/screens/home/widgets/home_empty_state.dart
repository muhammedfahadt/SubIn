import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/providers/location_provider.dart';
import 'package:sub_in/screens/home/home_search_radius_provider.dart';
import 'package:sub_in/screens/home/home_sport_filter_provider.dart';

class HomeEmptyStateCard extends ConsumerWidget {
  const HomeEmptyStateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSport = ref.watch(homeSelectedSportProvider);
    final radiusKm = ref.watch(homeSearchRadiusKmProvider);
    final locationAsync = ref.watch(locationProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.lowContainer, borderRadius: AppTheme.radiusBorder, border: Border.all(color: AppTheme.outline)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No games found nearby yet.', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('No $selectedSport matches within ${radiusKm.round()} km.'),
          TextButton(
            onPressed: () => ref.read(homeSelectedSportProvider.notifier).state = 'All Sports',
            child: const Text('Explore other sports'),
          ),
          TextButton(
            onPressed: () => ref.read(homeSearchRadiusKmProvider.notifier).state = homeExpandedSearchRadiusKm,
            child: const Text('or Expand search radius to 15 mi'),
          ),
          TextButton(
            onPressed: () => ref.read(locationProvider.notifier).refreshLocation(),
            child: Text(locationAsync.hasError ? 'Update Location Permissions' : 'Refresh location'),
          ),
          const SizedBox(height: 8),
          const Text('Be the first to start a game'),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => context.push('/create-event'),
            icon: const Icon(Icons.add),
            label: const Text('Host an Event'),
          ),
        ],
      ),
    );
  }
}