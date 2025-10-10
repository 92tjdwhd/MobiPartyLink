import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SignOut {

  SignOut(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, void>> call() async {
    return repository.signOut();
  }
}
