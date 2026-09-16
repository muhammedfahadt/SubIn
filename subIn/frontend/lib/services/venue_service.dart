// frontend/lib/services/venue_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_in/models/venue.dart';
import 'package:sub_in/services/api_service.dart';

final venueServiceProvider = Provider<VenueService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return VenueService(api);
});

class VenueService {
  final ApiService _api;

  VenueService(this._api);

  /// Fetch nearby venues using PostGIS
  Future<List<Venue>> getNearbyVenues({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? sport,
  }) async {
    try {
      final queryParams = {
        'lat': latitude,
        'lon': longitude,
        'radius_km': radiusKm,
      };
      
      if (sport != null && sport.isNotEmpty) {
        queryParams['sport'] = sport.toLowerCase() as double;
      }

      final response = await _api.get('/venues/nearby', queryParams: queryParams);
      
      final List<dynamic> data = response.data;
      return data.map((json) => Venue.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new venue
  Future<Venue> createVenue({
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
    String? phone,
    String? website,
  }) async {
    try {
      final data = {
        'name': name,
        'address': address,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'sports': sports,
        'has_lights': hasLights,
        'has_changing_room': hasChangingRoom,
        'has_parking': hasParking,
        'is_free': isFree,
      };

      if (description != null) data['description'] = description;
      if (pricePerHour != null) data['price_per_hour'] = pricePerHour;
      if (phone != null) data['phone'] = phone;
      if (website != null) data['website'] = website;

      final response = await _api.post('/venues/', data: data);
      return Venue.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      return e.response!.data['detail'] ?? 'Failed to fetch venues';
    }
    return 'Network error. Please try again.';
  }
}