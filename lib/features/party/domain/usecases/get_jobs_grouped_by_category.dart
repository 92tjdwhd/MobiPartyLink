import 'package:dartz/dartz.dart';
import 'package:mobi_party_link/core/error/failures.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_entity.dart';
import 'package:mobi_party_link/features/party/domain/repositories/job_repository.dart';

class GetJobsGroupedByCategory {
  final JobRepository jobRepository;

  GetJobsGroupedByCategory({required this.jobRepository});

  Future<Either<Failure, Map<String, List<JobEntity>>>> call() async {
    return await jobRepository.getJobsGroupedByCategory();
  }
}
