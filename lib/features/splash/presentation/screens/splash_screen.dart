import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mobi_party_link/core/services/data_sync_service.dart';
import 'package:mobi_party_link/core/di/injection.dart';

/// 스플래시 화면
///
/// 앱 시작 시 데이터 동기화를 수행하고 메인 화면으로 이동합니다.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _statusText = '초기화 중...';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// 앱 초기화 및 데이터 동기화
  Future<void> _initialize() async {
    try {
      final dataSyncService = DataSyncService(
        jobRepository: ref.read(jobRepositoryProvider),
        templateRepository: ref.read(partyTemplateRepositoryProvider),
      );

      // 1. 직업 데이터 동기화
      if (mounted) {
        setState(() => _statusText = '직업 데이터 동기화 중...');
      }

      await dataSyncService.forceSyncJobs().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏱️ 직업 데이터 동기화 타임아웃');
          return false;
        },
      );

      // 2. 템플릿 데이터 동기화
      if (mounted) {
        setState(() => _statusText = '템플릿 데이터 동기화 중...');
      }

      await dataSyncService.forceSyncTemplates().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏱️ 템플릿 데이터 동기화 타임아웃');
          return false;
        },
      );

      // 3. 완료 - 부드러운 전환을 위한 짧은 딜레이
      if (mounted) {
        setState(() => _statusText = '완료!');
      }
      await Future.delayed(const Duration(milliseconds: 500));

      // 4. 메인 화면으로 이동
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      print('❌ 스플래시 초기화 실패: $e');

      // 실패해도 메인으로 이동 (캐시 데이터 사용)
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. 상단: "모비링크" 타이틀
            Text(
              '모비링크',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 60),

            // 2. 중앙: 모닥불 애니메이션
            Lottie.asset(
              'assets/animations/camfire.json',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // 애니메이션 로드 실패 시 대체 아이콘
                return Icon(
                  Icons.local_fire_department,
                  size: 180,
                  color: Colors.orange[700],
                );
              },
            ),
            const SizedBox(height: 60),

            // 3. 하단: 진행 상태 텍스트
            Text(
              _statusText,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
