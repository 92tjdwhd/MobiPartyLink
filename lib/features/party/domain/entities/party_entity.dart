import 'package:freezed_annotation/freezed_annotation.dart';

import 'party_member_entity.dart';

part 'party_entity.freezed.dart';

@freezed
class PartyEntity with _$PartyEntity {
  const factory PartyEntity({
    required String id,
    required String name,
    required DateTime startTime,
    required int maxMembers,
    required String contentType,
    required String category,
    required String difficulty,
    required bool requireJob,
    required bool requirePower,
    int? minPower,
    int? maxPower,
    // 직업 제한 설정
    @Default(false) bool requireJobCategory,
    @Default(0) int tankLimit,
    @Default(0) int healerLimit,
    @Default(0) int dpsLimit,
    required PartyStatus status,
    required String creatorId,
    @Default([]) List<PartyMemberEntity> members,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PartyEntity;
}

enum PartyStatus {
  pending, // 대기중
  startingSoon, // 시작 5분 전
  ongoing, // 진행중
  completed, // 완료
  expired, // 만료됨
  cancelled, // 취소됨
}
