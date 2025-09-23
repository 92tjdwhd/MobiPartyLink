import 'package:freezed_annotation/freezed_annotation.dart';

part 'job_category_entity.freezed.dart';

@freezed
class JobCategoryEntity with _$JobCategoryEntity {
  const factory JobCategoryEntity({
    required String id,
    required String name,
    String? description,
    String? iconUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _JobCategoryEntity;
}
