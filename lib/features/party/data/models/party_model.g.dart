// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartyModelImpl _$$PartyModelImplFromJson(Map<String, dynamic> json) =>
    _$PartyModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      maxMembers: (json['max_members'] as num).toInt(),
      contentType: json['content_type'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      requireJob: json['require_job'] as bool,
      requirePower: json['require_power'] as bool,
      minPower: (json['min_power'] as num?)?.toInt(),
      maxPower: (json['max_power'] as num?)?.toInt(),
      requireJobCategory: json['require_job_category'] as bool? ?? false,
      tankLimit: (json['tank_limit'] as num?)?.toInt() ?? 0,
      healerLimit: (json['healer_limit'] as num?)?.toInt() ?? 0,
      dpsLimit: (json['dps_limit'] as num?)?.toInt() ?? 0,
      status: $enumDecode(_$PartyStatusEnumMap, json['status']),
      creatorId: json['creator_id'] as String,
      members: (json['party_members'] as List<dynamic>?)
              ?.map((e) => PartyMemberModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$PartyModelImplToJson(_$PartyModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'start_time': instance.startTime.toIso8601String(),
      'max_members': instance.maxMembers,
      'content_type': instance.contentType,
      'category': instance.category,
      'difficulty': instance.difficulty,
      'require_job': instance.requireJob,
      'require_power': instance.requirePower,
      'min_power': instance.minPower,
      'max_power': instance.maxPower,
      'require_job_category': instance.requireJobCategory,
      'tank_limit': instance.tankLimit,
      'healer_limit': instance.healerLimit,
      'dps_limit': instance.dpsLimit,
      'status': _$PartyStatusEnumMap[instance.status]!,
      'creator_id': instance.creatorId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$PartyStatusEnumMap = {
  PartyStatus.pending: 'pending',
  PartyStatus.startingSoon: 'startingSoon',
  PartyStatus.ongoing: 'ongoing',
  PartyStatus.completed: 'completed',
  PartyStatus.expired: 'expired',
  PartyStatus.cancelled: 'cancelled',
};
