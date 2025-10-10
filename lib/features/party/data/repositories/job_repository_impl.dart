import 'package:dartz/dartz.dart';
import 'package:mobi_party_link/core/error/exceptions.dart';
import 'package:mobi_party_link/core/error/failures.dart';
import 'package:mobi_party_link/core/network/network_info.dart';
import 'package:mobi_party_link/features/party/data/datasources/job_remote_datasource.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_category_entity.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_entity.dart';
import 'package:mobi_party_link/features/party/domain/repositories/job_repository.dart';

class JobRepositoryImpl implements JobRepository {

  JobRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final JobRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<JobCategoryEntity>>> getJobCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final jobCategories = await remoteDataSource.getJobCategories();
        return Right(jobCategories);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }
  }

  @override
  Future<Either<Failure, List<JobEntity>>> getJobs() async {
    if (await networkInfo.isConnected) {
      try {
        final jobs = await remoteDataSource.getJobs();
        return Right(jobs);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }
  }

  @override
  Future<Either<Failure, List<JobEntity>>> getJobsByCategory(
      String categoryId) async {
    if (await networkInfo.isConnected) {
      try {
        final jobs = await remoteDataSource.getJobsByCategory(categoryId);
        return Right(jobs);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> getJobById(String jobId) async {
    if (await networkInfo.isConnected) {
      try {
        final job = await remoteDataSource.getJobById(jobId);
        return Right(job);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<JobEntity>>>>
      getJobsGroupedByCategory() async {
    if (await networkInfo.isConnected) {
      try {
        final jobs = await remoteDataSource.getJobs();
        final Map<String, List<JobEntity>> groupedJobs = {};

        for (final job in jobs) {
          groupedJobs.putIfAbsent(job.categoryId, () => []).add(job);
        }

        return Right(groupedJobs);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }
  }

  @override
  Future<Either<Failure, int>> getJobsVersion() async {
    if (await networkInfo.isConnected) {
      try {
        final version = await remoteDataSource.getJobsVersion();
        return Right(version);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }
  }
}
