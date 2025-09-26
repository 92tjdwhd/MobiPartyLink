// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CounterEntityImpl _$$CounterEntityImplFromJson(Map<String, dynamic> json) =>
    _$CounterEntityImpl(
      value: (json['value'] as num).toInt(),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$CounterEntityImplToJson(_$CounterEntityImpl instance) =>
    <String, dynamic>{
      'value': instance.value,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
