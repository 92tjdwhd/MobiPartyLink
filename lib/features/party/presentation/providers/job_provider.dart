import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_category_entity.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_entity.dart';
import 'package:mobi_party_link/features/party/domain/usecases/get_job_categories.dart';
import 'package:mobi_party_link/features/party/domain/usecases/get_jobs.dart';
import 'package:mobi_party_link/features/party/domain/usecases/get_jobs_by_category.dart';
import 'package:mobi_party_link/features/party/domain/usecases/get_job_by_id.dart';
import 'package:mobi_party_link/features/party/domain/usecases/get_jobs_grouped_by_category.dart';

part 'job_provider.g.dart';

@riverpod
class JobNotifier extends _$JobNotifier {
  @override
  Future<List<JobCategoryEntity>> build() async {
    final result = await ref.read(getJobCategoriesProvider.future);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (jobCategories) => jobCategories,
    );
  }

  /// 모든 직업 카테고리를 가져옵니다
  Future<List<JobCategoryEntity>> getJobCategories() async {
    state = const AsyncValue.loading();
    final result = await ref.read(getJobCategoriesProvider.future);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (jobCategories) => jobCategories,
    );
  }

  /// 모든 직업을 가져옵니다
  Future<List<JobEntity>> getJobs() async {
    final result = await ref.read(getJobsProvider.future);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (jobs) => jobs,
    );
  }

  /// 특정 카테고리의 직업들을 가져옵니다
  Future<List<JobEntity>> getJobsByCategory(String categoryId) async {
    final result = await ref.read(getJobsByCategoryProvider(categoryId).future);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (jobs) => jobs,
    );
  }

  /// 특정 직업을 가져옵니다
  Future<JobEntity> getJobById(String jobId) async {
    final result = await ref.read(getJobByIdProvider(jobId).future);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (job) => job,
    );
  }

  /// 직업 카테고리별로 그룹화된 직업들을 가져옵니다
  Future<Map<String, List<JobEntity>>> getJobsGroupedByCategory() async {
    final result = await ref.read(getJobsGroupedByCategoryProvider.future);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (groupedJobs) => groupedJobs,
    );
  }
}

// Provider들
@riverpod
Future<List<JobCategoryEntity>> getJobCategoriesProvider(
    GetJobCategoriesProviderRef ref) async {
  final getJobCategories = ref.watch(getJobCategoriesUseCaseProvider);
  final result = await getJobCategories();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (jobCategories) => jobCategories,
  );
}

@riverpod
Future<List<JobEntity>> getJobsProvider(GetJobsProviderRef ref) async {
  final getJobs = ref.watch(getJobsUseCaseProvider);
  final result = await getJobs();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (jobs) => jobs,
  );
}

@riverpod
Future<List<JobEntity>> getJobsByCategoryProvider(
    GetJobsByCategoryProviderRef ref, String categoryId) async {
  final getJobsByCategory = ref.watch(getJobsByCategoryUseCaseProvider);
  final result = await getJobsByCategory(categoryId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (jobs) => jobs,
  );
}

@riverpod
Future<JobEntity> getJobByIdProvider(
    GetJobByIdProviderRef ref, String jobId) async {
  final getJobById = ref.watch(getJobByIdUseCaseProvider);
  final result = await getJobById(jobId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (job) => job,
  );
}

@riverpod
Future<Map<String, List<JobEntity>>> getJobsGroupedByCategoryProvider(
    GetJobsGroupedByCategoryProviderRef ref) async {
  final getJobsGroupedByCategory =
      ref.watch(getJobsGroupedByCategoryUseCaseProvider);
  final result = await getJobsGroupedByCategory();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (groupedJobs) => groupedJobs,
  );
}

// UseCase Provider들
@riverpod
GetJobCategories getJobCategoriesUseCaseProvider(
    GetJobCategoriesUseCaseProviderRef ref) {
  return GetJobCategories(jobRepository: ref.watch(jobRepositoryProvider));
}

@riverpod
GetJobs getJobsUseCaseProvider(GetJobsUseCaseProviderRef ref) {
  return GetJobs(jobRepository: ref.watch(jobRepositoryProvider));
}

@riverpod
GetJobsByCategory getJobsByCategoryUseCaseProvider(
    GetJobsByCategoryUseCaseProviderRef ref) {
  return GetJobsByCategory(jobRepository: ref.watch(jobRepositoryProvider));
}

@riverpod
GetJobById getJobByIdUseCaseProvider(GetJobByIdUseCaseProviderRef ref) {
  return GetJobById(jobRepository: ref.watch(jobRepositoryProvider));
}

@riverpod
GetJobsGroupedByCategory getJobsGroupedByCategoryUseCaseProvider(
    GetJobsGroupedByCategoryUseCaseProviderRef ref) {
  return GetJobsGroupedByCategory(
      jobRepository: ref.watch(jobRepositoryProvider));
}
