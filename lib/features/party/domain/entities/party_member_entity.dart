import 'package:freezed_annotation/freezed_annotation.dart';

part 'party_member_entity.freezed.dart';

@freezed
class PartyMemberEntity with _$PartyMemberEntity {
  const factory PartyMemberEntity({
    required String id,
    required String partyId,
    required String userId,
    required String nickname,
    String? job, // 직업 이름 (로컬 프로필)
    int? power, // 전투력 (로컬 프로필)
    String? fcmToken, // FCM 토큰 (푸시 알림용)
    required DateTime joinedAt,
  }) = _PartyMemberEntity;
}
