// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Venue _$VenueFromJson(Map<String, dynamic> json) => _Venue(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      city: json['city'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      sports:
          (json['sports'] as List<dynamic>).map((e) => e as String).toList(),
      hasLights: json['has_lights'] as bool? ?? false,
      hasChangingRoom: json['has_changing_room'] as bool? ?? false,
      hasParking: json['has_parking'] as bool? ?? false,
      isFree: json['is_free'] as bool? ?? true,
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
                
Map<String, dynamic> _$VenueToJson(_Venue instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'city': instance.city,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'sports': instance.sports,
      'has_lights': instance.hasLights,
      'has_changing_room': instance.hasChangingRoom,
      'has_parking': instance.hasParking,
      'is_free': instance.isFree,
      'price_per_hour': instance.pricePerHour,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'phone': instance.phone,
      'website': instance.website,
      'image_urls': instance.imageUrls,
      'distance_km': instance.distanceKm,
    };
