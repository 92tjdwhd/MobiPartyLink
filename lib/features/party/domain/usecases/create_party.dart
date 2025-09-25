import 'package:dartz/dartz.dart';
import 'package:mobi_party_link/core/error/failures.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/features/party/domain/repositories/party_repository.dart';

class CreateParty {
  final PartyRepository repository;

  CreateParty(this.repository);

  Future<Either<Failure, PartyEntity>> call({
    required String name,
    required DateTime startTime,
    required int maxMembers,
    required String contentType,
    required String category,
    required String difficulty,
    required bool requireJob,
    required bool requirePower,
    int? minPower,
    int? maxPower,
    bool requireJobCategory = false,
    int tankLimit = 0,
    int healerLimit = 0,
    int dpsLimit = 0,
  }) async {
    try {
      // 파티 엔티티 생성
      final party = PartyEntity(
        id: '', // Repository에서 생성
        name: name,
        startTime: startTime,
        maxMembers: maxMembers,
        contentType: contentType,
        category: category,
        difficulty: difficulty,
        requireJob: requireJob,
        requirePower: requirePower,
        minPower: minPower,
        maxPower: maxPower,
        requireJobCategory: requireJobCategory,
        tankLimit: tankLimit,
        healerLimit: healerLimit,
        dpsLimit: dpsLimit,
        status: PartyStatus.pending,
        creatorId: '', // 현재 사용자 ID (Repository에서 설정)
        members: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await repository.createParty(party);
    } catch (e) {
      return Left(ServerFailure(message: '파티 생성에 실패했습니다: $e'));
    }
  }
}
