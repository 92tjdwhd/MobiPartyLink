// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartyTemplateModelImpl _$$PartyTemplateModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PartyTemplateModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      contentType: json['content_type'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      maxMembers: (json['max_members'] as num).toInt(),
      requireJob: json['require_job'] as bool,
      requirePower: json['require_power'] as bool,
      minPower: (json['min_power'] as num?)?.toInt(),
      maxPower: (json['max_power'] as num?)?.toInt(),
      requireJobCategory: json['require_job_category'] as bool? ?? false,
      tankLimit: (json['tank_limit'] as num?)?.toInt() ?? 0,
      healerLimit: (json['healer_limit'] as num?)?.toInt() ?? 0,
      dpsLimit: (json['dps_limit'] as num?)?.toInt() ?? 0,
      iconUrl: json['icon_url'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$PartyTemplateModelImplToJson(
        _$PartyTemplateModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'content_type': instance.contentType,
      'category': instance.category,
      'difficulty': instance.difficulty,
      'max_members': instance.maxMembers,
      'require_job': instance.requireJob,
      'require_power': instance.requirePower,
      'min_power': instance.minPower,
      'max_power': instance.maxPower,
      'require_job_category': instance.requireJobCategory,
      'tank_limit': instance.tankLimit,
      'healer_limit': instance.healerLimit,
      'dps_limit': instance.dpsLimit,
      'icon_url': instance.iconUrl,
      'is_default': instance.isDefault,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
