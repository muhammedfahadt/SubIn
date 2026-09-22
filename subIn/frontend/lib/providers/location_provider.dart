import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, AsyncValue<LatLng>>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<AsyncValue<LatLng>> {
  LocationNotifier() : super(const AsyncValue.loading()) {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await _determinePosition();
      state = AsyncValue.data(LatLng(position.latitude, position.longitude));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> refreshLocation() async {
    state = const AsyncValue.loading();
    await _initializeLocation();
  }

  LatLng? get currentLocation {
    return state.value;
  }
}