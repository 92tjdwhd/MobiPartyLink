import 'package:freezed_annotation/freezed_annotation.dart';

part 'template_version_entity.freezed.dart';

@freezed
class TemplateVersionEntity with _$TemplateVersionEntity {
  const factory TemplateVersionEntity({
    required int version,
    required DateTime lastUpdated,
    required int templateCount,
  }) = _TemplateVersionEntity;
}
