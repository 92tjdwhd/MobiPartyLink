import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_entity.dart';
import '../repositories/party_repository.dart';

class SearchParties {

  SearchParties(this.repository);
  final PartyRepository repository;

  Future<Either<Failure, List<PartyEntity>>> call({
    String? query,
    String? contentType,
    bool? requireJob,
    bool? requirePower,
    int? minPower,
    int? maxPower,
    PartyStatus? status,
  }) async {
    return repository.searchParties(
      query: query,
      contentType: contentType,
      requireJob: requireJob,
      requirePower: requirePower,
      minPower: minPower,
      maxPower: maxPower,
      status: status,
    );
  }
}
