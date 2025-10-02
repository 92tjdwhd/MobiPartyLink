import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 백그라운드 메시지 핸들러 (Top-level 함수로 선언 필수!)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📱 백그라운드 메시지 수신: ${message.messageId}');
  print('📱 제목: ${message.notification?.title}');
  print('📱 내용: ${message.notification?.body}');
  print('📱 데이터: ${message.data}');

  // 백그라운드에서도 알림 표시
  await FcmService.showNotificationStatic(message);
}

/// FCM 서비스
class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// FCM 초기화
  static Future<void> initialize() async {
    print('🔔 FCM 서비스 초기화 시작');

    // 로컬 알림 초기화
    await _initializeLocalNotifications();

    // FCM 권한 요청
    await requestPermission();

    // 백그라운드 메시지 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 포그라운드 메시지 리스너
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 앱이 종료된 상태에서 알림을 탭해서 앱이 열린 경우
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('📱 앱 종료 상태에서 알림 탭으로 앱 열림');
      _handleMessage(initialMessage);
    }

    // 앱이 백그라운드에 있을 때 알림을 탭해서 앱이 포그라운드로 온 경우
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // FCM 토큰 가져오기
    final token = await getToken();
    print('🔔 FCM 토큰: $token');

    print('✅ FCM 서비스 초기화 완료');
  }

  /// 로컬 알림 초기화
  static Future<void> _initializeLocalNotifications() async {
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

    await _localNotifications.initialize(initSettings);
  }

  /// FCM 권한 요청
  static Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('✅ FCM 권한 허용됨');
    } else {
      print('❌ FCM 권한 거부됨: ${settings.authorizationStatus}');
    }
  }

  /// FCM 토큰 가져오기
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      print('🔔 FCM 토큰 획득: $token');
      return token;
    } catch (e) {
      print('❌ FCM 토큰 획득 실패: $e');
      return null;
    }
  }

  /// 토픽 구독
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('✅ 토픽 구독 성공: $topic');
    } catch (e) {
      print('❌ 토픽 구독 실패: $e');
    }
  }

  /// 토픽 구독 해제
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('✅ 토픽 구독 해제 성공: $topic');
    } catch (e) {
      print('❌ 토픽 구독 해제 실패: $e');
    }
  }

  /// 포그라운드 메시지 처리
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📱 포그라운드 메시지 수신: ${message.messageId}');
    print('📱 제목: ${message.notification?.title}');
    print('📱 내용: ${message.notification?.body}');
    print('📱 데이터: ${message.data}');

    // 포그라운드에서는 로컬 알림으로 표시
    await showNotificationStatic(message);
  }

  /// 메시지 처리 (앱 열기)
  static Future<void> _handleMessage(RemoteMessage message) async {
    print('📱 메시지 처리: ${message.messageId}');
    print('📱 제목: ${message.notification?.title}');
    print('📱 내용: ${message.notification?.body}');
    print('📱 데이터: ${message.data}');

    // 여기서 특정 화면으로 네비게이션하거나 특정 동작을 수행할 수 있습니다
    // 예: 파티 알림이면 파티 상세 화면으로 이동
    final data = message.data;
    if (data.containsKey('type')) {
      final type = data['type'];
      print('📱 알림 타입: $type');

      switch (type) {
        case 'party_created':
          print('📱 파티 생성 알림');
          break;
        case 'party_updated':
          print('📱 파티 업데이트 알림');
          break;
        case 'party_deleted':
          print('📱 파티 삭제 알림');
          break;
        case 'member_joined':
          print('📱 멤버 참가 알림');
          break;
        case 'member_left':
          print('📱 멤버 탈퇴 알림');
          break;
        case 'member_kicked':
          print('📱 멤버 강퇴 알림');
          break;
        default:
          print('📱 알 수 없는 알림 타입: $type');
      }
    }
  }

  /// 로컬 알림 표시 (정적 메서드)
  static Future<void> showNotificationStatic(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) return;

      const androidDetails = AndroidNotificationDetails(
        'fcm_channel',
        'FCM 알림',
        channelDescription: 'FCM을 통한 푸시 알림',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        notification.title ?? '알림',
        notification.body ?? '',
        details,
        payload: message.data.toString(),
      );

      print('✅ 로컬 알림 표시 완료');
    } catch (e) {
      print('❌ 로컬 알림 표시 실패: $e');
    }
  }

  /// 업데이트 플래그 저장 (정적 메서드)
  static Future<void> saveUpdateFlagStatic(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final type = data['type'] as String?;
      if (type != null) {
        await prefs.setBool('needs_update_$type', true);
        print('✅ 업데이트 플래그 저장: $type');
      }
    } catch (e) {
      print('❌ 업데이트 플래그 저장 실패: $e');
    }
  }

  /// 업데이트 필요 여부 확인
  static Future<bool> needsUpdateJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('needs_update_jobs') ?? false;
    } catch (e) {
      print('❌ 작업 업데이트 필요 여부 확인 실패: $e');
      return false;
    }
  }

  static Future<bool> needsUpdateTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('needs_update_templates') ?? false;
    } catch (e) {
      print('❌ 템플릿 업데이트 필요 여부 확인 실패: $e');
      return false;
    }
  }

  /// 업데이트 플래그 클리어
  static Future<void> clearUpdateFlag(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('needs_update_$type');
      print('✅ 업데이트 플래그 클리어: $type');
    } catch (e) {
      print('❌ 업데이트 플래그 클리어 실패: $e');
    }
  }
}
