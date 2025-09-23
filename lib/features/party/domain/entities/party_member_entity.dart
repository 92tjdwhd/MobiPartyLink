import 'package:freezed_annotation/freezed_annotation.dart';

part 'party_member_entity.freezed.dart';

@freezed
class PartyMemberEntity with _$PartyMemberEntity {
  const factory PartyMemberEntity({
    required String id,
    required String partyId,
    required String userId,
    required String nickname,
    String? jobId, // job -> jobId로 변경
    int? power,
    required DateTime joinedAt,
  }) = _PartyMemberEntity;
}
