// frontend/lib/providers/venue_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_in/models/venue.dart';
import 'package:sub_in/services/venue_service.dart';
import 'package:sub_in/providers/location_provider.dart';

// Provider for nearby venues
final nearbyVenuesProvider = FutureProvider.autoDispose<List<Venue>>((ref) async {
  final locationAsync = ref.watch(locationProvider);
  
  return locationAsync.when(
    data: (location) async {
      final venueService = ref.watch(venueServiceProvider);
      return await venueService.getNearbyVenues(
        latitude: location.latitude,
        longitude: location.longitude,
        radiusKm: 10.0,
      );
    },
    loading: () async => [],
    error: (err, _) => throw err,
  );
});

// Provider for creating venues
final createVenueProvider = Provider<CreateVenueNotifier>((ref) {
  final venueService = ref.watch(venueServiceProvider);
  return CreateVenueNotifier(venueService);
});

class CreateVenueNotifier {
  final VenueService _venueService;

  CreateVenueNotifier(this._venueService);

  Future<Venue> create({
    required String name,
    required String address,
    required String city,
    required double latitude,
    required double longitude,
    required List<String> sports,
    String? description,
    bool hasLights = false,
    bool hasChangingRoom = false,
    bool hasParking = false,
    bool isFree = true,
    double? pricePerHour,
  }) async {
    return await _venueService.createVenue(
      name: name,
      address: address,
      city: city,
      latitude: latitude,
      longitude: longitude,
      sports: sports,
      description: description,
      hasLights: hasLights,
      hasChangingRoom: hasChangingRoom,
      hasParking: hasParking,
      isFree: isFree,
      pricePerHour: pricePerHour,
    );
  }
}