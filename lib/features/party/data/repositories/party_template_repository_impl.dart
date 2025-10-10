import 'package:dartz/dartz.dart';
import 'package:mobi_party_link/core/error/exceptions.dart';
import 'package:mobi_party_link/core/error/failures.dart';
import 'package:mobi_party_link/core/network/network_info.dart';
import 'package:mobi_party_link/features/party/data/datasources/party_template_server_datasource.dart';
import 'package:mobi_party_link/features/party/data/datasources/party_template_local_datasource.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_template_entity.dart';
import 'package:mobi_party_link/features/party/domain/repositories/party_template_repository.dart';

class PartyTemplateRepositoryImpl implements PartyTemplateRepository {

  PartyTemplateRepositoryImpl({
    required this.serverDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  final PartyTemplateServerDataSource serverDataSource;
  final PartyTemplateLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<PartyTemplateEntity>>> getTemplates() async {
    if (await networkInfo.isConnected) {
      try {
        final serverTemplates = await serverDataSource.getServerTemplates();
        final localTemplates = await localDataSource.getCustomTemplates();
        return Right([...serverTemplates, ...localTemplates]);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
      }
    } else {
      // 오프라인일 때는 로컬 템플릿만 반환
      try {
        final localTemplates = await localDataSource.getCustomTemplates();
        return Right(localTemplates);
      } catch (e) {
        return const Left(CacheFailure(message: '로컬 템플릿을 불러올 수 없습니다'));
      }
    }
  }

  @override
  Future<Either<Failure, List<PartyTemplateEntity>>>
      getServerTemplates() async {
    if (await networkInfo.isConnected) {
      try {
        final templates = await serverDataSource.getServerTemplates();
        return Right(templates);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }
  }

  @override
  Future<Either<Failure, List<PartyTemplateEntity>>>
      getCustomTemplates() async {
    try {
      final templates = await localDataSource.getCustomTemplates();
      return Right(templates);
    } catch (e) {
      return const Left(CacheFailure(message: '커스텀 템플릿을 불러올 수 없습니다'));
    }
  }

  @override
  Future<Either<Failure, List<PartyTemplateEntity>>> getTemplatesByContentType(
      String contentType) async {
    if (await networkInfo.isConnected) {
      try {
        final serverTemplates = await serverDataSource.getServerTemplates();
        final filteredTemplates = serverTemplates
            .where((template) => template.contentType == contentType)
            .toList();
        return Right(filteredTemplates);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkAndUpdateTemplates() async {
    if (await networkInfo.isConnected) {
      try {
        final versionInfo = await serverDataSource.getTemplateVersion();
        final localVersionEntity = await localDataSource.getTemplateVersion();
        final localVersion = localVersionEntity?.version ?? 0;

        if (versionInfo.version > localVersion) {
          // 서버 버전이 더 높으면 업데이트
          final serverTemplates = await serverDataSource.getServerTemplates();
          await localDataSource.saveServerTemplates(serverTemplates);
          await localDataSource.saveTemplateVersion(versionInfo);
          return const Right(true);
        }

        return const Right(false);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }
  }

  @override
  Future<Either<Failure, void>> saveCustomTemplate(
      PartyTemplateEntity template) async {
    try {
      await localDataSource.saveCustomTemplate(template);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure(message: '커스텀 템플릿 저장에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomTemplate(String templateId) async {
    try {
      await localDataSource.deleteCustomTemplate(templateId);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure(message: '커스텀 템플릿 삭제에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, PartyTemplateEntity>> createPartyFromTemplate(
    String templateId,
    String partyName,
    DateTime startTime,
    String creatorId,
  ) async {
    try {
      // 템플릿 찾기
      final allTemplates = await getTemplates();

      return allTemplates.fold(
        Left.new,
        (templates) {
          final template = templates.firstWhere(
            (t) => t.id == templateId,
            orElse: () => throw const ServerException(message: '템플릿을 찾을 수 없습니다'),
          );

          // 템플릿 기반 파티 생성 로직은 PartyRepository에서 처리
          return Right(template);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: '템플릿에서 파티를 생성하는데 실패했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getTemplatesVersion() async {
    if (await networkInfo.isConnected) {
      try {
        final version = await serverDataSource.getTemplatesVersion();
        return Right(version);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }
  }
}
