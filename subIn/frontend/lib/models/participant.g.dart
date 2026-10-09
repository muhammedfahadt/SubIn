// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Participant _$ParticipantFromJson(Map<String, dynamic> json) => _Participant(
      userId: (json['user_id'] as num).toInt(),
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      skillLevel: json['skill_level'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );

Map<String, dynamic> _$ParticipantToJson(_Participant instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'full_name': instance.fullName,
      'avatar_url': instance.avatarUrl,
      'skill_level': instance.skillLevel,
      'joined_at': instance.joinedAt.toIso8601String(),
    };
