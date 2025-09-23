import 'package:dartz/dartz.dart';
import 'package:mobi_party_link/core/error/failures.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_entity.dart';
import 'package:mobi_party_link/features/party/domain/repositories/job_repository.dart';

class GetJobById {
  final JobRepository jobRepository;

  GetJobById({required this.jobRepository});

  Future<Either<Failure, JobEntity>> call(String jobId) async {
    return await jobRepository.getJobById(jobId);
  }
}
