import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_entity.dart';
import '../repositories/party_repository.dart';

class GetParties {
  final PartyRepository repository;

  GetParties(this.repository);

  Future<Either<Failure, List<PartyEntity>>> call() async {
    return await repository.getParties();
  }
}
