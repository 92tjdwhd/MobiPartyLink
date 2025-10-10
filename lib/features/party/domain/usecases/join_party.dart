import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_member_entity.dart';
import '../repositories/party_repository.dart';

class JoinParty {

  JoinParty(this.repository);
  final PartyRepository repository;

  Future<Either<Failure, PartyMemberEntity>> call(
      String partyId, PartyMemberEntity member) async {
    return repository.joinParty(partyId, member);
  }
}
