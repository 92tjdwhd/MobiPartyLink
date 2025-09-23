import 'package:freezed_annotation/freezed_annotation.dart';

part 'party_template_entity.freezed.dart';

@freezed
class PartyTemplateEntity with _$PartyTemplateEntity {
  const factory PartyTemplateEntity({
    required String id,
    required String name,
    required String description,
    required String contentType,
    required String category,
    required String difficulty,
    required int maxMembers,
    required bool requireJob,
    required bool requirePower,
    int? minPower,
    int? maxPower,
    // 직업 제한 설정
    @Default(false) bool requireJobCategory,
    @Default(0) int tankLimit,
    @Default(0) int healerLimit,
    @Default(0) int dpsLimit,
    required String iconUrl,
    @Default(false) bool isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PartyTemplateEntity;
}
