import 'package:dartz/dartz.dart';
import 'package:mobi_party_link/core/error/failures.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_category_entity.dart';
import 'package:mobi_party_link/features/party/domain/repositories/job_repository.dart';

class GetJobCategories {
  final JobRepository jobRepository;

  GetJobCategories({required this.jobRepository});

  Future<Either<Failure, List<JobCategoryEntity>>> call() async {
    return await jobRepository.getJobCategories();
  }
}
