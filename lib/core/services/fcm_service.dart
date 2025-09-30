import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 백그라운드 메시지 핸들러 (Top-level 함수로 선언 필수!)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 백그라운드 FCM 수신: ${message.messageId}');
  print('   데이터: ${message.data}');

  if (message.data['type'] == 'data_update') {
    await FcmService.saveUpdateFlagStatic(message.data);
  }
}

/// FCM 서비스
/// iOS + Android 백그라운드 푸시 지원
class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// FCM 초기화
  static Future<void> initialize() async {
    try {
      print('🔔 FCM 초기화 시작...');

      // 1. iOS 포그라운드 알림 설정
      if (Platform.isIOS) {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        print('✅ iOS 포그라운드 알림 설정 완료');
      }

      // 2. 권한 요청
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ FCM 권한 승인됨');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('⚠️ FCM 임시 권한 승인됨');
      } else {
        print('❌ FCM 권한 거부됨');
        return;
      }

      // 3. Android 알림 채널 생성
      await _createNotificationChannel();

      // 4. FCM 토큰 가져오기
      final token = await _messaging.getToken();
      if (token != null) {
        print('📱 FCM 토큰: ${token.substring(0, 20)}...');
      }

      // 5. 토픽 구독
      await _messaging.subscribeToTopic('all_users');
      print('✅ all_users 토픽 구독 완료');

      // 6. 백그라운드 메시지 핸들러 등록
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      print('✅ 백그라운드 핸들러 등록 완료');

      // 7. 포그라운드 메시지 핸들러
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      print('✅ 포그라운드 핸들러 등록 완료');

      // 8. 앱이 종료된 상태에서 푸시 클릭으로 실행된 경우
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print('📬 앱 종료 상태에서 푸시로 실행: ${initialMessage.data}');
        await _handleMessage(initialMessage);
      }

      // 9. 백그라운드 상태에서 푸시 클릭으로 포그라운드 전환
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      // 10. 토큰 갱신 리스너
      _messaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM 토큰 갱신: ${newToken.substring(0, 20)}...');
      });

      print('✅ FCM 초기화 완료');
    } catch (e) {
      print('❌ FCM 초기화 실패: $e');
    }
  }

  /// Android 알림 채널 생성
  static Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'data_update_channel', // ID (FCM 페이로드와 동일!)
        '데이터 업데이트',
        description: '직업, 템플릿 등 데이터 업데이트 알림',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      print('✅ Android 알림 채널 생성 완료');
    }
  }

  /// 포그라운드 메시지 핸들러
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📬 포그라운드 FCM 수신: ${message.messageId}');
    print('   제목: ${message.notification?.title}');
    print('   내용: ${message.notification?.body}');
    print('   데이터: ${message.data}');

    await _handleMessage(message);
  }

  /// 메시지 처리 (공통)
  static Future<void> _handleMessage(RemoteMessage message) async {
    if (message.data['type'] == 'data_update') {
      await _saveUpdateFlag(message.data);
    }
  }

  /// 업데이트 플래그 저장
  static Future<void> _saveUpdateFlag(Map<String, dynamic> data) async {
    try {
      final dataType = data['data_type'] as String?;
      if (dataType == null) {
        print('⚠️ data_type이 없습니다');
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      if (dataType == 'jobs') {
        await prefs.setBool('needs_update_jobs', true);
        await prefs.setString('update_jobs_version', data['version'] ?? '');
        print('✅ 직업 업데이트 플래그 저장 (v${data['version']})');
      } else if (dataType == 'party_templates') {
        await prefs.setBool('needs_update_templates', true);
        await prefs.setString(
            'update_templates_version', data['version'] ?? '');
        print('✅ 템플릿 업데이트 플래그 저장 (v${data['version']})');
      }
    } catch (e) {
      print('❌ 플래그 저장 실패: $e');
    }
  }

  /// Static 메서드로 플래그 저장 (백그라운드에서 사용)
  static Future<void> saveUpdateFlagStatic(Map<String, dynamic> data) async {
    await _saveUpdateFlag(data);
  }

  /// 업데이트 플래그 확인
  static Future<bool> needsUpdateJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final needsUpdate = prefs.getBool('needs_update_jobs') ?? false;

      if (needsUpdate) {
        final version = prefs.getString('update_jobs_version') ?? '?';
        print('📌 직업 업데이트 플래그 확인: true (v$version)');
      }

      return needsUpdate;
    } catch (e) {
      print('❌ 플래그 확인 실패: $e');
      return false;
    }
  }

  static Future<bool> needsUpdateTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final needsUpdate = prefs.getBool('needs_update_templates') ?? false;

      if (needsUpdate) {
        final version = prefs.getString('update_templates_version') ?? '?';
        print('📌 템플릿 업데이트 플래그 확인: true (v$version)');
      }

      return needsUpdate;
    } catch (e) {
      print('❌ 플래그 확인 실패: $e');
      return false;
    }
  }

  /// 업데이트 플래그 제거
  static Future<void> clearUpdateFlag(String dataType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('needs_update_$dataType');
      await prefs.remove('update_${dataType}_version');
      print('✅ $dataType 업데이트 플래그 제거');
    } catch (e) {
      print('❌ 플래그 제거 실패: $e');
    }
  }
}
