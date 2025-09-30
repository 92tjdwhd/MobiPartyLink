import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_entity.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_template_entity.dart';
import 'package:mobi_party_link/features/party/data/models/job_model.dart';
import 'package:mobi_party_link/features/party/data/models/party_template_model.dart';

/// 로컬 저장소 서비스
/// 직업, 파티 템플릿 등의 정적 데이터를 로컬에 저장하고 관리합니다.
class LocalStorageService {
  static const String _jobsKey = 'cached_jobs';
  static const String _jobCategoriesKey = 'cached_job_categories';
  static const String _partyTemplatesKey = 'cached_party_templates';
  static const String _jobsVersionKey = 'jobs_version';
  static const String _templatesVersionKey = 'templates_version';
  static const String _jobsLastUpdatedKey = 'jobs_last_updated';
  static const String _templatesLastUpdatedKey = 'templates_last_updated';

  /// 직업 데이터 저장
  static Future<void> saveJobs(List<JobEntity> jobs) async {
    final prefs = await SharedPreferences.getInstance();
    final jobModels = jobs.map((job) => JobModel.fromEntity(job)).toList();
    final jsonList = jobModels.map((job) => job.toJson()).toList();
    await prefs.setString(_jobsKey, jsonEncode(jsonList));
    await prefs.setString(
      _jobsLastUpdatedKey,
      DateTime.now().toIso8601String(),
    );
    print('✅ 직업 데이터 ${jobs.length}개 로컬 저장 완료');
  }

  /// 직업 데이터 불러오기
  static Future<List<JobEntity>?> getJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_jobsKey);
      if (jsonString == null) return null;

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final jobs = jsonList
          .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();

      print('📖 로컬에서 직업 데이터 ${jobs.length}개 불러옴');
      return jobs;
    } catch (e) {
      print('❌ 직업 데이터 불러오기 실패: $e');
      return null;
    }
  }

  /// 파티 템플릿 데이터 저장
  static Future<void> savePartyTemplates(
      List<PartyTemplateEntity> templates) async {
    final prefs = await SharedPreferences.getInstance();
    final templateModels =
        templates.map((t) => PartyTemplateModel.fromEntity(t)).toList();
    final jsonList = templateModels.map((t) => t.toJson()).toList();
    await prefs.setString(_partyTemplatesKey, jsonEncode(jsonList));
    await prefs.setString(
      _templatesLastUpdatedKey,
      DateTime.now().toIso8601String(),
    );
    print('✅ 파티 템플릿 데이터 ${templates.length}개 로컬 저장 완료');
  }

  /// 파티 템플릿 데이터 불러오기
  static Future<List<PartyTemplateEntity>?> getPartyTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_partyTemplatesKey);
      if (jsonString == null) return null;

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final templates = jsonList
          .map((json) =>
              PartyTemplateModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();

      print('📖 로컬에서 파티 템플릿 ${templates.length}개 불러옴');
      return templates;
    } catch (e) {
      print('❌ 파티 템플릿 불러오기 실패: $e');
      return null;
    }
  }

  /// 직업 버전 저장
  static Future<void> saveJobsVersion(int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_jobsVersionKey, version);
    print('✅ 직업 버전 $version 저장 완료');
  }

  /// 직업 버전 불러오기
  static Future<int> getJobsVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_jobsVersionKey) ?? 0;
  }

  /// 템플릿 버전 저장
  static Future<void> saveTemplatesVersion(int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_templatesVersionKey, version);
    print('✅ 템플릿 버전 $version 저장 완료');
  }

  /// 템플릿 버전 불러오기
  static Future<int> getTemplatesVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_templatesVersionKey) ?? 0;
  }

  /// 마지막 업데이트 시간 확인
  static Future<DateTime?> getJobsLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_jobsLastUpdatedKey);
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  /// 마지막 업데이트 시간 확인
  static Future<DateTime?> getTemplatesLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_templatesLastUpdatedKey);
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  /// 모든 캐시 데이터 삭제
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jobsKey);
    await prefs.remove(_jobCategoriesKey);
    await prefs.remove(_partyTemplatesKey);
    await prefs.remove(_jobsVersionKey);
    await prefs.remove(_templatesVersionKey);
    await prefs.remove(_jobsLastUpdatedKey);
    await prefs.remove(_templatesLastUpdatedKey);
    print('🗑️ 모든 캐시 데이터 삭제 완료');
  }

  /// 캐시 상태 확인
  static Future<Map<String, dynamic>> getCacheStatus() async {
    final jobsVersion = await getJobsVersion();
    final templatesVersion = await getTemplatesVersion();
    final jobsLastUpdated = await getJobsLastUpdated();
    final templatesLastUpdated = await getTemplatesLastUpdated();
    final jobs = await getJobs();
    final templates = await getPartyTemplates();

    return {
      'jobs': {
        'version': jobsVersion,
        'count': jobs?.length ?? 0,
        'lastUpdated': jobsLastUpdated?.toIso8601String(),
        'hasData': jobs != null && jobs.isNotEmpty,
      },
      'templates': {
        'version': templatesVersion,
        'count': templates?.length ?? 0,
        'lastUpdated': templatesLastUpdated?.toIso8601String(),
        'hasData': templates != null && templates.isNotEmpty,
      },
    };
  }
}
