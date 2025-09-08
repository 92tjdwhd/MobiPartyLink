import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/counter_entity.dart';

part 'counter_model.freezed.dart';
part 'counter_model.g.dart';

@freezed
class CounterModel with _$CounterModel {
  const factory CounterModel({
    required int value,
    required DateTime lastUpdated,
  }) = _CounterModel;

  factory CounterModel.fromJson(Map<String, dynamic> json) =>
      _$CounterModelFromJson(json);

  factory CounterModel.fromEntity(CounterEntity entity) => CounterModel(
        value: entity.value,
        lastUpdated: entity.lastUpdated,
      );
}

extension CounterModelX on CounterModel {
  CounterEntity toEntity() => CounterEntity(
        value: value,
        lastUpdated: lastUpdated,
      );
}
