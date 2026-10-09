import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_in/models/event.dart';
import 'package:sub_in/models/participant.dart';
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
      final data = response.data as List;
      return data
          .map((json) => Event.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Event> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _api.post('/events/', data: eventData);
      return Event.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

   Future<Event> joinEvent(int eventId) async {
    try {
      // Backend route: POST /events/{event_id}/join (path param, no body)
      final response = await _api.post('/events/$eventId/join');
      return Event.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  Future<Event> getEvent(int eventId) async {
    try {
      final response = await _api.get('/events/$eventId');
      return Event.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get event details (with participants)
Future<Map<String, dynamic>> getEventDetails(int eventId) async {
  try {
    // Get event
    final eventResponse = await _api.get('/events/$eventId');
    final event = Event.fromJson(Map<String, dynamic>.from(eventResponse.data as Map));
    
    // Get participants (we'll add this endpoint next)
    final participantsResponse = await _api.get('/events/$eventId/participants');
    final participants = (participantsResponse.data as List)
        .map((json) => Participant.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
    
    return {
      'event': event,
      'participants': participants,
    };
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
  

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data != null && data is Map) {
      final detail = data['detail'];
      // FastAPI validation errors come as a list of {loc, msg} — stringify it.
      if (detail is List) {
        return detail
            .map((d) => d is Map ? '${d['loc']?.last ?? 'field'}: ${d['msg']}' : '$d')
            .join(', ');
      }
      if (detail != null) return detail.toString();
    }
    if (e.response?.statusCode == 401) {
      return 'Unauthorized (401): please log in again.';
    }
    return 'Network error (${e.response?.statusCode ?? 'no response'}). Please try again.';
  }

  
}