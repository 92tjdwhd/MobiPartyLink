// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JobCategoryModelImpl _$$JobCategoryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$JobCategoryModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$JobCategoryModelImplToJson(
        _$JobCategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon_url': instance.iconUrl,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
