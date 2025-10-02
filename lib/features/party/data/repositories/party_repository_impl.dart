import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/data/mock_party_data.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/profile_service.dart';
import '../../../../core/services/local_storage_service.dart';
// FCM 푸시는 Database Webhooks에서 자동 처리
// import '../../../../core/services/fcm_push_service.dart';
import '../../domain/entities/party_entity.dart';
import '../../domain/entities/party_member_entity.dart';
import '../../domain/repositories/party_repository.dart';
import '../datasources/party_remote_datasource.dart';

class PartyRepositoryImpl implements PartyRepository {
  PartyRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.authService,
  });
  final PartyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final AuthService authService;

  @override
  Future<Either<Failure, List<PartyEntity>>> getParties() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
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
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
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
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
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
      var profile = await ProfileService.getMainProfile();
      if (profile == null) {
        // 메인 프로필이 없으면 프로필 리스트에서 첫 번째 가져오기
        final profiles = await ProfileService.getProfileList();
        if (profiles.isEmpty) {
          return const Left(ServerFailure(message: '프로필을 먼저 설정해주세요'));
        }
        // 첫 번째 프로필을 메인으로 설정
        await ProfileService.setMainProfile(profiles.first.id);
        profile = profiles.first;
        print('✅ 첫 번째 프로필을 메인으로 설정: ${profile.nickname}');
      }

      // 3. FCM 토큰 가져오기 (실패 시 더미 토큰 사용)
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        print('✅ FCM 토큰: ${fcmToken?.substring(0, 20)}...');
      } catch (e) {
        fcmToken = 'dummy_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
        print('⚠️ FCM 토큰 가져오기 실패, 더미 토큰 사용: $e');
      }

      // 4. 파티 생성 (id는 Supabase가 자동 생성)
      final newParty = party.copyWith(
        id: '', // Supabase가 UUID 자동 생성
        creatorId: userId,
        members: [], // members는 별도로 저장
      );

      // 5. 네트워크 확인
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
      }

      // 6. Supabase에 파티 저장
      final savedParty = await remoteDataSource.createParty(newParty);
      print('✅ 파티 생성 완료: ${savedParty.name}, ID: ${savedParty.id}');

      // 7. 생성자를 첫 번째 멤버로 추가
      // 직업 ID → 직업 이름 변환
      String? jobName;
      final profileJobId = profile.jobId;
      print('🔍 profile.jobId: $profileJobId');

      if (profileJobId != null) {
        final jobs = await LocalStorageService.getJobs();
        print('🔍 로컬 직업 수: ${jobs?.length}');
        if (jobs != null && jobs.isNotEmpty) {
          try {
            final job = jobs.firstWhere((j) => j.id == profileJobId);
            jobName = job.name;
            print('✅ 직업 매칭 성공: ID=$profileJobId, Name=$jobName');
          } catch (e) {
            print('⚠️ 직업 ID 매칭 실패: $profileJobId, 첫 번째 직업 사용');
            jobName = jobs.first.name;
          }
        }
      }

      final creatorMember = PartyMemberEntity(
        id: '', // Supabase가 UUID 자동 생성
        partyId: savedParty.id, // 생성된 파티 ID 사용
        userId: userId,
        nickname: profile.nickname,
        jobId: profile.jobId, // 직업 ID (예: "varechar")
        job: jobName, // 직업 이름 (예: "바처")
        power: profile.power,
        fcmToken: fcmToken,
        joinedAt: DateTime.now(),
      );
      print('🔍 멤버 생성: jobId=${profile.jobId}, job=$jobName');

      // 8. 멤버 저장
      final joinedMember =
          await remoteDataSource.joinParty(savedParty.id, creatorMember);
      print('✅ 생성자 멤버 추가 완료: ${joinedMember.nickname}');

      // 9. 멤버가 포함된 완전한 파티 반환
      final finalParty = savedParty.copyWith(members: [joinedMember]);
      return Right(finalParty);
    } on ServerException catch (e) {
      print('❌ 파티 생성 ServerException: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      print('❌ 파티 생성 에러: $e');
      print('❌ Stack trace: $stackTrace');
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
      var profile = await ProfileService.getMainProfile();
      if (profile == null) {
        // 메인 프로필이 없으면 프로필 리스트에서 첫 번째 가져오기
        final profiles = await ProfileService.getProfileList();
        if (profiles.isEmpty) {
          return const Left(ServerFailure(message: '프로필을 먼저 설정해주세요'));
        }
        // 첫 번째 프로필을 메인으로 설정
        await ProfileService.setMainProfile(profiles.first.id);
        profile = profiles.first;
        print('✅ 첫 번째 프로필을 메인으로 설정: ${profile.nickname}');
      }

      // 3. FCM 토큰 가져오기 (실패 시 더미 토큰 사용)
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        print('✅ FCM 토큰: ${fcmToken?.substring(0, 20)}...');
      } catch (e) {
        fcmToken = 'dummy_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
        print('⚠️ FCM 토큰 가져오기 실패, 더미 토큰 사용: $e');
      }

      // 4. 직업 ID → 직업 이름 변환
      String? jobName;
      final profileJobId = profile.jobId;
      if (profileJobId != null) {
        final jobs = await LocalStorageService.getJobs();
        if (jobs != null && jobs.isNotEmpty) {
          try {
            final job = jobs.firstWhere((j) => j.id == profileJobId);
            jobName = job.name;
          } catch (e) {
            jobName = jobs.first.name;
          }
        }
      }

      // 5. 멤버 정보 업데이트
      final updatedMember = member.copyWith(
        userId: userId,
        nickname: profile.nickname,
        jobId: profile.jobId, // 직업 ID (예: "varechar")
        job: jobName, // 직업 이름 (예: "바처")
        power: profile.power,
        fcmToken: fcmToken,
        joinedAt: DateTime.now(),
      );

      // 6. Supabase에 저장
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
      }

      final joinedMember =
          await remoteDataSource.joinParty(partyId, updatedMember);
      print('✅ 파티 참가 완료: ${joinedMember.nickname}');
      return Right(joinedMember);
    } catch (e) {
      print('❌ 파티 참가 에러: $e');
      return Left(ServerFailure(message: '파티 참가에 실패했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveParty(
      String partyId, String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
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
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }

    try {
      // 1. 파티 정보 조회 (파티명, 멤버 FCM 토큰)
      final party = await remoteDataSource.getPartyById(partyId);
      if (party == null) {
        return const Left(ServerFailure(message: '파티를 찾을 수 없습니다'));
      }

      // 2. 멤버들의 FCM 토큰 조회 (생성자 제외)
      final fcmTokens = await remoteDataSource.getPartyMemberFcmTokens(partyId);
      final memberTokens =
          fcmTokens.where((token) => token.isNotEmpty).toList();

      // 3. 파티 삭제 (Webhook이 자동으로 FCM 전송)
      await remoteDataSource.deleteParty(partyId, userId);
      print('✅ 파티 삭제 완료: ${party.name}');
      print('📩 Webhook이 ${memberTokens.length}명에게 FCM 푸시 전송 예정');

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
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }

    try {
      // 1. 멤버들의 FCM 토큰 조회 (생성자 제외)
      final fcmTokens =
          await remoteDataSource.getPartyMemberFcmTokens(party.id);
      final memberTokens =
          fcmTokens.where((token) => token.isNotEmpty).toList();

      // 2. 파티 정보 업데이트 (Webhook이 자동으로 FCM 전송)
      final updatedParty = await remoteDataSource.updateParty(party);
      print('✅ 파티 업데이트 완료: ${updatedParty.name}');
      print('📩 Webhook이 ${memberTokens.length}명에게 FCM 푸시 전송 예정');

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
  Future<Either<Failure, void>> kickMember(
      String partyId, String memberId, String creatorId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }

    try {
      // 1. 파티 조회
      final party = await remoteDataSource.getPartyById(partyId);
      if (party == null) {
        return const Left(ServerFailure(message: '파티를 찾을 수 없습니다'));
      }

      // 2. 강퇴할 멤버 찾기
      final kickedMember = party.members.firstWhere((m) => m.id == memberId);

      // 3. 멤버 강퇴 (Webhook이 자동으로 FCM 전송)
      await remoteDataSource.kickMember(partyId, memberId, creatorId);
      print('✅ 멤버 강퇴 완료: ${kickedMember.nickname}');
      if (kickedMember.fcmToken != null && kickedMember.fcmToken!.isNotEmpty) {
        print('📩 Webhook이 강퇴된 멤버에게 FCM 푸시 전송 예정');
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '멤버 강퇴에 실패했습니다: $e'));
    }
  } // ========================================
  // FCM 푸시는 Supabase Database Webhooks에서 자동 처리
  // ========================================
  // - parties 테이블 UPDATE/DELETE → fcm-send Edge Function 호출
  // - party_members 테이블 DELETE → fcm-send Edge Function 호출
  // - data_versions 테이블 UPDATE → send-fcm-push Edge Function 호출

  @override
  Future<Either<Failure, List<PartyEntity>>> getMyParties() async {
    try {
      // 1. userId 확인 (로컬에서)
      final userId = await authService.getUserId();
      if (userId == null) {
        // userId가 없으면 빈 목록 반환 (파티 생성/참가 전)
        print('⚠️ userId 없음, 빈 파티 목록 반환');
        return const Right([]);
      }

      // 2. 네트워크 확인
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
      }

      // 3. Supabase에서 내가 생성한 파티 조회
      final parties = await remoteDataSource.getMyParties(userId);
      print('✅ 내 파티 목록 조회 완료: ${parties.length}개');
      return Right(parties);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('❌ 내 파티 목록 조회 에러: $e');
      return Left(ServerFailure(message: '내 파티 목록을 불러올 수 없습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PartyEntity>>> getJoinedParties() async {
    try {
      // 1. userId 확인 (로컬에서)
      final userId = await authService.getUserId();
      if (userId == null) {
        // userId가 없으면 빈 목록 반환 (파티 생성/참가 전)
        print('⚠️ userId 없음, 빈 파티 목록 반환');
        return const Right([]);
      }

      // 2. 네트워크 확인
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
      }

      // 3. Supabase에서 참가한 파티 조회
      final parties = await remoteDataSource.getJoinedParties(userId);
      print('✅ 참가한 파티 목록 조회 완료: ${parties.length}개');
      return Right(parties);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('❌ 참가한 파티 목록 조회 에러: $e');
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
