import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_entity.dart';
import '../repositories/party_repository.dart';

class GetParties {

  GetParties(this.repository);
  final PartyRepository repository;

  Future<Either<Failure, List<PartyEntity>>> call() async {
    return repository.getParties();
  }
}
