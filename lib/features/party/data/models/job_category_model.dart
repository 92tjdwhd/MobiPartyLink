import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_category_entity.dart';

part 'job_category_model.freezed.dart';
part 'job_category_model.g.dart';

@freezed
class JobCategoryModel with _$JobCategoryModel {
  const factory JobCategoryModel({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _JobCategoryModel;

  factory JobCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$JobCategoryModelFromJson(json);

  factory JobCategoryModel.fromEntity(JobCategoryEntity entity) {
    return JobCategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      iconUrl: entity.iconUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  JobCategoryEntity toEntity() {
    return JobCategoryEntity(
      id: id,
      name: name,
      description: description,
      iconUrl: iconUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
