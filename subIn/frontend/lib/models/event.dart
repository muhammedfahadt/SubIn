import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
abstract class Event with _$Event {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Event({
    required int id,
    required String title,
    String? description,
    required String sport,
    int? venueId,
    String? customLocation,
    double? latitude,
    double? longitude,
    required DateTime startTime,
    required DateTime endTime,
    required int maxPlayers,
    required int minPlayers,
    required int currentPlayers,
    required bool isFree,
    double? costPerPlayer,
    required String status,
    required String skillLevel,
    required bool isPublic,
    required int organizerId,
    required String organizerName,
    required DateTime createdAt,
    double? distanceKm,
    int? spotsRemaining,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}