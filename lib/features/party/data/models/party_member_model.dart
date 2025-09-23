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
    @JsonKey(name: 'job_id') String? jobId, // job -> jobId로 변경
    int? power,
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
        jobId: entity.jobId, // job -> jobId로 변경
        power: entity.power,
        joinedAt: entity.joinedAt,
      );
}

extension PartyMemberModelX on PartyMemberModel {
  PartyMemberEntity toEntity() => PartyMemberEntity(
        id: id,
        partyId: partyId,
        userId: userId,
        nickname: nickname,
        jobId: jobId, // job -> jobId로 변경
        power: power,
        joinedAt: joinedAt,
      );
}
