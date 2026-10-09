



import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_in/models/event.dart';
import 'package:sub_in/providers/location_provider.dart';
import 'package:sub_in/services/event_service.dart';

final nearByEventsProvider = FutureProvider.autoDispose<List<Event>>((ref)async{
  final locationAsync = ref.watch(locationProvider);
  return locationAsync.when(
    data: (location) async {
      final eventService = ref.watch(eventServiceProvider);
      return await eventService.getNearbyEvents(
        latitude: location.latitude,
        longitude: location.longitude,
        radiusKm: 10.0,
      );
    },
    loading: () async => [],
    error: (err, _) => throw err,
 );});  

/// Provider for creating events
final createEventProvider = Provider<CreateEventNotifier>((ref) {
  final eventService = ref.watch(eventServiceProvider);
  return CreateEventNotifier(eventService);
});

class CreateEventNotifier {
  final EventService _eventService;

  CreateEventNotifier(this._eventService);

  Future<Event> create(Map<String, dynamic> eventData) async {
    return await _eventService.createEvent(eventData);
  }
}

/// Provider for joining events
final joinEventProvider = Provider<JoinEventNotifier>((ref) {
  final eventService = ref.watch(eventServiceProvider);
  return JoinEventNotifier(eventService);
});

class JoinEventNotifier {
  final EventService _eventService;

  JoinEventNotifier(this._eventService);

  Future<void> join(int eventId) async {
    await _eventService.joinEvent(eventId);
  }
}

/// Provider for single event details
final eventDetailProvider = FutureProvider.autoDispose.family<Event, int>((ref, eventId) async {
  final eventService = ref.watch(eventServiceProvider);
  return await eventService.getEvent(eventId);
});
 
