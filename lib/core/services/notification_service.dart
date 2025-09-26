import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/core/utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isInitialized = false;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Timezone 초기화
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

      // 로컬 알림 초기화
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // TODO: FCM 초기화 (Firebase 설정 완료 후 활성화)
      // await _firebaseMessaging.requestPermission(
      //   alert: true,
      //   badge: true,
      //   sound: true,
      // );

      // FCM 토큰 가져오기
      // final token = await _firebaseMessaging.getToken();
      // Logger.info('FCM Token: $token');

      _isInitialized = true;
      Logger.info('알림 서비스 초기화 완료 (로컬 알림만)');
    } catch (e) {
      Logger.error('알림 서비스 초기화 실패: $e');
    }
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    Logger.info('알림 탭됨: ${response.payload}');
    // TODO: 알림 탭 시 파티 상세 화면으로 이동
  }

  /// 파티 시작 N분 전 알림 예약
  Future<void> schedulePartyNotification(
      PartyEntity party, int minutesBefore) async {
    try {
      final notificationTime =
          party.startTime.subtract(Duration(minutes: minutesBefore));
      final now = DateTime.now();

      // 이미 지난 시간이면 알림 예약하지 않음
      if (notificationTime.isBefore(now)) {
        Logger.info('파티 시작 시간이 이미 지났습니다: ${party.name}');
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        'party_notifications',
        '파티 알림',
        channelDescription: '파티 시작 알림',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        party.hashCode, // 고유 ID로 파티 해시코드 사용
        '파티 시작 예정',
        '${party.name} 파티가 ${_getTimeText(minutesBefore)} 시작됩니다!',
        tz.TZDateTime.from(notificationTime, tz.local),
        notificationDetails,
        payload: party.id,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      Logger.info(
          '파티 알림 예약 완료: ${party.name} - ${notificationTime} (${minutesBefore}분 전)');
    } catch (e) {
      Logger.error('파티 알림 예약 실패: $e');
    }
  }

  /// 시간 텍스트 변환
  String _getTimeText(int minutes) {
    if (minutes < 60) {
      return '${minutes}분 후';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}시간 후';
      } else {
        return '${hours}시간 ${remainingMinutes}분 후';
      }
    }
  }

  /// 파티 알림 취소
  Future<void> cancelPartyNotification(PartyEntity party) async {
    try {
      await _localNotifications.cancel(party.hashCode);
      Logger.info('파티 알림 취소 완료: ${party.name}');
    } catch (e) {
      Logger.error('파티 알림 취소 실패: $e');
    }
  }

  /// 모든 파티 알림 취소
  Future<void> cancelAllPartyNotifications() async {
    try {
      await _localNotifications.cancelAll();
      Logger.info('모든 파티 알림 취소 완료');
    } catch (e) {
      Logger.error('모든 파티 알림 취소 실패: $e');
    }
  }

  /// 예약된 알림 목록 조회
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _localNotifications.pendingNotificationRequests();
    } catch (e) {
      Logger.error('예약된 알림 조회 실패: $e');
      return [];
    }
  }

  /// FCM 토큰 가져오기
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      Logger.error('FCM 토큰 가져오기 실패: $e');
      return null;
    }
  }

  /// FCM 토큰 새로고침 리스너
  void listenToTokenRefresh(Function(String) onTokenRefresh) {
    _firebaseMessaging.onTokenRefresh.listen(onTokenRefresh);
  }

  /// 백그라운드 메시지 핸들러
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    Logger.info('백그라운드 메시지 수신: ${message.messageId}');
    // TODO: 백그라운드 메시지 처리 로직
  }

  /// 포그라운드 메시지 핸들러
  void handleForegroundMessage(Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }
}
