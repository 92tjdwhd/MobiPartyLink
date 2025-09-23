import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_entity.dart';

part 'job_model.freezed.dart';
part 'job_model.g.dart';

@freezed
class JobModel with _$JobModel {
  const factory JobModel({
    required String id,
    required String name,
    @JsonKey(name: 'category_id') required String categoryId,
    String? description,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _JobModel;

  factory JobModel.fromJson(Map<String, dynamic> json) =>
      _$JobModelFromJson(json);

  factory JobModel.fromEntity(JobEntity entity) {
    return JobModel(
      id: entity.id,
      name: entity.name,
      categoryId: entity.categoryId,
      description: entity.description,
      iconUrl: entity.iconUrl,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  JobEntity toEntity() {
    return JobEntity(
      id: id,
      name: name,
      categoryId: categoryId,
      description: description,
      iconUrl: iconUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
