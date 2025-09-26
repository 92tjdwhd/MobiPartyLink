// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_version_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TemplateVersionModelImpl _$$TemplateVersionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TemplateVersionModelImpl(
      version: (json['version'] as num).toInt(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      templateCount: (json['templateCount'] as num).toInt(),
    );

Map<String, dynamic> _$$TemplateVersionModelImplToJson(
        _$TemplateVersionModelImpl instance) =>
    <String, dynamic>{
      'version': instance.version,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'templateCount': instance.templateCount,
    };
