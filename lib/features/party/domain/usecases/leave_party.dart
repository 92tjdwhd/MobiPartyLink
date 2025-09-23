import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/party_repository.dart';

class LeaveParty {
  final PartyRepository repository;

  LeaveParty(this.repository);

  Future<Either<Failure, void>> call(String partyId, String userId) async {
    return await repository.leaveParty(partyId, userId);
  }
}
