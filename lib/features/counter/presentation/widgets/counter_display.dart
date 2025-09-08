import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';

class CounterDisplay extends ConsumerWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterState = ref.watch(counterNotifierProvider);
    
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primaryContainer,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
          ),
          child: Center(
            child: counterState.isLoading
                ? CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  )
                : Text(
                    '${counterState.counter.value}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '현재 카운트',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (counterState.isError) ...[
          const SizedBox(height: 8),
          Text(
            counterState.errorMessage ?? '오류가 발생했습니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}