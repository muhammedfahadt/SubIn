import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/models/venue.dart';
import 'package:sub_in/providers/location_provider.dart';
import 'package:sub_in/screens/venues/create_venue_sheet.dart';
import 'package:sub_in/services/venue_service.dart';

class VenueMapScreen extends ConsumerStatefulWidget {
  const VenueMapScreen({super.key});

  @override
  ConsumerState<VenueMapScreen> createState() => _VenueMapScreenState();
}

class _VenueMapScreenState extends ConsumerState<VenueMapScreen> {
  final MapController _mapController = MapController();
  bool _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);
    final venuesAsync = ref.watch(nearbyVenuesProvider);
    final selectedSport = ref.watch(selectedSportProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_venue',
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _showCreateVenueSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          // Map — waits for BOTH location and venues
          locationAsync.when(
            data: (location) => venuesAsync.when(
              data: (venues) => _buildMap(location, venues),
              loading: () => _buildMap(location, const []),
              error: (err, _) => _buildVenuesError(err.toString()),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => _buildErrorState(err.toString()),
          ),

          // Search Bar Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),

          // Sport Filter Chips
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 0,
            right: 0,
            child: _buildSportFilter(selectedSport),
          ),

          // Bottom Sheet for Venue List
          if (_isMapReady)
            DraggableScrollableSheet(
              initialChildSize: 0.15,
              minChildSize: 0.15,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return _buildVenueList(scrollController);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVenuesError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text('Could not load venues', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            const Text(
              'Is the backend running? (http://localhost:8000/docs → GET /venues/nearby)',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.invalidate(venueRefreshProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateVenueSheet(BuildContext context) {
    final location = ref.read(locationProvider).value;
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for location... try again in a second')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateVenueSheet(initialLocation: location),
    );
  }

  Widget _buildMap(LatLng location, List<Venue> venues) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: location,
        initialZoom: 14,
        onMapReady: () {
          if (!_isMapReady) setState(() => _isMapReady = true);
        },
      ),
      children: [
        // 100% free tiles, no API key. Dark tiles to match your theme.
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.subin.app',
        ),
        MarkerLayer(
          markers: [
            // "My location" dot
            Marker(
              point: location,
              width: 24,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
            for (final venue in venues)
              Marker(
                point: LatLng(venue.latitude, venue.longitude),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => _showVenueSnack(venue),
                  child: Icon(
                    Icons.location_pin,
                    size: 40,
                    color: _sportColor(venue.sports.isNotEmpty ? venue.sports.first : ''),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showVenueSnack(Venue venue) {
    final sport = venue.sports.isNotEmpty ? venue.sports.first : 'Venue';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${venue.name} • $sport • ⭐ ${venue.rating}')),
    );
  }

  String _displaySport(Venue venue) {
    if (venue.sports.isEmpty) return 'Other';
    final raw = venue.sports.first;
    if (raw.isEmpty) return 'Other';
    return raw[0].toUpperCase() + raw.substring(1);
  }

  Color _sportColor(String sport) {
    // Backend stores lowercase (football); theme map uses Capitalized (Football)
    final normalized = sport.isEmpty ? sport : sport[0].toUpperCase() + sport.substring(1).toLowerCase();
    return AppTheme.sportColors[normalized] ??
        AppTheme.sportColors[sport] ??
        AppTheme.primaryColor;
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search venues, sports...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSportFilter(String selectedSport) {
    final sports = ['All', 'Football', 'Cricket', 'Basketball', 'Tennis', 'Badminton'];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sports.length,
        itemBuilder: (context, index) {
          final sport = sports[index];
          final isSelected = sport == selectedSport;
          final color = AppTheme.sportColors[sport] ?? AppTheme.primaryColor;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) {
                ref.read(selectedSportProvider.notifier).state = sport;
              },
              label: Text(sport),
              selectedColor: color.withValues(alpha: 0.2),
              checkmarkColor: color,
              labelStyle: TextStyle(
                color: isSelected ? color : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: AppTheme.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? color : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenueList(ScrollController scrollController) {
    final venuesAsync = ref.watch(nearbyVenuesProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Venues',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                venuesAsync.when(
                  data: (v) => Text('${v.length} found', style: const TextStyle(color: AppTheme.textMuted)),
                  loading: () => const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Text('error', style: TextStyle(color: AppTheme.textMuted)),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: venuesAsync.when(
              data: (venues) {
                if (venues.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No venues found nearby.\nTap + to add the first one!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: venues.length,
                  itemBuilder: (context, index) {
                    final venue = venues[index];
                    final dist = venue.distanceKm != null
                        ? '${venue.distanceKm!.toStringAsFixed(1)} km'
                        : '—';
                    return _VenueListItem(
                      name: venue.name,
                      sport: _displaySport(venue),
                      distance: dist,
                      rating: venue.rating,
                      onTap: () {
                        _mapController.move(
                          LatLng(venue.latitude, venue.longitude), 15);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(err.toString(), textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textMuted)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(venueRefreshProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            'Location Required',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(locationProvider.notifier).refreshLocation(),
            child: const Text('Enable Location'),
          ),
        ],
      ),
    );
  }
}

// ── Create venue bottom sheet (POST /venues/) ──
// Full implementation lives in create_venue_sheet.dart to keep this file small.

class _VenueListItem extends StatelessWidget {
  final String name;
  final String sport;
  final String distance;
  final double rating;
  final VoidCallback onTap;

  const _VenueListItem({
    required this.name,
    required this.sport,
    required this.distance,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.sportColors[sport] ?? AppTheme.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.sports, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber[400]),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        distance,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sport,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}