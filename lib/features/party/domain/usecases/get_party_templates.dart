import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_template_entity.dart';
import '../repositories/party_template_repository.dart';

class GetPartyTemplates {
  final PartyTemplateRepository repository;

  GetPartyTemplates(this.repository);

  Future<Either<Failure, List<PartyTemplateEntity>>> call() async {
    return await repository.getTemplates();
  }
}
