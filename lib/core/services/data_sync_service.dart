import 'package:mobi_party_link/features/party/domain/repositories/job_repository.dart';
import 'package:mobi_party_link/features/party/domain/repositories/party_template_repository.dart';
import 'package:mobi_party_link/core/services/local_storage_service.dart';
import 'package:mobi_party_link/core/services/fcm_service.dart';
import 'package:mobi_party_link/core/services/job_icon_service.dart';

/// 데이터 동기화 서비스
/// 서버의 직업, 템플릿 데이터를 로컬과 동기화합니다.
class DataSyncService {
  DataSyncService({
    required this.jobRepository,
    this.templateRepository,
  });
  final JobRepository jobRepository;
  final PartyTemplateRepository? templateRepository;

  /// 직업 데이터 동기화
  /// 서버 버전이 로컬 버전보다 높으면 데이터를 다운로드하고 저장합니다.
  Future<bool> syncJobs() async {
    try {
      print('🔄 직업 데이터 동기화 시작...');

      // 1. 로컬 버전 확인
      final localVersion = await LocalStorageService.getJobsVersion();
      print('📱 로컬 직업 버전: $localVersion');

      // 2. 서버 버전 확인
      final serverVersionResult = await jobRepository.getJobsVersion();
      final serverVersion = serverVersionResult.fold(
        (failure) {
          print('❌ 서버 버전 확인 실패: ${failure.message}');
          return localVersion; // 실패 시 로컬 버전 사용
        },
        (version) {
          print('☁️ 서버 직업 버전: $version');
          return version;
        },
      );

      // 3. 버전 비교
      if (serverVersion <= localVersion) {
        print('✅ 직업 데이터가 최신 상태입니다 (v$localVersion)');

        // 로컬 데이터가 있는지 확인
        final localJobs = await LocalStorageService.getJobs();
        if (localJobs == null || localJobs.isEmpty) {
          print('⚠️ 로컬 데이터가 없어서 서버에서 다운로드합니다');
        } else {
          return true; // 이미 최신 데이터가 있음
        }
      }

      // 4. 서버에서 직업 데이터 다운로드
      print('⬇️ 서버에서 직업 데이터 다운로드 중...');
      final jobsResult = await jobRepository.getJobs();

      return await jobsResult.fold(
        (failure) {
          print('❌ 직업 데이터 다운로드 실패: ${failure.message}');
          return false;
        },
        (jobs) async {
          print('✅ 직업 데이터 ${jobs.length}개 다운로드 완료');

          // 5. 로컬에 저장
          await LocalStorageService.saveJobs(jobs);
          await LocalStorageService.saveJobsVersion(serverVersion);

          // 6. 직업 아이콘 다운로드 (백그라운드)
          try {
            print('🎨 직업 아이콘 다운로드 시작...');
            final iconCount = await JobIconService.downloadAllIcons(jobs);
            print('✅ 직업 아이콘 $iconCount개 다운로드 완료');
          } catch (e) {
            print('⚠️ 아이콘 다운로드 실패 (직업 데이터는 정상 저장됨): $e');
            // 아이콘 다운로드 실패해도 직업 데이터 동기화는 성공으로 처리
          }

          print('🎉 직업 데이터 동기화 완료! (v$localVersion → v$serverVersion)');
          return true;
        },
      );
    } catch (e) {
      print('❌ 직업 데이터 동기화 중 오류: $e');
      return false;
    }
  }

