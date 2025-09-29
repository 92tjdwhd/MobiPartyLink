# 알림 개발 모범 사례

## 개요
Flutter 앱에서 안정적인 알림 시스템을 구축하기 위한 모범 사례를 정리합니다.

## 1. 권한 관리

### 필수 권한
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
```

### 권한 요청 순서
1. 앱 시작 시 알림 권한 요청
2. 예약 알림 사용 시 정확한 알림 예약 권한 요청
3. 권한 거부 시 설정 화면으로 안내

## 2. 알림 채널 설정

### Android 알림 채널
```dart
const androidDetails = AndroidNotificationDetails(
  'party_notifications', // 채널 ID
  '파티 알림', // 채널 이름
  channelDescription: '파티 시작 전 알림',
  importance: Importance.high,
  priority: Priority.high,
  icon: '@mipmap/ic_launcher',
  playSound: true,
  enableVibration: true,
  usesChronometer: false,
  showWhen: true,
);
```

### iOS 알림 설정
```dart
const iosDetails = DarwinNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: true,
);
```

## 3. 예약 알림 구현

### 안정적인 예약 알림
```dart
Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledTime,
}) async {
  try {
    // 기존 알림 취소 (중복 방지)
    await _localNotifications.cancel(id);
    
    // 고유한 알림 ID 생성
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // 시간대 설정
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    
    // 알림 예약
    await _localNotifications.zonedSchedule(
      notificationId,
      title,
      body,
      tzScheduledTime,
      notificationDetails,
      payload: 'scheduled_notification',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    
    print('알림 예약 완료: $scheduledTime');
  } catch (e) {
    print('알림 예약 실패: $e');
    rethrow;
  }
}
```

## 4. 에러 처리

### 일반적인 에러 상황
1. **권한 거부**: 사용자에게 설정 화면 안내
2. **배터리 최적화**: 배터리 최적화 해제 안내
3. **알림 예약 실패**: 로그 기록 및 사용자 알림
4. **알림 실행 실패**: 재시도 로직 구현

### 에러 처리 예시
```dart
try {
  await scheduleNotification(...);
} catch (e) {
  if (e.toString().contains('exact_alarms_not_permitted')) {
    // 정확한 알림 권한 요청
    await requestExactAlarmPermission();
  } else if (e.toString().contains('notification_permission')) {
    // 알림 권한 요청
    await requestNotificationPermission();
  } else {
    // 기타 에러 처리
    print('알림 예약 실패: $e');
  }
}
```

## 5. 디버깅 및 로깅

### 필수 로그
```dart
// 알림 예약 시
print('현재 시간: ${DateTime.now()}');
print('알림 예약 시간: $scheduledTime');
print('알림 ID: $notificationId');

// 예약된 알림 확인
final pendingNotifications = await getPendingNotifications();
print('현재 예약된 알림 수: ${pendingNotifications.length}');
for (final notification in pendingNotifications) {
  print('예약된 알림: ID=${notification.id}, 제목=${notification.title}');
}
```

### 성공/실패 로그
```dart
// 성공 시
Logger.info('알림 예약 완료: ${minutes}분 후');
print('알림 예약 완료: ${minutes}분 후');

// 실패 시
Logger.error('알림 예약 실패: $e');
print('알림 예약 실패: $e');
debugPrint('알림 예약 실패: $e');
```

## 6. 사용자 경험 개선

### 권한 요청 다이얼로그
```dart
Future<bool?> showPermissionDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('알림 권한 요청'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('모비링크는 파티 시작 5분 전 알림을 통해 중요한 파티 일정을 놓치지 않도록 도와드립니다.'),
            SizedBox(height: 16),
            Text('정확한 시간에 알림을 받으려면 다음 권한들이 필요합니다:'),
            SizedBox(height: 12),
            Text('• 알림 권한\n• 정확한 알림 예약 권한'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () async {
              final notificationStatus = await Permission.notification.request();
              final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
              
              if (notificationStatus.isGranted && exactAlarmStatus.isGranted) {
                dialogContext.pop(true);
              } else {
                openAppSettings();
                dialogContext.pop(false);
              }
            },
            child: Text('권한 허용'),
          ),
        ],
      );
    },
  );
}
```

### 배터리 최적화 안내
```dart
void showBatteryOptimizationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('배터리 최적화 해제'),
      content: Text('정확한 시간에 알림을 받으려면 배터리 최적화를 해제해주세요.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            openAppSettings();
          },
          child: Text('설정으로 이동'),
        ),
      ],
    ),
  );
}
```

## 7. 테스트 전략

### 단위 테스트
- 권한 상태 확인
- 알림 예약 로직
- 에러 처리 로직

### 통합 테스트
- 즉시 알림 테스트
- 예약 알림 테스트 (1분, 5분, 10분)
- 백그라운드 알림 테스트
- 잠금 화면 알림 테스트

### 사용자 테스트
- 다양한 Android 버전에서 테스트
- 배터리 최적화 설정별 테스트
- 네트워크 상태별 테스트

## 8. 성능 최적화

### 메모리 관리
- 불필요한 알림 취소
- 알림 ID 관리
- 리스너 정리

### 배터리 최적화
- 적절한 알림 빈도
- 불필요한 알림 방지
- 효율적인 스케줄링

## 9. 보안 고려사항

### 데이터 보호
- 알림 내용에 민감한 정보 포함 금지
- 사용자 식별 정보 암호화
- 로그에서 민감한 정보 제거

### 권한 관리
- 최소 권한 원칙
- 사용자 동의 획득
- 권한 사용 목적 명시

## 10. 모니터링 및 분석

### 알림 성공률 추적
- 예약된 알림 수
- 실제 실행된 알림 수
- 실패한 알림 수 및 원인

### 사용자 행동 분석
- 알림 클릭률
- 알림 설정 변경 패턴
- 앱 사용 패턴과 알림의 관계

## 11. 향후 개선 방향

### 기술적 개선
- Firebase Cloud Messaging (FCM) 도입 검토
- 서버 사이드 알림 스케줄링
- 실시간 알림 동기화

### 사용자 경험 개선
- 개인화된 알림 설정
- 스마트 알림 타이밍
- 알림 그룹화 및 우선순위

### 플랫폼별 최적화
- Android 15+ 대응
- iOS 17+ 대응
- 웹 알림 지원
