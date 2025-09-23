import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_entity.dart';
import '../repositories/party_repository.dart';

class GetPartyById {
  final PartyRepository repository;

  GetPartyById(this.repository);

  Future<Either<Failure, PartyEntity?>> call(String partyId) async {
    return await repository.getPartyById(partyId);
  }
}
