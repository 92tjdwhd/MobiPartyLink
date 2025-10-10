import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_entity.dart';
import '../repositories/party_repository.dart';

class UpdateParty {

  UpdateParty(this.repository);
  final PartyRepository repository;

  Future<Either<Failure, PartyEntity>> call(PartyEntity party) async {
    return repository.updateParty(party);
  }
}
