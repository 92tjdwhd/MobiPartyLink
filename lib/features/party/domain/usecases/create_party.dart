import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_entity.dart';
import '../repositories/party_repository.dart';

class CreateParty {
  final PartyRepository repository;

  CreateParty(this.repository);

  Future<Either<Failure, PartyEntity>> call(PartyEntity party) async {
    return await repository.createParty(party);
  }
}
