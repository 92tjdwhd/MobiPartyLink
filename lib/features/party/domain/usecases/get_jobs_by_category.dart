import 'package:dartz/dartz.dart';
import 'package:mobi_party_link/core/error/failures.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_entity.dart';
import 'package:mobi_party_link/features/party/domain/repositories/job_repository.dart';

class GetJobsByCategory {

  GetJobsByCategory({required this.jobRepository});
  final JobRepository jobRepository;

  Future<Either<Failure, List<JobEntity>>> call(String categoryId) async {
    return jobRepository.getJobsByCategory(categoryId);
  }
}
