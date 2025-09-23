import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/template_version_entity.dart';

part 'template_version_model.freezed.dart';
part 'template_version_model.g.dart';

@freezed
class TemplateVersionModel with _$TemplateVersionModel {
  const factory TemplateVersionModel({
    required int version,
    required DateTime lastUpdated,
    required int templateCount,
  }) = _TemplateVersionModel;

  factory TemplateVersionModel.fromJson(Map<String, dynamic> json) =>
      _$TemplateVersionModelFromJson(json);

  factory TemplateVersionModel.fromEntity(TemplateVersionEntity entity) =>
      TemplateVersionModel(
        version: entity.version,
        lastUpdated: entity.lastUpdated,
        templateCount: entity.templateCount,
      );
}

extension TemplateVersionModelX on TemplateVersionModel {
  TemplateVersionEntity toEntity() => TemplateVersionEntity(
        version: version,
        lastUpdated: lastUpdated,
        templateCount: templateCount,
      );
}
