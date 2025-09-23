import 'package:dartz/dartz.dart';
import 'package:mobi_party_link/core/error/failures.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_entity.dart';
import 'package:mobi_party_link/features/party/domain/repositories/job_repository.dart';

class GetJobsByCategory {
  final JobRepository jobRepository;

  GetJobsByCategory({required this.jobRepository});

  Future<Either<Failure, List<JobEntity>>> call(String categoryId) async {
    return await jobRepository.getJobsByCategory(categoryId);
  }
}
