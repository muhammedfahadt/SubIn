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
    @JsonKey(name: 'has_lights') @Default(false) bool hasLights,
    @JsonKey(name: 'has_changing_room') @Default(false) bool hasChangingRoom,
    @JsonKey(name: 'has_parking') @Default(false) bool hasParking,
    @JsonKey(name: 'is_free') @Default(true) bool isFree,
    @JsonKey(name: 'price_per_hour') double? pricePerHour,
    @Default(0.0) double rating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    String? phone,
    String? website,
    @JsonKey(name: 'image_urls') @Default([]) List<String> imageUrls,
    @JsonKey(name: 'distance_km') double? distanceKm,
  }) = _Venue;

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);
}