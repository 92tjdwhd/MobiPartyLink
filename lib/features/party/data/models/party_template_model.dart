import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/party_template_entity.dart';

part 'party_template_model.freezed.dart';
part 'party_template_model.g.dart';

@freezed
class PartyTemplateModel with _$PartyTemplateModel {
  const factory PartyTemplateModel({
    required String id,
    required String name,
    required String description,
    @JsonKey(name: 'content_type') required String contentType,
    required String category,
    required String difficulty,
    @JsonKey(name: 'max_members') required int maxMembers,
    @JsonKey(name: 'require_job') required bool requireJob,
    @JsonKey(name: 'require_power') required bool requirePower,
    @JsonKey(name: 'min_power') int? minPower,
    @JsonKey(name: 'max_power') int? maxPower,
    // 직업 제한 설정
    @JsonKey(name: 'require_job_category')
    @Default(false)
    bool requireJobCategory,
    @JsonKey(name: 'tank_limit') @Default(0) int tankLimit,
    @JsonKey(name: 'healer_limit') @Default(0) int healerLimit,
    @JsonKey(name: 'dps_limit') @Default(0) int dpsLimit,
    @JsonKey(name: 'icon_url') required String iconUrl,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PartyTemplateModel;

  factory PartyTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$PartyTemplateModelFromJson(json);

  factory PartyTemplateModel.fromEntity(PartyTemplateEntity entity) =>
      PartyTemplateModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        contentType: entity.contentType,
        category: entity.category,
        difficulty: entity.difficulty,
        maxMembers: entity.maxMembers,
        requireJob: entity.requireJob,
        requirePower: entity.requirePower,
        minPower: entity.minPower,
        maxPower: entity.maxPower,
        requireJobCategory: entity.requireJobCategory,
        tankLimit: entity.tankLimit,
        healerLimit: entity.healerLimit,
        dpsLimit: entity.dpsLimit,
        iconUrl: entity.iconUrl,
        isDefault: entity.isDefault,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}

extension PartyTemplateModelX on PartyTemplateModel {
  PartyTemplateEntity toEntity() => PartyTemplateEntity(
        id: id,
        name: name,
        description: description,
        contentType: contentType,
        category: category,
        difficulty: difficulty,
        maxMembers: maxMembers,
        requireJob: requireJob,
        requirePower: requirePower,
        minPower: minPower,
        maxPower: maxPower,
        requireJobCategory: requireJobCategory,
        tankLimit: tankLimit,
        healerLimit: healerLimit,
        dpsLimit: dpsLimit,
        iconUrl: iconUrl,
        isDefault: isDefault,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
