import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // 알림 설정 관련 상수
  static const String _notificationMinutesKey = 'notification_minutes_before';
  static const int _defaultNotificationMinutes = 5;

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

  /// 알림 설정 시간 조회
  Future<int> getNotificationMinutesBefore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_notificationMinutesKey) ??
          _defaultNotificationMinutes;
    } catch (e) {
      Logger.error('알림 설정 조회 실패: $e');
      return _defaultNotificationMinutes;
    }
  }

  /// 알림 설정 시간 저장
  Future<void> setNotificationMinutesBefore(int minutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_notificationMinutesKey, minutes);
      Logger.info('알림 설정 저장 완료: ${minutes}분 전');
    } catch (e) {
      Logger.error('알림 설정 저장 실패: $e');
    }
  }

  /// 파티 시작 N분 전 알림 예약
  Future<void> schedulePartyNotification(
      PartyEntity party, int minutesBefore) async {
    try {
      // 초기화 확인
      if (!_isInitialized) {
        await initialize();
      }

      final notificationTime =
          party.startTime.subtract(Duration(minutes: minutesBefore));
      final now = DateTime.now();

      // 이미 지난 시간이면 알림 예약하지 않음
      if (notificationTime.isBefore(now)) {
        Logger.info('파티 시작 시간이 이미 지났습니다: ${party.name}');
        return;
      }

      // 고유한 알림 ID 생성 (파티 ID + 시간 기반)
      final notificationId = '${party.id}_${minutesBefore}'.hashCode;

      const androidDetails = AndroidNotificationDetails(
        'party_notifications',
        '파티 알림',
        channelDescription: '파티 시작 알림',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        usesChronometer: false,
        showWhen: true,
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
        notificationId,
        '파티 시작 예정',
        '${party.name} 파티가 ${_getTimeText(minutesBefore)} 시작됩니다!',
        tz.TZDateTime.from(notificationTime, tz.local),
        notificationDetails,
        payload: party.id,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
      // 모든 알림 시간대에 대해 취소
      final currentMinutes = await getNotificationMinutesBefore();
      final notificationId = '${party.id}_${currentMinutes}'.hashCode;
      await _localNotifications.cancel(notificationId);
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

  /// 파티 리스트로 전체 알림 재등록
  Future<void> rescheduleAllPartyNotifications(
      List<PartyEntity> parties) async {
    try {
      // 기존 알림 모두 취소
      await cancelAllPartyNotifications();

      // 현재 알림 설정 시간 조회
      final minutesBefore = await getNotificationMinutesBefore();

      // 각 파티에 대해 알림 재등록
      for (final party in parties) {
        await schedulePartyNotification(party, minutesBefore);
      }

      Logger.info(
          '전체 파티 알림 재등록 완료: ${parties.length}개 파티, ${minutesBefore}분 전');
    } catch (e) {
      Logger.error('전체 파티 알림 재등록 실패: $e');
    }
  }

  /// 알림 설정 변경 시 전체 알림 재등록
  Future<void> updateNotificationSettings(
      int newMinutesBefore, List<PartyEntity> parties) async {
    try {
      // 새로운 설정 저장
      await setNotificationMinutesBefore(newMinutesBefore);

      // 전체 알림 재등록
      await rescheduleAllPartyNotifications(parties);

      Logger.info(
          '알림 설정 변경 완료: ${newMinutesBefore}분 전, ${parties.length}개 파티 재등록');
    } catch (e) {
      Logger.error('알림 설정 변경 실패: $e');
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

  /// 즉시 테스트 알림 표시
  Future<void> showTestNotification() async {
    try {
      // 초기화 확인
      if (!_isInitialized) {
        await initialize();
      }

      const androidDetails = AndroidNotificationDetails(
        'test_notifications',
        '테스트 알림',
        channelDescription: '알림 테스트용',
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

      await _localNotifications.show(
        999, // 테스트용 고유 ID
        'Mobi Party Link 테스트',
        '알림이 정상적으로 작동합니다! 🎉',
        notificationDetails,
        payload: 'test_notification',
      );

      Logger.info('테스트 알림 표시 완료');
    } catch (e) {
      Logger.error('테스트 알림 표시 실패: $e');
      rethrow;
    }
  }

  /// 지정된 시간 후 테스트 알림 예약
  Future<void> scheduleTestNotification(int minutes) async {
    try {
      // 초기화 확인
      if (!_isInitialized) {
        await initialize();
      }

      // 기존 테스트 알림 모두 취소
      await _localNotifications.cancelAll();
      print('기존 알림 모두 취소 완료');

      final notificationTime = DateTime.now().add(Duration(minutes: minutes));
      final scheduledTime = tz.TZDateTime.from(notificationTime, tz.local);

      // 고유한 알림 ID 생성 (현재 시간 기반)
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      print('현재 시간: ${DateTime.now()}');
      print('알림 예약 시간: $scheduledTime');
      print('알림 ID: $notificationId');

      const androidDetails = AndroidNotificationDetails(
        'test_notifications',
        '테스트 알림',
        channelDescription: '알림 테스트용',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        usesChronometer: false,
        showWhen: true,
        when: null, // Android에서 자동으로 설정됨
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

      // Android 15 호환성을 위해 zonedSchedule 사용하되 설정 조정
      await _localNotifications.zonedSchedule(
        notificationId, // 고유한 알림 ID
        'Mobi Party Link 테스트',
        '${minutes}분 후 테스트 알림입니다! 🎉',
        scheduledTime,
        notificationDetails,
        payload: 'test_notification_scheduled',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      // 예약된 알림 목록 확인
      final pendingNotifications = await getPendingNotifications();
      print('현재 예약된 알림 수: ${pendingNotifications.length}');
      for (final notification in pendingNotifications) {
        print('예약된 알림: ID=${notification.id}, 제목=${notification.title}');
      }

      Logger.info('테스트 알림 예약 완료: ${minutes}분 후');
      print('테스트 알림 예약 완료: ${minutes}분 후');
    } catch (e) {
      Logger.error('테스트 알림 예약 실패: $e');
      print('테스트 알림 예약 실패: $e');
      debugPrint('테스트 알림 예약 실패: $e');
      rethrow;
    }
  }
}
