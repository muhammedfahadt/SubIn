import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/providers/location_provider.dart';

class MapLocationPickerScreen extends ConsumerStatefulWidget {
  const MapLocationPickerScreen({super.key});

  @override
  ConsumerState<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends ConsumerState<MapLocationPickerScreen> {
  LatLng? _selectedPosition;
  String _address = 'Tap on map to select location';
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          TextButton(
            onPressed: _selectedPosition == null
                ? null
                : () => Navigator.pop(context, {
                      'latitude': _selectedPosition!.latitude,
                      'longitude': _selectedPosition!.longitude,
                      'name': 'Custom Location',
                      'address': _address,
                    }),
            child: const Text('Confirm'),
          ),
        ],
      ),
      body: locationAsync.when(
        data: (location) => Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                // locationProvider uses latlong2 LatLng; GoogleMap needs
                // google_maps_flutter LatLng — same shape, different type.
                target: LatLng(location.latitude, location.longitude),
                zoom: 14,
              ),
              myLocationEnabled: true,
              onTap: (latLng) {
                setState(() => _selectedPosition = latLng);
                _reverseGeocode(latLng);
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(latLng),
                );
              },
              onMapCreated: (controller) => _mapController = controller,
              markers: _selectedPosition != null
                  ? {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: _selectedPosition!,
                        infoWindow: InfoWindow(title: _address),
                      ),
                    }
                  : {},
            ),
            // Bottom info card
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.touch_app, color: AppTheme.primaryColor),
                    const SizedBox(height: 8),
                    Text(
                      _selectedPosition == null
                          ? 'Tap on the map to set location'
                          : 'Location selected',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _address,
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _reverseGeocode(LatLng position) async {
    // In production, use geocoding package:
    // final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    // setState(() => _address = placemarks.first.street ?? 'Unknown');
    
    setState(() => _address = 
        '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}');
  }
}