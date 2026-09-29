import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/models/venue.dart';
import 'package:sub_in/screens/events/map_location_picker.dart';
import 'package:sub_in/services/venue_service.dart';
import 'package:sub_in/providers/location_provider.dart';

class VenueSelector extends ConsumerStatefulWidget {
  final Function(Venue?) onVenueSelected;
  final Venue? initialVenue;

  const VenueSelector({
    super.key,
    required this.onVenueSelected,
    this.initialVenue,
  });

  @override
  ConsumerState<VenueSelector> createState() => _VenueSelectorState();
}

class _VenueSelectorState extends ConsumerState<VenueSelector> {
  List<Venue> _nearbyVenues = [];
  bool _isLoading = false;
  Venue? _selectedVenue;

  @override
  void initState() {
    super.initState();
    _selectedVenue = widget.initialVenue;
    _loadNearbyVenues();
  }

  Future<void> _loadNearbyVenues() async {
    final location = ref.read(locationProvider).value;
    if (location == null) return;

    setState(() => _isLoading = true);
    try {
      final venueService = ref.read(venueServiceProvider);
      _nearbyVenues = await venueService.fetchNearby(
       location: location,
        radiusKm: 20.0,
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected venue card OR "Select Venue" button
        _selectedVenue != null
            ? _buildSelectedVenueCard()
            : _buildSelectButton(),
        
        const SizedBox(height: 12),
        
        // Quick list of nearby venues
        if (_nearbyVenues.isNotEmpty) _buildNearbyList(),
      ],
    );
  }

  Widget _buildSelectedVenueCard() {
    final venue = _selectedVenue!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.place, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  venue.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (venue.distanceKm != null)
                  Text(
                    '${venue.distanceKm!.toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.textMuted),
            onPressed: () {
              setState(() => _selectedVenue = null);
              widget.onVenueSelected(null);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectButton() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showVenuePickerDialog,
            icon: const Icon(Icons.place),
            label: const Text('Select a Venue'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          onPressed: _showMapPicker,
          icon: const Icon(Icons.map),
          tooltip: 'Pick on Map',
        ),
      ],
    );
  }

  Widget _buildNearbyList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby Venues',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _nearbyVenues.length,
                  itemBuilder: (context, index) {
                    final venue = _nearbyVenues[index];
                    return _NearbyVenueChip(
                      venue: venue,
                      onTap: () {
                        setState(() => _selectedVenue = venue);
                        widget.onVenueSelected(venue);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showVenuePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Select Venue'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _nearbyVenues.length,
                  itemBuilder: (context, index) {
                    final venue = _nearbyVenues[index];
                    return ListTile(
                      leading: const Icon(Icons.place, color: AppTheme.primaryColor),
                      title: Text(venue.name),
                      subtitle: Text(
                        '${venue.address} • ${venue.sports.join(", ")}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: venue.distanceKm != null
                          ? Text('${venue.distanceKm!.toStringAsFixed(1)} km')
                          : null,
                      onTap: () {
                        setState(() => _selectedVenue = venue);
                        widget.onVenueSelected(venue);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _showMapPicker() async {
    // Navigate to map picker screen (returns LatLng + address)
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const MapLocationPickerScreen(),
      ),
    );

    if (result != null) {
      // Create a "virtual" venue from map selection
      final virtualVenue = Venue(
        id: -1, // Virtual
        name: result['name'] ?? 'Custom Location',
        address: result['address'] ?? '',
        city: '',
        latitude: result['latitude'],
        longitude: result['longitude'],
        sports: [],
      );
      setState(() => _selectedVenue = virtualVenue);
      widget.onVenueSelected(virtualVenue);
    }
  }
}

class _NearbyVenueChip extends StatelessWidget {
  final Venue venue;
  final VoidCallback onTap;

  const _NearbyVenueChip({required this.venue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              venue.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              venue.sports.take(2).join(', '),
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
            if (venue.distanceKm != null)
              Text(
                '${venue.distanceKm!.toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}