  /// 파티 템플릿 데이터 동기화
  Future<bool> syncTemplates() async {
    if (templateRepository == null) {
      print('⚠️ 템플릿 Repository가 설정되지 않았습니다');
      return false;
    }

    try {
      print('🔄 파티 템플릿 동기화 시작...');

      // 1. 로컬 버전 확인
      final localVersion = await LocalStorageService.getTemplatesVersion();
      print('📱 로컬 템플릿 버전: $localVersion');

      // 2. 서버 버전 확인
      final serverVersionResult =
          await templateRepository!.getTemplatesVersion();
      final serverVersion = serverVersionResult.fold(
        (failure) {
          print('❌ 서버 버전 확인 실패: ${failure.message}');
          return localVersion;
        },
        (version) {
          print('☁️ 서버 템플릿 버전: $version');
          return version;
        },
      );

      // 3. 버전 비교
      if (serverVersion <= localVersion) {
        print('✅ 템플릿 데이터가 최신 상태입니다 (v$localVersion)');

        // 로컬 데이터가 있는지 확인
        final localTemplates = await LocalStorageService.getPartyTemplates();
        if (localTemplates == null || localTemplates.isEmpty) {
          print('⚠️ 로컬 데이터가 없어서 서버에서 다운로드합니다');
        } else {
          return true;
        }
      }

      // 4. 서버에서 템플릿 데이터 다운로드
      print('⬇️ 서버에서 템플릿 데이터 다운로드 중...');
      final templatesResult = await templateRepository!.getTemplates();

      return await templatesResult.fold(
        (failure) {
          print('❌ 템플릿 데이터 다운로드 실패: ${failure.message}');
          return false;
        },
        (templates) async {
          print('✅ 템플릿 데이터 ${templates.length}개 다운로드 완료');

          // 5. 로컬에 저장
          await LocalStorageService.savePartyTemplates(templates);
          await LocalStorageService.saveTemplatesVersion(serverVersion);

          print('🎉 템플릿 데이터 동기화 완료! (v$localVersion → v$serverVersion)');
          return true;
        },
      );
    } catch (e) {
      print('❌ 템플릿 데이터 동기화 중 오류: $e');
      return false;
    }
  }

  /// 모든 데이터 동기화
  Future<Map<String, bool>> syncAll() async {
    print('🚀 전체 데이터 동기화 시작...');
    print('=====================================');

    final jobsSynced = await syncJobs();
    print('-------------------------------------');
    final templatesSynced = await syncTemplates();
    print('=====================================');

    final allSynced = jobsSynced && templatesSynced;
    if (allSynced) {
      print('✅ 전체 데이터 동기화 완료!');
    } else {
      print('⚠️ 일부 데이터 동기화 실패');
    }

    // 캐시 상태 출력
    final cacheStatus = await LocalStorageService.getCacheStatus();
    print('\n📊 캐시 상태:');
    print(
        '  직업: ${cacheStatus['jobs']['count']}개 (v${cacheStatus['jobs']['version']})');
    print(
        '  템플릿: ${cacheStatus['templates']['count']}개 (v${cacheStatus['templates']['version']})');

    return {
      'jobs': jobsSynced,
      'templates': templatesSynced,
    };
  }

  /// 강제 동기화 (버전 무시하고 다시 다운로드)
  Future<Map<String, bool>> forceSync() async {
    print('🔄 강제 동기화 시작 (캐시 삭제)...');
    await LocalStorageService.clearAll();
    return syncAll();
  }

  /// FCM 플래그 기반 스마트 동기화 - 직업
  Future<bool> fcmSmartSyncJobs() async {
    try {
      // 1. FCM 플래그 확인 (로컬에서만!)
      final needsUpdate = await FcmService.needsUpdateJobs();

      if (!needsUpdate) {
        print('✅ 직업 업데이트 불필요 (FCM 플래그 없음)');
        return true;
      }

      // 2. 플래그가 있으면 기존 동기화 로직 호출
      print('🔔 FCM 플래그 감지, 직업 동기화 시작...');
      final synced = await syncJobs();

      // 3. 성공하면 플래그 제거
      if (synced) {
        await FcmService.clearUpdateFlag('jobs');
      }

      return synced;
    } catch (e) {
      print('❌ FCM 기반 직업 동기화 실패: $e');
      return false;
    }
  }

