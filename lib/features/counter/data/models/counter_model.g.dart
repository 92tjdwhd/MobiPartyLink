// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CounterModelImpl _$$CounterModelImplFromJson(Map<String, dynamic> json) =>
    _$CounterModelImpl(
      value: (json['value'] as num).toInt(),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$CounterModelImplToJson(_$CounterModelImpl instance) =>
    <String, dynamic>{
      'value': instance.value,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
