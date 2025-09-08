import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/counter_entity.dart';
import '../../domain/repositories/counter_repository.dart';
import '../datasources/counter_local_datasource.dart';
import '../datasources/counter_remote_datasource.dart';
import '../models/counter_model.dart';

class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource localDataSource;
  final CounterRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CounterRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, CounterEntity>> getCounter() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteCounter = await remoteDataSource.getCounter();
        await localDataSource.saveCounter(remoteCounter);
        return Right(remoteCounter.toEntity());
      } else {
        final localCounter = await localDataSource.getCounter();
        return Right(localCounter.toEntity());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, CounterEntity>> incrementCounter() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteCounter = await remoteDataSource.incrementCounter();
        await localDataSource.saveCounter(remoteCounter);
        return Right(remoteCounter.toEntity());
      } else {
        final localCounter = await localDataSource.getCounter();
        final newCounter = CounterModel(
          value: localCounter.value + 1,
          lastUpdated: DateTime.now(),
        );
        await localDataSource.saveCounter(newCounter);
        return Right(newCounter.toEntity());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, CounterEntity>> decrementCounter() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteCounter = await remoteDataSource.decrementCounter();
        await localDataSource.saveCounter(remoteCounter);
        return Right(remoteCounter.toEntity());
      } else {
        final localCounter = await localDataSource.getCounter();
        final newCounter = CounterModel(
          value: localCounter.value - 1,
          lastUpdated: DateTime.now(),
        );
        await localDataSource.saveCounter(newCounter);
        return Right(newCounter.toEntity());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, CounterEntity>> resetCounter() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteCounter = await remoteDataSource.resetCounter();
        await localDataSource.saveCounter(remoteCounter);
        return Right(remoteCounter.toEntity());
      } else {
        final newCounter = CounterModel(
          value: 0,
          lastUpdated: DateTime.now(),
        );
        await localDataSource.saveCounter(newCounter);
        return Right(newCounter.toEntity());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, CounterEntity>> setCounter(int value) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteCounter = await remoteDataSource.setCounter(value);
        await localDataSource.saveCounter(remoteCounter);
        return Right(remoteCounter.toEntity());
      } else {
        final newCounter = CounterModel(
          value: value,
          lastUpdated: DateTime.now(),
        );
        await localDataSource.saveCounter(newCounter);
        return Right(newCounter.toEntity());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }
}
