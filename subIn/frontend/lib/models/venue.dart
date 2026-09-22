// frontend/lib/models/venue.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue.freezed.dart';
part 'venue.g.dart';

@freezed
abstract class Venue with _$Venue {
  const factory Venue({
    required int id,
    required String name,
    String? description,
    required String address,
    required String city,
    required double latitude,
    required double longitude,
    required List<String> sports,
    @Default(false) bool hasLights,
    @Default(false) bool hasChangingRoom,
    @Default(false) bool hasParking,
    @Default(true) bool isFree,
    double? pricePerHour,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    String? phone,
    String? website,
    @Default([]) List<String> imageUrls,
    double? distanceKm,
  }) = _Venue;

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);
}