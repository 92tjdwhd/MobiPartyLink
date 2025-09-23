import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/party_template_entity.dart';

abstract class PartyTemplateRepository {
  /// 모든 파티 템플릿을 가져옵니다 (서버 + 커스텀)
  Future<Either<Failure, List<PartyTemplateEntity>>> getTemplates();

  /// 서버 템플릿을 가져옵니다
  Future<Either<Failure, List<PartyTemplateEntity>>> getServerTemplates();

  /// 커스텀 템플릿을 가져옵니다
  Future<Either<Failure, List<PartyTemplateEntity>>> getCustomTemplates();

  /// 특정 콘텐츠 타입의 템플릿을 가져옵니다
  Future<Either<Failure, List<PartyTemplateEntity>>> getTemplatesByContentType(
      String contentType);

  /// 템플릿 버전을 확인하고 업데이트합니다
  Future<Either<Failure, bool>> checkAndUpdateTemplates();

  /// 커스텀 템플릿을 저장합니다
  Future<Either<Failure, void>> saveCustomTemplate(
      PartyTemplateEntity template);

  /// 커스텀 템플릿을 삭제합니다
  Future<Either<Failure, void>> deleteCustomTemplate(String templateId);

  /// 템플릿으로 파티를 생성합니다
  Future<Either<Failure, PartyTemplateEntity>> createPartyFromTemplate(
    String templateId,
    String partyName,
    DateTime startTime,
    String creatorId,
  );
}
