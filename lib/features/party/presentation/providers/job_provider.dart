import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/core/services/local_storage_service.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_entity.dart';

/// 로컬에 저장된 직업 목록을 제공하는 Provider
final localJobsProvider = FutureProvider<List<JobEntity>>((ref) async {
  // 로컬 저장소에서 직업 목록 가져오기
  final jobs = await LocalStorageService.getJobs();

  if (jobs == null || jobs.isEmpty) {
    print('⚠️ 로컬에 저장된 직업이 없습니다. 동기화가 필요합니다.');
    return [];
  }

  return jobs;
});

/// 직업 이름 목록 Provider (UI에서 사용)
final jobNamesProvider = FutureProvider<List<String>>((ref) async {
  final jobs = await ref.watch(localJobsProvider.future);
  return jobs.map((job) => job.name).toList();
});

/// 직업 ID로 이름 찾기
final jobIdToNameProvider =
    FutureProvider.family<String?, String>((ref, jobId) async {
  final jobs = await ref.watch(localJobsProvider.future);
  try {
    return jobs.firstWhere((job) => job.id == jobId).name;
  } catch (e) {
    return null;
  }
});

/// 직업 이름으로 ID 찾기
final jobNameToIdProvider =
    FutureProvider.family<String?, String>((ref, jobName) async {
  final jobs = await ref.watch(localJobsProvider.future);
  try {
    return jobs.firstWhere((job) => job.name == jobName).id;
  } catch (e) {
    return null;
  }
});

/// 직업 ID로 아이콘 URL 찾기
final jobIdToIconUrlProvider =
    FutureProvider.family<String?, String>((ref, jobId) async {
  final jobs = await ref.watch(localJobsProvider.future);
  try {
    return jobs.firstWhere((job) => job.id == jobId).iconUrl;
  } catch (e) {
    return null;
  }
});
