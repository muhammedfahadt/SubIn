// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      sport: json['sport'] as String,
      venueId: (json['venueId'] as num?)?.toInt(),
      customLocation: json['customLocation'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      maxPlayers: (json['maxPlayers'] as num).toInt(),
      minPlayers: (json['minPlayers'] as num).toInt(),
      currentPlayers: (json['currentPlayers'] as num).toInt(),
      isFree: json['isFree'] as bool,
      costPerPlayer: (json['costPerPlayer'] as num?)?.toDouble(),
      status: json['status'] as String,
      skillLevel: json['skillLevel'] as String,
      isPublic: json['isPublic'] as bool,
      organizerId: (json['organizerId'] as num).toInt(),
      organizerName: json['organizerName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      spotsRemaining: (json['spotsRemaining'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'sport': instance.sport,
      'venueId': instance.venueId,
      'customLocation': instance.customLocation,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'maxPlayers': instance.maxPlayers,
      'minPlayers': instance.minPlayers,
      'currentPlayers': instance.currentPlayers,
      'isFree': instance.isFree,
      'costPerPlayer': instance.costPerPlayer,
      'status': instance.status,
      'skillLevel': instance.skillLevel,
      'isPublic': instance.isPublic,
      'organizerId': instance.organizerId,
      'organizerName': instance.organizerName,
      'createdAt': instance.createdAt.toIso8601String(),
      'distanceKm': instance.distanceKm,
      'spotsRemaining': instance.spotsRemaining,
    };
