import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/party_repository.dart';

class DeleteParty {
  final PartyRepository repository;

  DeleteParty(this.repository);

  Future<Either<Failure, void>> call(String partyId, String userId) async {
    return await repository.deleteParty(partyId, userId);
  }
}
