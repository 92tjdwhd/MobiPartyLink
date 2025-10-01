import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/party_member_entity.dart';

part 'party_member_model.freezed.dart';
part 'party_member_model.g.dart';

@freezed
class PartyMemberModel with _$PartyMemberModel {
  const factory PartyMemberModel({
    required String id,
    @JsonKey(name: 'party_id') required String partyId,
    @JsonKey(name: 'user_id') required String userId,
    required String nickname,
    String? job, // 직업 이름 (로컬 프로필)
    int? power, // 전투력 (로컬 프로필)
    @JsonKey(name: 'fcm_token') String? fcmToken, // FCM 토큰
    @JsonKey(name: 'joined_at') required DateTime joinedAt,
  }) = _PartyMemberModel;

  factory PartyMemberModel.fromJson(Map<String, dynamic> json) =>
      _$PartyMemberModelFromJson(json);

  factory PartyMemberModel.fromEntity(PartyMemberEntity entity) =>
      PartyMemberModel(
        id: entity.id,
        partyId: entity.partyId,
        userId: entity.userId,
        nickname: entity.nickname,
        job: entity.job,
        power: entity.power,
        fcmToken: entity.fcmToken,
        joinedAt: entity.joinedAt,
      );
}

extension PartyMemberModelX on PartyMemberModel {
  PartyMemberEntity toEntity() => PartyMemberEntity(
        id: id,
        partyId: partyId,
        userId: userId,
        nickname: nickname,
        job: job,
        power: power,
        fcmToken: fcmToken,
        joinedAt: joinedAt,
      );
}
