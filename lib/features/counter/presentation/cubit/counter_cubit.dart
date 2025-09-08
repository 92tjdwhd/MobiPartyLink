import 'package:flutter_bloc/flutter_bloc.dart';

part 'counter_state.dart';

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterState(count: 0));

  void increment() {
    emit(CounterState(count: state.count + 1));
  }

  void decrement() {
    if (state.count > 0) {
      emit(CounterState(count: state.count - 1));
    }
  }

  void reset() {
    emit(const CounterState(count: 0));
  }

  void setCount(int count) {
    emit(CounterState(count: count));
  }
}