  /// FCM 플래그 기반 스마트 동기화 - 템플릿
  Future<bool> fcmSmartSyncTemplates() async {
    try {
      // 1. FCM 플래그 확인 (로컬에서만!)
      final needsUpdate = await FcmService.needsUpdateTemplates();

      if (!needsUpdate) {
        print('✅ 템플릿 업데이트 불필요 (FCM 플래그 없음)');
        return true;
      }

      // 2. 플래그가 있으면 기존 동기화 로직 호출
      print('🔔 FCM 플래그 감지, 템플릿 동기화 시작...');
      final synced = await syncTemplates();

      // 3. 성공하면 플래그 제거
      if (synced) {
        await FcmService.clearUpdateFlag('templates');
      }

      return synced;
    } catch (e) {
      print('❌ FCM 기반 템플릿 동기화 실패: $e');
      return false;
    }
  }

  /// FCM 기반 전체 스마트 동기화
  Future<Map<String, bool>> fcmSmartSyncAll() async {
    print('🚀 FCM 기반 전체 스마트 동기화 시작...');
    print('=====================================');

    final jobsSynced = await fcmSmartSyncJobs();
    print('-------------------------------------');

    final templatesSynced = await fcmSmartSyncTemplates();
    print('=====================================');

    if (jobsSynced && templatesSynced) {
      print('✅ FCM 기반 전체 동기화 완료!');
    } else {
      print('⚠️ 일부 데이터 동기화 실패');
    }

    return {
      'jobs': jobsSynced,
      'templates': templatesSynced,
    };
  }

  /// 강제 직업 동기화 - 스플래시용 (무조건 서버 버전 체크)
  Future<bool> forceSyncJobs() async {
    try {
      print('🔄 강제 직업 데이터 동기화 시작');

      // 1. 로컬 버전 조회
      final localVersion = await LocalStorageService.getJobsVersion();
      print('📦 로컬 직업 버전: $localVersion');

      // 2. 서버 버전 조회
      final serverVersionResult = await jobRepository.getJobsVersion();
      final serverVersion = serverVersionResult.fold(
        (failure) {
          print('⚠️ 서버 버전 조회 실패 - 로컬 데이터 사용');
          return null;
        },
        (version) {
          print('🌐 서버 직업 버전: $version');
          return version;
        },
      );

      if (serverVersion == null) {
        print('⚠️ 서버 연결 실패 - 로컬 데이터로 진행');
        return false;
      }

      // 3. 버전 비교
      if (localVersion == serverVersion) {
        print('✅ 직업 데이터 최신 버전 (동기화 불필요)');
        return true;
      }

      // 4. 버전 다르면 동기화 (syncJobs 호출)
      print('🔽 직업 데이터 다운로드 필요 (v$localVersion → v$serverVersion)');
      return await syncJobs();
    } catch (e) {
      print('❌ 강제 직업 동기화 실패: $e');
      return false;
    }
  }

  /// 강제 템플릿 동기화 - 스플래시용 (무조건 서버 버전 체크)
  Future<bool> forceSyncTemplates() async {
    if (templateRepository == null) {
      print('⚠️ 템플릿 Repository가 설정되지 않았습니다');
      return false;
    }

    try {
      print('🔄 강제 템플릿 데이터 동기화 시작');

      // 1. 로컬 버전 조회
      final localVersion = await LocalStorageService.getTemplatesVersion();
      print('📦 로컬 템플릿 버전: $localVersion');

      // 2. 서버 버전 조회
      final serverVersionResult = await templateRepository!.getTemplatesVersion();
      final serverVersion = serverVersionResult.fold(
        (failure) {
          print('⚠️ 서버 버전 조회 실패 - 로컬 데이터 사용');
          return null;
        },
        (version) {
          print('🌐 서버 템플릿 버전: $version');
          return version;
        },
      );

      if (serverVersion == null) {
        print('⚠️ 서버 연결 실패 - 로컬 데이터로 진행');
        return false;
      }

      // 3. 버전 비교
      if (localVersion == serverVersion) {
        print('✅ 템플릿 데이터 최신 버전 (동기화 불필요)');
        return true;
      }

      // 4. 버전 다르면 동기화 (syncTemplates 호출)
      print('🔽 템플릿 데이터 다운로드 필요 (v$localVersion → v$serverVersion)');
      return await syncTemplates();
    } catch (e) {
      print('❌ 강제 템플릿 동기화 실패: $e');
      return false;
    }
  }
}
