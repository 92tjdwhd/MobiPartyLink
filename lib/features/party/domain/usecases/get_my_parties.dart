import 'package:dartz/dartz.dart';
import 'package:mobi_party_link/core/error/failures.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/features/party/domain/repositories/party_repository.dart';

class GetMyParties {
  final PartyRepository repository;

  GetMyParties(this.repository);

  Future<Either<Failure, List<PartyEntity>>> call() async {
    return await repository.getMyParties();
  }
}
