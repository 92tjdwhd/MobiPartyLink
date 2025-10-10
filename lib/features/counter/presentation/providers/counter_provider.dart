import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/counter_entity.dart';
import '../../domain/usecases/decrement_counter.dart';
import '../../domain/usecases/get_counter.dart';
import '../../domain/usecases/increment_counter.dart';
import '../../domain/usecases/reset_counter.dart';

part 'counter_provider.freezed.dart';

@freezed
class CounterState with _$CounterState {
  const factory CounterState({
    @Default(CounterEntity(value: 0, lastUpdated: null)) CounterEntity counter,
    @Default(false) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
  }) = _CounterState;
}

class CounterNotifier extends StateNotifier<CounterState> {
  CounterNotifier({
    required this.getCounter,
    required this.incrementCounter,
    required this.decrementCounter,
    required this.resetCounter,
  }) : super(const CounterState()) {
    _loadCounter();
  }
  final GetCounter getCounter;
  final IncrementCounter incrementCounter;
  final DecrementCounter decrementCounter;
  final ResetCounter resetCounter;

  Future<void> _loadCounter() async {
    state = state.copyWith(isLoading: true, isError: false);

    final result = await getCounter();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: failure.message,
      ),
      (counter) => state = state.copyWith(
        isLoading: false,
        isError: false,
        counter: counter,
      ),
    );
  }

  Future<void> increment() async {
    state = state.copyWith(isLoading: true, isError: false);

    final result = await incrementCounter();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: failure.message,
      ),
      (counter) => state = state.copyWith(
        isLoading: false,
        isError: false,
        counter: counter,
      ),
    );
  }

  Future<void> decrement() async {
    state = state.copyWith(isLoading: true, isError: false);

    final result = await decrementCounter();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: failure.message,
      ),
      (counter) => state = state.copyWith(
        isLoading: false,
        isError: false,
        counter: counter,
      ),
    );
  }

  Future<void> reset() async {
    state = state.copyWith(isLoading: true, isError: false);

    final result = await resetCounter();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: failure.message,
      ),
      (counter) => state = state.copyWith(
        isLoading: false,
        isError: false,
        counter: counter,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(isError: false, errorMessage: null);
  }
}
