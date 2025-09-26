import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobi_party_link/core/di/injection.dart';

part 'notification_settings_provider.g.dart';

@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  static const String _notificationTimeKey = 'notification_time_minutes';

  @override
  Future<int> build() async {
    final prefs = await ref.read(sharedPreferencesProvider);
    return prefs.getInt(_notificationTimeKey) ?? 10; // 기본값 10분
  }

  /// 알림 시간 설정 (분 단위)
  Future<void> setNotificationTime(int minutes) async {
    final prefs = await ref.read(sharedPreferencesProvider);
    await prefs.setInt(_notificationTimeKey, minutes);
    state = AsyncValue.data(minutes);
  }

  /// 알림 시간 옵션들
  static const List<int> notificationTimeOptions = [5, 10, 15, 30, 60];

  /// 알림 시간 텍스트 변환
  static String getNotificationTimeText(int minutes) {
    if (minutes < 60) {
      return '${minutes}분 전';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}시간 전';
      } else {
        return '${hours}시간 ${remainingMinutes}분 전';
      }
    }
  }
}
