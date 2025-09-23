import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_entity.freezed.dart';
part 'counter_entity.g.dart';

@freezed
class CounterEntity with _$CounterEntity {
  const factory CounterEntity({
    required int value,
    DateTime? lastUpdated,
  }) = _CounterEntity;

  factory CounterEntity.fromJson(Map<String, dynamic> json) =>
      _$CounterEntityFromJson(json);
}
