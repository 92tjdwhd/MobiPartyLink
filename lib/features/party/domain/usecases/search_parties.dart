import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_entity.dart';
import '../repositories/party_repository.dart';

class SearchParties {
  final PartyRepository repository;

  SearchParties(this.repository);

  Future<Either<Failure, List<PartyEntity>>> call({
    String? query,
    String? contentType,
    bool? requireJob,
    bool? requirePower,
    int? minPower,
    int? maxPower,
    PartyStatus? status,
  }) async {
    return await repository.searchParties(
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
