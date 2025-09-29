import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobi_party_link/core/services/notification_service.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

part 'notification_provider.g.dart';

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  final NotificationService _notificationService = NotificationService();

  @override
  Future<void> build() async {
    await _notificationService.initialize();
  }

  /// 파티 참여 시 알림 예약
  Future<void> schedulePartyNotification(
      PartyEntity party, int minutesBefore) async {
    await _notificationService.schedulePartyNotification(party, minutesBefore);
  }

  /// 파티 탈퇴 시 알림 취소
  Future<void> cancelPartyNotification(PartyEntity party) async {
    await _notificationService.cancelPartyNotification(party);
  }

  /// 모든 알림 취소 (앱 삭제/재설치 시)
  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllPartyNotifications();
  }

  /// 예약된 알림 목록 조회
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationService.getPendingNotifications();
  }
}
