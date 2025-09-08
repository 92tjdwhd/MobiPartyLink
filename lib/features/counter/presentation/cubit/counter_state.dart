part of 'counter_cubit.dart';

class CounterState {
  final int count;

  const CounterState({required this.count});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CounterState && other.count == count;
  }

  @override
  int get hashCode => count.hashCode;

  @override
  String toString() => 'CounterState(count: $count)';
}
