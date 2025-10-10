import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_entity.dart';

/// 직업 아이콘 로컬 캐싱 서비스
/// PNG 아이콘을 다운로드하고 로컬 파일로 저장/관리합니다.
class JobIconService {
  static const String _iconDirName = 'job_icons';
  static final Dio _dio = Dio();

  /// 아이콘 저장 디렉토리 경로 가져오기
  static Future<Directory> _getIconDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final iconDir = Directory('${appDir.path}/$_iconDirName');

    // 디렉토리가 없으면 생성
    if (!await iconDir.exists()) {
      await iconDir.create(recursive: true);
      print('📁 아이콘 디렉토리 생성: ${iconDir.path}');
    }

    return iconDir;
  }

  /// 로컬 아이콘 파일 경로 반환
  static Future<String?> getLocalIconPath(String jobId) async {
    try {
      final iconDir = await _getIconDirectory();
      final file = File('${iconDir.path}/$jobId.png');

      if (await file.exists()) {
        print('✅ 로컬 PNG 아이콘 찾음: $jobId.png');
        return file.path;
      }
      return null;
    } catch (e) {
      print('❌ 로컬 아이콘 경로 조회 실패: $e');
      return null;
    }
  }

  /// 아이콘 파일 존재 여부 확인
  static Future<bool> hasLocalIcon(String jobId) async {
    final path = await getLocalIconPath(jobId);
    return path != null;
  }

  /// PNG 아이콘 다운로드 및 저장
  static Future<bool> downloadAndSaveIcon(String jobId, String iconUrl) async {
    try {
      // 이미 로컬에 있으면 스킵
      if (await hasLocalIcon(jobId)) {
        print('✅ 아이콘 이미 존재: $jobId');
        return true;
      }

      print('⬇️ 아이콘 다운로드 중: $jobId');

      // PNG 파일 다운로드
      final response = await _dio.get(
        iconUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final iconDir = await _getIconDirectory();
        final file = File('${iconDir.path}/$jobId.png');

        // 파일 저장
        await file.writeAsBytes(response.data);
        print('✅ 아이콘 저장 완료: $jobId (${response.data.length} bytes)');
        return true;
      } else {
        print('❌ 아이콘 다운로드 실패: $jobId (HTTP ${response.statusCode})');
        return false;
      }
    } catch (e) {
      print('❌ 아이콘 다운로드 중 오류: $jobId - $e');
      return false;
    }
  }

  /// 모든 직업 아이콘 다운로드
  static Future<int> downloadAllIcons(List<JobEntity> jobs) async {
    print('🎨 직업 아이콘 다운로드 시작 (총 ${jobs.length}개)');
    int successCount = 0;
    int skipCount = 0;
    int failCount = 0;

    for (final job in jobs) {
      // iconUrl이 없으면 스킵
      if (job.iconUrl == null || job.iconUrl!.isEmpty) {
        print('⚠️ iconUrl 없음: ${job.id}');
        skipCount++;
        continue;
      }

      // 이미 로컬에 있으면 스킵
      if (await hasLocalIcon(job.id)) {
        skipCount++;
        continue;
      }

      // 다운로드 시도
      final success = await downloadAndSaveIcon(job.id, job.iconUrl!);
      if (success) {
        successCount++;
      } else {
        failCount++;
      }

      // 네트워크 부하 방지를 위한 짧은 딜레이
      await Future.delayed(const Duration(milliseconds: 100));
    }

    print('🎉 아이콘 다운로드 완료: 성공 $successCount, 스킵 $skipCount, 실패 $failCount');
    return successCount;
  }

  /// 특정 아이콘 삭제
  static Future<bool> deleteIcon(String jobId) async {
    try {
      final iconDir = await _getIconDirectory();
      final file = File('${iconDir.path}/$jobId.png');

      if (await file.exists()) {
        await file.delete();
        print('🗑️ 아이콘 삭제 완료: $jobId');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 아이콘 삭제 실패: $jobId - $e');
      return false;
    }
  }

  /// 모든 아이콘 캐시 삭제
  static Future<void> clearIconCache() async {
    try {
      final iconDir = await _getIconDirectory();

      if (await iconDir.exists()) {
        await iconDir.delete(recursive: true);
        print('🗑️ 아이콘 캐시 전체 삭제 완료');
      }
    } catch (e) {
      print('❌ 아이콘 캐시 삭제 실패: $e');
    }
  }

  /// 캐시 상태 확인 (디버깅용)
  static Future<Map<String, dynamic>> getCacheStatus() async {
    try {
      final iconDir = await _getIconDirectory();

      if (!await iconDir.exists()) {
        return {
          'exists': false,
          'count': 0,
          'totalSize': 0,
        };
      }

      final files = await iconDir
          .list()
          .where((item) => item is File && item.path.endsWith('.png'))
          .toList();

      int totalSize = 0;
      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      return {
        'exists': true,
        'count': files.length,
        'totalSize': totalSize,
        'path': iconDir.path,
      };
    } catch (e) {
      print('❌ 캐시 상태 확인 실패: $e');
      return {
        'exists': false,
        'count': 0,
        'totalSize': 0,
        'error': e.toString(),
      };
    }
  }
}
