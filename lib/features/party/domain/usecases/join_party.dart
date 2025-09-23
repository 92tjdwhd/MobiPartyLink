import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_member_entity.dart';
import '../repositories/party_repository.dart';

class JoinParty {
  final PartyRepository repository;

  JoinParty(this.repository);

  Future<Either<Failure, PartyMemberEntity>> call(
      String partyId, PartyMemberEntity member) async {
    return await repository.joinParty(partyId, member);
  }
}
