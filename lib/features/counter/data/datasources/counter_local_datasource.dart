import 'package:shared_preferences/shared_preferences.dart';

import '../models/counter_model.dart';

abstract class CounterLocalDataSource {
  Future<CounterModel> getCounter();
  Future<CounterModel> saveCounter(CounterModel counter);
}

class CounterLocalDataSourceImpl implements CounterLocalDataSource {
  CounterLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  @override
  Future<CounterModel> getCounter() async {
    final value = sharedPreferences.getInt('counter_value') ?? 0;
    final lastUpdatedMillis =
        sharedPreferences.getInt('counter_last_updated') ??
            DateTime.now().millisecondsSinceEpoch;

    return CounterModel(
      value: value,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(lastUpdatedMillis),
    );
  }

  @override
  Future<CounterModel> saveCounter(CounterModel counter) async {
    await sharedPreferences.setInt('counter_value', counter.value);
    if (counter.lastUpdated != null) {
      await sharedPreferences.setInt(
          'counter_last_updated', counter.lastUpdated!.millisecondsSinceEpoch);
    }
    return counter;
  }
}
