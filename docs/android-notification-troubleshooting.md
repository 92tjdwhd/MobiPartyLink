# Android 알림 트러블슈팅 가이드

## 개요
Android 15에서 예약 알림이 작동하지 않는 문제와 해결 과정을 문서화합니다.

## 문제 상황
- **즉시 알림**: 정상 작동 ✅
- **예약 알림**: Android 15에서 작동하지 않음 ❌
- **에러**: 예약은 되지만 실행되지 않음

## 해결 과정

### 1. 권한 설정 (AndroidManifest.xml)
```xml
<!-- 기본 알림 권한 -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />

<!-- 정확한 알림 예약 권한 (Android 12+) -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />

<!-- 정확한 알람 사용 권한 (Android 15+) -->
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />

<!-- 백그라운드 서비스 권한 (Android 15+) -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />

<!-- 백그라운드 실행 권한 (Android 15+) -->
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
```

### 2. Activity 설정
```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize"
    android:showWhenLocked="true"
    android:turnScreenOn="true">
```

### 3. 알림 수신기 설정 (Android 12+)
```xml
<!-- 알림 수신기 -->
<receiver 
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
    android:exported="false" />
<receiver 
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
    android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
</receiver>
```

### 4. Flutter 코드 설정
```dart
// NotificationService.dart
await _localNotifications.zonedSchedule(
  notificationId, // 고유한 알림 ID
  'Mobi Party Link 테스트',
  '${minutes}분 후 테스트 알림입니다! 🎉',
  scheduledTime,
  notificationDetails,
  payload: 'test_notification_scheduled',
  uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
  androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // 중요!
);
```

## 주요 해결책

### 1. Android 12+ exported 속성
- **문제**: `android:exported` 속성이 누락되어 빌드 실패
- **해결**: 모든 receiver에 `android:exported="false"` 추가

### 2. Android 15 백그라운드 제한
- **문제**: 배터리 최적화로 인해 예약 알림이 실행되지 않음
- **해결**: 
  - `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` 권한 추가
  - `AndroidScheduleMode.inexactAllowWhileIdle` 사용
  - `showWhenLocked="true"`, `turnScreenOn="true"` 설정

### 3. 고유한 알림 ID
- **문제**: 동일한 ID로 인해 이전 알림이 덮어씌워짐
- **해결**: `DateTime.now().millisecondsSinceEpoch ~/ 1000` 사용

### 4. 알림 누적 방지
- **문제**: 실행되지 않은 알림이 누적되어 새로운 알림에 영향
- **해결**: `await _localNotifications.cancelAll()` 호출

## 권한 요청 로직
```dart
// 알림 권한 요청
final notificationStatus = await Permission.notification.request();

// 정확한 알림 예약 권한 요청 (Android 12+)
final exactAlarmStatus = await Permission.scheduleExactAlarm.request();

// 두 권한 모두 허용된 경우에만 성공
if (notificationStatus.isGranted && exactAlarmStatus.isGranted) {
  // 알림 예약 진행
}
```

## 테스트 방법
1. **즉시 알림**: 앱이 포그라운드에 있을 때 테스트
2. **예약 알림**: 1분 후 테스트 (빠른 확인)
3. **백그라운드 테스트**: 앱을 백그라운드로 보낸 후 테스트
4. **잠금 화면 테스트**: 화면을 잠근 상태에서 테스트

## 주의사항
- Android 15에서는 배터리 최적화 설정이 중요함
- 사용자가 수동으로 배터리 최적화를 해제해야 할 수 있음
- `USE_EXACT_ALARM` 권한은 Android 15+에서 자동으로 처리됨
- `permission_handler`에서 `Permission.useExactAlarm`은 지원하지 않음

## 참고사항
- `AndroidScheduleMode.exact`: 정확한 시간에 실행 (배터리 최적화 영향 받음)
- `AndroidScheduleMode.inexact`: 부정확한 시간에 실행 (배터리 최적화 영향 적음)
- `AndroidScheduleMode.inexactAllowWhileIdle`: Doze 모드에서도 실행 가능

## 성공 로그 예시
```
I/flutter: 기존 알림 모두 취소 완료
I/flutter: 현재 시간: 2025-09-29 16:16:51.788059
I/flutter: 알림 예약 시간: 2025-09-29 16:17:51.787464+0900
I/flutter: 알림 ID: 1759130211
I/flutter: 현재 예약된 알림 수: 1
I/flutter: 예약된 알림: ID=1759130211, 제목=Mobi Party Link 테스트
I/flutter: 테스트 알림 예약 완료: 1분 후
I/NotificationManager: studio.deskmonent.mobipartylink: notify(1759130211, null, ...)
```

## 향후 개발 시 고려사항
1. 새로운 Android 버전 출시 시 백그라운드 제한 정책 확인
2. 배터리 최적화 관련 사용자 가이드 제공
3. 알림 채널 설정 최적화
4. 포그라운드 서비스 활용 검토
5. Firebase Cloud Messaging (FCM) 대안 검토
