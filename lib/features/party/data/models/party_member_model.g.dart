// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartyMemberModelImpl _$$PartyMemberModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PartyMemberModelImpl(
      id: json['id'] as String,
      partyId: json['party_id'] as String,
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      job: json['job'] as String?,
      power: (json['power'] as num?)?.toInt(),
      fcmToken: json['fcm_token'] as String?,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );

Map<String, dynamic> _$$PartyMemberModelImplToJson(
        _$PartyMemberModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'party_id': instance.partyId,
      'user_id': instance.userId,
      'nickname': instance.nickname,
      'job': instance.job,
      'power': instance.power,
      'fcm_token': instance.fcmToken,
      'joined_at': instance.joinedAt.toIso8601String(),
    };
