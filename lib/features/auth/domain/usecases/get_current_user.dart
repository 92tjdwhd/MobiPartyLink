import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {

  GetCurrentUser(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, AuthUserEntity?>> call() async {
    return repository.getCurrentUser();
  }
}
