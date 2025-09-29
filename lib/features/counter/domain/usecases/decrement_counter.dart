import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/counter_entity.dart';
import '../repositories/counter_repository.dart';

class DecrementCounter {

  DecrementCounter(this.repository);
  final CounterRepository repository;

  Future<Either<Failure, CounterEntity>> call() async {
    return repository.decrementCounter();
  }
}
