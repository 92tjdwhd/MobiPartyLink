import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, AuthUserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity>> signInAnonymously() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '인터넷 연결을 확인해주세요'));
    }

    try {
      final user = await remoteDataSource.signInAnonymously();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '예상치 못한 오류가 발생했습니다: $e'));
    }
  }

  @override
  Stream<AuthUserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }
}
