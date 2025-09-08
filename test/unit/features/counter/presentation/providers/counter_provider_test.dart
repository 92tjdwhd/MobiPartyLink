import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod_test/riverpod_test.dart';

import 'package:mobi_party_link/features/counter/domain/entities/counter_entity.dart';
import 'package:mobi_party_link/features/counter/domain/usecases/get_counter.dart';
import 'package:mobi_party_link/features/counter/domain/usecases/increment_counter.dart';
import 'package:mobi_party_link/features/counter/domain/usecases/decrement_counter.dart';
import 'package:mobi_party_link/features/counter/domain/usecases/reset_counter.dart';
import 'package:mobi_party_link/features/counter/presentation/providers/counter_provider.dart';
import 'package:mobi_party_link/core/error/failures.dart';

import '../../../../helpers/mock_use_cases.dart';

void main() {
  group('CounterNotifier', () {
    late MockGetCounter mockGetCounter;
    late MockIncrementCounter mockIncrementCounter;
    late MockDecrementCounter mockDecrementCounter;
    late MockResetCounter mockResetCounter;

    setUp(() {
      mockGetCounter = MockGetCounter();
      mockIncrementCounter = MockIncrementCounter();
      mockDecrementCounter = MockDecrementCounter();
      mockResetCounter = MockResetCounter();
    });

    test('초기 상태는 로딩 중이어야 한다', () {
      final container = ProviderContainer(
        overrides: [
          getCounterProvider.overrideWithValue(mockGetCounter),
          incrementCounterProvider.overrideWithValue(mockIncrementCounter),
          decrementCounterProvider.overrideWithValue(mockDecrementCounter),
          resetCounterProvider.overrideWithValue(mockResetCounter),
        ],
      );

      final notifier = container.read(counterNotifierProvider.notifier);
      final state = container.read(counterNotifierProvider);

      expect(state.isLoading, true);
      expect(state.isError, false);
      expect(state.counter.value, 0);

      container.dispose();
    });

    test('카운터 증가가 성공하면 상태가 업데이트되어야 한다', () async {
      const counterEntity = CounterEntity(value: 1, lastUpdated: null);
      when(mockIncrementCounter()).thenAnswer((_) async => const Right(counterEntity));

      final container = ProviderContainer(
        overrides: [
          getCounterProvider.overrideWithValue(mockGetCounter),
          incrementCounterProvider.overrideWithValue(mockIncrementCounter),
          decrementCounterProvider.overrideWithValue(mockDecrementCounter),
          resetCounterProvider.overrideWithValue(mockResetCounter),
        ],
      );

      final notifier = container.read(counterNotifierProvider.notifier);
      await notifier.increment();

      final state = container.read(counterNotifierProvider);
      expect(state.counter.value, 1);
      expect(state.isLoading, false);
      expect(state.isError, false);

      container.dispose();
    });

    test('카운터 증가가 실패하면 에러 상태가 되어야 한다', () async {
      when(mockIncrementCounter()).thenAnswer(
        (_) async => const Left(ServerFailure(message: '서버 오류')),
      );

      final container = ProviderContainer(
        overrides: [
          getCounterProvider.overrideWithValue(mockGetCounter),
          incrementCounterProvider.overrideWithValue(mockIncrementCounter),
          decrementCounterProvider.overrideWithValue(mockDecrementCounter),
          resetCounterProvider.overrideWithValue(mockResetCounter),
        ],
      );

      final notifier = container.read(counterNotifierProvider.notifier);
      await notifier.increment();

      final state = container.read(counterNotifierProvider);
      expect(state.isError, true);
      expect(state.errorMessage, '서버 오류');
      expect(state.isLoading, false);

      container.dispose();
    });
  });
}
