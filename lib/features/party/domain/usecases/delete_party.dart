import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/party_repository.dart';

class DeleteParty {

  DeleteParty(this.repository);
  final PartyRepository repository;

  Future<Either<Failure, void>> call(String partyId, String userId) async {
    return repository.deleteParty(partyId, userId);
  }
}
