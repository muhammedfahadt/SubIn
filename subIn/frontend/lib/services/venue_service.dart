import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:sub_in/config/app_constants.dart';
import 'package:sub_in/models/venue.dart';
import 'package:sub_in/providers/location_provider.dart';
import 'package:sub_in/services/api_service.dart';

// Talks to FastAPI /venues/* (PostGIS nearby + create)
final venueServiceProvider = Provider<VenueService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return VenueService(api);
});

class VenueService {
  final ApiService _api;
  VenueService(this._api);

  Future<List<Venue>> fetchNearby({
    required LatLng location,
    double radiusKm = AppConstants.defaultSearchRadiusKm,
  }) async {
    final resp = await _api.get('/venues/nearby', queryParams: {
      'lat': location.latitude,
      'lon': location.longitude,
      'radius_km': radiusKm,
    });
    final data = resp.data as List;
    return data.map((e) => Venue.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<Venue> createVenue({
    required String name,
    required String address,
    required String city,
    required double latitude,
    required double longitude,
    required List<String> sports,
    bool hasLights = false,
    bool hasChangingRoom = false,
    bool hasParking = false,
    bool isFree = true,
    double? pricePerHour,
    String? description,
    String? phone,
    String? website,
  }) async {
    final resp = await _api.post('/venues/', data: {
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'sports': sports.map((s) => s.toLowerCase()).toList(),
      'has_lights': hasLights,
      'has_changing_room': hasChangingRoom,
      'has_parking': hasParking,
      'is_free': isFree,
      'price_per_hour': pricePerHour,
      'phone': phone,
      'website': website,
    });
    return Venue.fromJson(Map<String, dynamic>.from(resp.data as Map));
  }
}

final selectedSportProvider = StateProvider<String>((ref) => 'All');
final searchRadiusProvider = StateProvider<double>((ref) => AppConstants.defaultSearchRadiusKm);
final venueRefreshProvider = StateProvider<int>((ref) => 0);

final nearbyVenuesProvider = FutureProvider<List<Venue>>((ref) async {
  final location = ref.watch(locationProvider).value;
  if (location == null) return [];
  final radiusKm = ref.watch(searchRadiusProvider);
  ref.watch(venueRefreshProvider);
  final venues = await ref.watch(venueServiceProvider).fetchNearby(
        location: location,
        radiusKm: radiusKm,
      );
  final sport = ref.watch(selectedSportProvider);
  if (sport == 'All') return venues;
  final lower = sport.toLowerCase();
  return venues.where((v) => v.sports.map((s) => s.toLowerCase()).contains(lower)).toList();
});
