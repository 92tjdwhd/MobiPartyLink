import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/data/mock_party_data.dart';
import '../../domain/entities/party_entity.dart';
import '../../domain/entities/party_member_entity.dart';
import '../../domain/repositories/party_repository.dart';
import '../datasources/party_remote_datasource.dart';

class PartyRepositoryImpl implements PartyRepository {
  final PartyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PartyRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PartyEntity>>> getParties() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }

    try {
      final parties = await remoteDataSource.getParties();
      return Right(parties);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PartyEntity>>> searchParties({
    String? query,
    String? contentType,
    bool? requireJob,
    bool? requirePower,
    int? minPower,
    int? maxPower,
    PartyStatus? status,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }

    try {
      final parties = await remoteDataSource.searchParties(
        query: query,
        contentType: contentType,
        requireJob: requireJob,
        requirePower: requirePower,
        minPower: minPower,
        maxPower: maxPower,
        status: status,
      );
      return Right(parties);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, PartyEntity?>> getPartyById(String partyId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }

    try {
      final party = await remoteDataSource.getPartyById(partyId);
      return Right(party);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, PartyEntity>> createParty(PartyEntity party) async {
    // TODO: 실제 API 연동 시 구현
    // 현재는 Mock 데이터 사용
    try {
      // 파티 ID와 생성자 ID 설정
      final newParty = party.copyWith(
        id: 'party_${DateTime.now().millisecondsSinceEpoch}',
        creatorId: 'user1', // 현재 사용자 ID (임시)
        members: [
          PartyMemberEntity(
            id: 'member_${DateTime.now().millisecondsSinceEpoch}',
            partyId: 'party_${DateTime.now().millisecondsSinceEpoch}',
            userId: 'user1',
            nickname: '플레이어1',
            jobId: '전사',
            power: 1500,
            joinedAt: DateTime.now(),
          ),
        ],
      );

      return Right(newParty);
    } catch (e) {
      return Left(ServerFailure(message: '파티 생성에 실패했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, PartyMemberEntity>> joinParty(
      String partyId, PartyMemberEntity member) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }

    try {
      final joinedMember = await remoteDataSource.joinParty(partyId, member);
      return Right(joinedMember);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveParty(
      String partyId, String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }

    try {
      await remoteDataSource.leaveParty(partyId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteParty(
      String partyId, String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }

    try {
      await remoteDataSource.deleteParty(partyId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, PartyEntity>> updateParty(PartyEntity party) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }

    try {
      final updatedParty = await remoteDataSource.updateParty(party);
      return Right(updatedParty);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PartyEntity>>> getMyParties() async {
    // TODO: 실제 API 연동 시 구현
    // 현재는 Mock 데이터 사용
    try {
      final parties = MockPartyData.getMyParties();
      return Right(parties);
    } catch (e) {
      return Left(ServerFailure(message: '내 파티 목록을 불러올 수 없습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PartyEntity>>> getJoinedParties() async {
    // TODO: 실제 API 연동 시 구현
    // 현재는 Mock 데이터 사용
    try {
      final parties = MockPartyData.getJoinedParties();
      return Right(parties);
    } catch (e) {
      return Left(ServerFailure(message: '참가한 파티 목록을 불러올 수 없습니다: $e'));
    }
  }

  @override
  Stream<List<PartyEntity>> get partiesStream {
    return remoteDataSource.partiesStream;
  }

  @override
  Stream<PartyEntity?> watchParty(String partyId) {
    return remoteDataSource.watchParty(partyId);
  }
}
