import 'package:freezed_annotation/freezed_annotation.dart';

part 'job_entity.freezed.dart';

@freezed
class JobEntity with _$JobEntity {
  const factory JobEntity({
    required String id,
    required String name,
    required String categoryId,
    String? description,
    String? iconUrl,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _JobEntity;
}
