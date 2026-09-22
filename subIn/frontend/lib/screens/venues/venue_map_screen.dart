import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/providers/location_provider.dart';

class VenueMapScreen extends ConsumerStatefulWidget {
  const VenueMapScreen({super.key});

  @override
  ConsumerState<VenueMapScreen> createState() => _VenueMapScreenState();
}

class _VenueMapScreenState extends ConsumerState<VenueMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          locationAsync.when(
            data: (location) => _buildMap(location),
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
            child: _buildSportFilter(),
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

  Widget _buildMap(LatLng location) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: location,
        zoom: 14,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      markers: _markers,
      onMapCreated: (controller) {
        _mapController = controller;
        _mapController?.setMapStyle(_darkMapStyle);
        setState(() {
          _isMapReady = true;
        });
        _loadVenues(location);
      },
    );
  }

  void _loadVenues(LatLng location) {
    // Simulate loading venues - in production, call API
    final venues = [
      _VenueMarker(
        id: '1',
        name: 'City Sports Complex',
        position: LatLng(location.latitude + 0.002, location.longitude + 0.001),
        sport: 'Football',
        rating: 4.5,
      ),
      _VenueMarker(
        id: '2',
        name: 'Green Valley Cricket Ground',
        position: LatLng(location.latitude - 0.001, location.longitude - 0.002),
        sport: 'Cricket',
        rating: 4.2,
      ),
      _VenueMarker(
        id: '3',
        name: 'Downtown Basketball Court',
        position: LatLng(location.latitude + 0.003, location.longitude - 0.001),
        sport: 'Basketball',
        rating: 4.0,
      ),
    ];

    setState(() {
      _markers.clear();
      for (final venue in venues) {
        _markers.add(
          Marker(
            markerId: MarkerId(venue.id),
            position: venue.position,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getSportHue(venue.sport),
            ),
            infoWindow: InfoWindow(
              title: venue.name,
              snippet: '${venue.sport} • ⭐ ${venue.rating}',
            ),
          ),
        );
      }
    });
  }

  double _getSportHue(String sport) {
    return switch (sport) {
      'Football' => BitmapDescriptor.hueGreen,
      'Cricket' => BitmapDescriptor.hueBlue,
      'Basketball' => BitmapDescriptor.hueOrange,
      'Tennis' => BitmapDescriptor.hueRose,
      _ => BitmapDescriptor.hueRed,
    };
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

  Widget _buildSportFilter() {
    final sports = ['All', 'Football', 'Cricket', 'Basketball', 'Tennis', 'Badminton'];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sports.length,
        itemBuilder: (context, index) {
          final sport = sports[index];
          final isSelected = index == 0; // Simplified
          final color = AppTheme.sportColors[sport] ?? AppTheme.primaryColor;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) {},
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
                Text(
                  '${_markers.length} found',
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _markers.length,
              itemBuilder: (context, index) {
                final marker = _markers.elementAt(index);
                return _VenueListItem(
                  name: marker.infoWindow.title ?? 'Unknown',
                  sport: 'Football', // Would come from API
                  distance: '${(index + 1) * 0.5} km',
                  rating: 4.5,
                  onTap: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLng(marker.position),
                    );
                  },
                );
              },
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

  static const String _darkMapStyle = '''
    [
      {"elementType": "geometry", "stylers": [{"color": "#1a1a2e"}]},
      {"elementType": "labels.text.fill", "stylers": [{"color": "#8ec3b9"}]},
      {"elementType": "labels.text.stroke", "stylers": [{"color": "#1a3646"}]},
      {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#0f172a"}]},
      {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#2d3748"}]}
    ]
  ''';
}

class _VenueMarker {
  final String id;
  final String name;
  final LatLng position;
  final String sport;
  final double rating;

  _VenueMarker({
    required this.id,
    required this.name,
    required this.position,
    required this.sport,
    required this.rating,
  });
}

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