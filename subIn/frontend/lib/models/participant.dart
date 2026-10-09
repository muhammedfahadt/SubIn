import 'package:freezed_annotation/freezed_annotation.dart';

part 'participant.freezed.dart';
part 'participant.g.dart';

@freezed
abstract class Participant with _$Participant {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Participant({
    required int userId,
    required String fullName,
    String? avatarUrl,
    required String skillLevel,
    required DateTime joinedAt,
  }) = _Participant;

  factory Participant.fromJson(Map<String, dynamic> json) => _$ParticipantFromJson(json);
}