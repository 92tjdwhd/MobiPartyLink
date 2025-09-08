import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../../features/counter/data/datasources/counter_local_datasource.dart';
import '../../features/counter/data/datasources/counter_remote_datasource.dart';
import '../../features/counter/data/repositories/counter_repository_impl.dart';
import '../../features/counter/domain/repositories/counter_repository.dart';
import '../../features/counter/domain/usecases/get_counter.dart';
import '../../features/counter/domain/usecases/increment_counter.dart';
import '../../features/counter/domain/usecases/decrement_counter.dart';
import '../../features/counter/domain/usecases/reset_counter.dart';
import '../../features/counter/presentation/providers/counter_provider.dart';

part 'injection.g.dart';

// Core
@riverpod
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
}

// Network
@riverpod
DioClient dioClient(DioClientRef ref) => DioClient();

@riverpod
NetworkInfo networkInfo(NetworkInfoRef ref) => NetworkInfoImpl();

// Data Sources
@riverpod
CounterLocalDataSource counterLocalDataSource(CounterLocalDataSourceRef ref) =>
    CounterLocalDataSourceImpl(sharedPreferences: ref.watch(sharedPreferencesProvider));

@riverpod
CounterRemoteDataSource counterRemoteDataSource(CounterRemoteDataSourceRef ref) =>
    CounterRemoteDataSourceImpl(ref.watch(dioClientProvider));

// Repository
@riverpod
CounterRepository counterRepository(CounterRepositoryRef ref) =>
    CounterRepositoryImpl(
      localDataSource: ref.watch(counterLocalDataSourceProvider),
      remoteDataSource: ref.watch(counterRemoteDataSourceProvider),
      networkInfo: ref.watch(networkInfoProvider),
    );

// Use Cases
@riverpod
GetCounter getCounter(GetCounterRef ref) =>
    GetCounter(ref.watch(counterRepositoryProvider));

@riverpod
IncrementCounter incrementCounter(IncrementCounterRef ref) =>
    IncrementCounter(ref.watch(counterRepositoryProvider));

@riverpod
DecrementCounter decrementCounter(DecrementCounterRef ref) =>
    DecrementCounter(ref.watch(counterRepositoryProvider));

@riverpod
ResetCounter resetCounter(ResetCounterRef ref) =>
    ResetCounter(ref.watch(counterRepositoryProvider));

// Presentation Layer
@riverpod
CounterNotifier counterNotifier(CounterNotifierRef ref) =>
    CounterNotifier(
      getCounter: ref.watch(getCounterProvider),
      incrementCounter: ref.watch(incrementCounterProvider),
      decrementCounter: ref.watch(decrementCounterProvider),
      resetCounter: ref.watch(resetCounterProvider),
    );
