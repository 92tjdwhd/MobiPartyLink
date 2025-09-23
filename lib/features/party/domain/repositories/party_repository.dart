import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_entity.dart';
import '../entities/party_member_entity.dart';

abstract class PartyRepository {
  /// 파티 목록을 가져옵니다
  Future<Either<Failure, List<PartyEntity>>> getParties();

  /// 파티를 검색합니다
  Future<Either<Failure, List<PartyEntity>>> searchParties({
    String? query,
    String? contentType,
    bool? requireJob,
    bool? requirePower,
    int? minPower,
    int? maxPower,
    PartyStatus? status,
  });

  /// 특정 파티 정보를 가져옵니다
  Future<Either<Failure, PartyEntity?>> getPartyById(String partyId);

  /// 파티를 생성합니다
  Future<Either<Failure, PartyEntity>> createParty(PartyEntity party);

  /// 파티에 참여합니다
  Future<Either<Failure, PartyMemberEntity>> joinParty(
      String partyId, PartyMemberEntity member);

  /// 파티에서 나갑니다
  Future<Either<Failure, void>> leaveParty(String partyId, String userId);

  /// 파티를 삭제합니다 (생성자만 가능)
  Future<Either<Failure, void>> deleteParty(String partyId, String userId);

  /// 파티 정보를 업데이트합니다 (생성자만 가능)
  Future<Either<Failure, PartyEntity>> updateParty(PartyEntity party);

  /// 파티 상태 변화를 스트림으로 구독합니다
  Stream<List<PartyEntity>> get partiesStream;

  /// 특정 파티의 상태 변화를 스트림으로 구독합니다
  Stream<PartyEntity?> watchParty(String partyId);
}
