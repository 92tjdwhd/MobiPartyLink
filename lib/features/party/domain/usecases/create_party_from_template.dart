import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_template_entity.dart';
import '../repositories/party_template_repository.dart';

class CreatePartyFromTemplate {
  final PartyTemplateRepository repository;

  CreatePartyFromTemplate(this.repository);

  Future<Either<Failure, PartyTemplateEntity>> call({
    required String templateId,
    required String partyName,
    required DateTime startTime,
    required String creatorId,
  }) async {
    return await repository.createPartyFromTemplate(
      templateId,
      partyName,
      startTime,
      creatorId,
    );
  }
}
