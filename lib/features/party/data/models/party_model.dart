import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/party_entity.dart';
import '../../domain/entities/party_member_entity.dart';
import 'party_member_model.dart';

part 'party_model.freezed.dart';
part 'party_model.g.dart';

@freezed
class PartyModel with _$PartyModel {
  const factory PartyModel({
    @JsonKey(includeToJson: false) required String id, // ← id는 Supabase가 자동 생성
    required String name,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'max_members') required int maxMembers,
    @JsonKey(name: 'content_type') required String contentType,
    required String category,
    required String difficulty,
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
    required PartyStatus status,
    @JsonKey(name: 'creator_id') required String creatorId,
    @JsonKey(
        name: 'party_members', // ← Supabase가 보내는 키 이름
        includeFromJson: true,
        includeToJson: false) // ← members는 조회 시에만 포함
    @Default([])
    List<PartyMemberModel> members,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PartyModel;

  factory PartyModel.fromJson(Map<String, dynamic> json) =>
      _$PartyModelFromJson(json);

  factory PartyModel.fromEntity(PartyEntity entity) => PartyModel(
        id: entity.id,
        name: entity.name,
        startTime: entity.startTime,
        maxMembers: entity.maxMembers,
        contentType: entity.contentType,
        category: entity.category,
        difficulty: entity.difficulty,
        requireJob: entity.requireJob,
        requirePower: entity.requirePower,
        minPower: entity.minPower,
        maxPower: entity.maxPower,
        requireJobCategory: entity.requireJobCategory,
        tankLimit: entity.tankLimit,
        healerLimit: entity.healerLimit,
        dpsLimit: entity.dpsLimit,
        status: entity.status,
        creatorId: entity.creatorId,
        members:
            entity.members.map((e) => PartyMemberModel.fromEntity(e)).toList(),
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}

extension PartyModelX on PartyModel {
  PartyEntity toEntity() {
    print('🔍 PartyModel.toEntity(): ${name}, members: ${members.length}개');
    final memberEntities = members.map((e) => e.toEntity()).toList();
    print('🔍 변환된 memberEntities: ${memberEntities.length}개');

    return PartyEntity(
      id: id,
      name: name,
      startTime: startTime,
      maxMembers: maxMembers,
      contentType: contentType,
      category: category,
      difficulty: difficulty,
      requireJob: requireJob,
      requirePower: requirePower,
      minPower: minPower,
      maxPower: maxPower,
      requireJobCategory: requireJobCategory,
      tankLimit: tankLimit,
      healerLimit: healerLimit,
      dpsLimit: dpsLimit,
      status: status,
      creatorId: creatorId,
      members: memberEntities,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
