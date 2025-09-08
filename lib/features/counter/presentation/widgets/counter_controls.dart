import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';

class CounterControls extends ConsumerWidget {
  const CounterControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterState = ref.watch(counterNotifierProvider);
    final counterNotifier = ref.read(counterNotifierProvider.notifier);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: counterState.isLoading ? null : () => counterNotifier.decrement(),
              heroTag: 'decrement',
              child: const Icon(Icons.remove),
            ),
            FloatingActionButton(
              onPressed: counterState.isLoading ? null : () => counterNotifier.reset(),
              heroTag: 'reset',
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.refresh),
            ),
            FloatingActionButton(
              onPressed: counterState.isLoading ? null : () => counterNotifier.increment(),
              heroTag: 'increment',
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: counterState.isLoading ? null : () => _showSetCountDialog(context, ref),
              icon: const Icon(Icons.edit),
              label: const Text('값 설정'),
            ),
            ElevatedButton.icon(
              onPressed: counterState.isLoading || counterState.counter.value <= 0
                  ? null
                  : () => counterNotifier.reset(),
              icon: const Icon(Icons.clear),
              label: const Text('초기화'),
            ),
          ],
        ),
      ],
    );
  }

  void _showSetCountDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    final counterNotifier = ref.read(counterNotifierProvider.notifier);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카운트 값 설정'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '새로운 카운트 값',
            hintText: '숫자를 입력하세요',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 0) {
                // TODO: setCounter usecase 구현 필요
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('setCounter 기능은 추후 구현 예정입니다'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('올바른 숫자를 입력해주세요 (0 이상)'),
                  ),
                );
              }
            },
            child: const Text('설정'),
          ),
        ],
      ),
    );
  }
}