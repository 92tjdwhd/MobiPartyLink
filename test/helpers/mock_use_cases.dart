import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:mobi_party_link/features/counter/domain/entities/counter_entity.dart';
import 'package:mobi_party_link/features/counter/domain/usecases/get_counter.dart';
import 'package:mobi_party_link/features/counter/domain/usecases/increment_counter.dart';
import 'package:mobi_party_link/features/counter/domain/usecases/decrement_counter.dart';
import 'package:mobi_party_link/features/counter/domain/usecases/reset_counter.dart';
import 'package:mobi_party_link/core/error/failures.dart';

class MockGetCounter extends Mock implements GetCounter {}
class MockIncrementCounter extends Mock implements IncrementCounter {}
class MockDecrementCounter extends Mock implements DecrementCounter {}
class MockResetCounter extends Mock implements ResetCounter {}
