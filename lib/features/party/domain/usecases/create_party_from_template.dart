import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_template_entity.dart';
import '../repositories/party_template_repository.dart';

class CreatePartyFromTemplate {

  CreatePartyFromTemplate(this.repository);
  final PartyTemplateRepository repository;

  Future<Either<Failure, PartyTemplateEntity>> call({
    required String templateId,
    required String partyName,
    required DateTime startTime,
    required String creatorId,
  }) async {
    return repository.createPartyFromTemplate(
      templateId,
      partyName,
      startTime,
      creatorId,
    );
  }
}
