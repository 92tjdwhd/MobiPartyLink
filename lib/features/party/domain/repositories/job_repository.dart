import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/job_category_entity.dart';
import '../entities/job_entity.dart';

abstract class JobRepository {
  /// 모든 직업 카테고리를 가져옵니다
  Future<Either<Failure, List<JobCategoryEntity>>> getJobCategories();

  /// 모든 활성 직업을 가져옵니다
  Future<Either<Failure, List<JobEntity>>> getJobs();

  /// 특정 카테고리의 직업들을 가져옵니다
  Future<Either<Failure, List<JobEntity>>> getJobsByCategory(String categoryId);

  /// 특정 직업을 가져옵니다
  Future<Either<Failure, JobEntity>> getJobById(String jobId);

  /// 직업 카테고리별로 그룹화된 직업들을 가져옵니다
  Future<Either<Failure, Map<String, List<JobEntity>>>>
      getJobsGroupedByCategory();
}
