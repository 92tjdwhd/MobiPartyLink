import 'package:dartz/dartz.dart';
import 'package:mobi_party_link/core/error/failures.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_entity.dart';
import 'package:mobi_party_link/features/party/domain/repositories/job_repository.dart';

class GetJobById {

  GetJobById({required this.jobRepository});
  final JobRepository jobRepository;

  Future<Either<Failure, JobEntity>> call(String jobId) async {
    return jobRepository.getJobById(jobId);
  }
}
