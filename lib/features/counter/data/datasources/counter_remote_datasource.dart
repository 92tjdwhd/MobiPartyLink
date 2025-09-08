import 'package:dio/dio.dart';

import '../models/counter_model.dart';

abstract class CounterRemoteDataSource {
  Future<CounterModel> getCounter();
  Future<CounterModel> incrementCounter();
  Future<CounterModel> decrementCounter();
  Future<CounterModel> resetCounter();
  Future<CounterModel> setCounter(int value);
}

class CounterRemoteDataSourceImpl implements CounterRemoteDataSource {
  final Dio dio;

  CounterRemoteDataSourceImpl({required this.dio});

  @override
  Future<CounterModel> getCounter() async {
    // 실제 API 호출 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));
    return const CounterModel(
      value: 0,
      lastUpdated: null,
    );
  }

  @override
  Future<CounterModel> incrementCounter() async {
    // 실제 API 호출 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));
    return const CounterModel(
      value: 1,
      lastUpdated: null,
    );
  }

  @override
  Future<CounterModel> decrementCounter() async {
    // 실제 API 호출 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));
    return const CounterModel(
      value: -1,
      lastUpdated: null,
    );
  }

  @override
  Future<CounterModel> resetCounter() async {
    // 실제 API 호출 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));
    return const CounterModel(
      value: 0,
      lastUpdated: null,
    );
  }

  @override
  Future<CounterModel> setCounter(int value) async {
    // 실제 API 호출 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));
    return CounterModel(
      value: value,
      lastUpdated: null,
    );
  }
}
