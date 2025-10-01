import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/data/mock_party_data.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/profile_service.dart';
import '../../domain/entities/party_entity.dart';
import '../../domain/entities/party_member_entity.dart';
import '../../domain/repositories/party_repository.dart';
import '../datasources/party_remote_datasource.dart';

class PartyRepositoryImpl implements PartyRepository {
  final PartyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final AuthService authService;

  PartyRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.authService,
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
    try {
      // 1. userId 확보 (익명 로그인)
      final userId = await authService.ensureUserId();
      print('✅ 파티 생성 userId: $userId');

      // 2. 로컬 프로필 가져오기
      final profile = await ProfileService.getMainProfile();
      if (profile == null) {
        return Left(ServerFailure(message: '프로필을 먼저 설정해주세요'));
      }

      // 3. FCM 토큰 가져오기
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('✅ FCM 토큰: ${fcmToken?.substring(0, 20)}...');

      // 4. 파티 ID 생성
      final partyId = 'party_${DateTime.now().millisecondsSinceEpoch}';

      // 5. 생성자를 첫 번째 멤버로 추가
      final creatorMember = PartyMemberEntity(
        id: 'member_${DateTime.now().millisecondsSinceEpoch}',
        partyId: partyId,
        userId: userId,
        nickname: profile.nickname,
        job: profile.jobId, // 직업 이름
        power: profile.power,
        fcmToken: fcmToken,
        joinedAt: DateTime.now(),
      );

      // 6. 파티 생성
      final newParty = party.copyWith(
        id: partyId,
        creatorId: userId,
        members: [creatorMember],
      );

      // 7. Supabase에 저장 (TODO: 실제 API 연동)
      // final savedParty = await remoteDataSource.createParty(newParty);

      print('✅ 파티 생성 완료: ${newParty.name}');
      return Right(newParty);
    } catch (e) {
      print('❌ 파티 생성 에러: $e');
      return Left(ServerFailure(message: '파티 생성에 실패했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, PartyMemberEntity>> joinParty(
      String partyId, PartyMemberEntity member) async {
    try {
      // 1. userId 확보 (익명 로그인)
      final userId = await authService.ensureUserId();
      print('✅ 파티 참가 userId: $userId');

      // 2. 로컬 프로필 가져오기
      final profile = await ProfileService.getMainProfile();
      if (profile == null) {
        return Left(ServerFailure(message: '프로필을 먼저 설정해주세요'));
      }

      // 3. FCM 토큰 가져오기
      final fcmToken = await FirebaseMessaging.instance.getToken();

      // 4. 멤버 정보 업데이트
      final updatedMember = member.copyWith(
        userId: userId,
        nickname: profile.nickname,
        job: profile.jobId,
        power: profile.power,
        fcmToken: fcmToken,
        joinedAt: DateTime.now(),
      );

      // 5. Supabase에 저장 (TODO: 실제 API 연동)
      // final joinedMember = await remoteDataSource.joinParty(partyId, updatedMember);

      print('✅ 파티 참가 완료: ${updatedMember.nickname}');
      return Right(updatedMember);
    } catch (e) {
      print('❌ 파티 참가 에러: $e');
      return Left(ServerFailure(message: '파티 참가에 실패했습니다: $e'));
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
