import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_in/models/event.dart';
import 'package:sub_in/services/api_service.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return EventService(api);
});

class EventService {
  final ApiService _api;

  EventService(this._api);

  /// Fetch nearby events
  Future<List<Event>> getNearbyEvents({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? sport,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'lat': latitude,
        'lon': longitude,
        'radius_km': radiusKm,
      };
      
      if (sport != null && sport.isNotEmpty) {
        queryParams['sport'] = sport.toLowerCase();
      }

      final response = await _api.get('/events/nearby', queryParams: queryParams);
      final List<dynamic> data = response.data;
      return data.map((json) => Event.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Event> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _api.post('/events/', data: eventData);
      return Event.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

   Future<void> joinEvent(int eventId) async {
    try {
      await _api.post('/events/join', data: {'event_id': eventId});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


Future<Event> getEvent(int eventId) async {
    try {
      final response = await _api.get('/events/$eventId');
      return Event.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  

  String _handleError(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      return e.response!.data['detail'] ?? 'Failed to fetch events';
    }
    return 'Network error. Please try again.';
  }
}