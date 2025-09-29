# Android 버전별 알림 호환성 가이드

## 개요
Android 버전별 알림 시스템의 변화와 대응 방안을 정리합니다.

## Android 버전별 주요 변화

### Android 8.0 (API 26) - 알림 채널 도입
- **변화**: 알림 채널 시스템 도입
- **대응**: 모든 알림에 채널 ID 설정 필수
- **코드 예시**:
```dart
const androidDetails = AndroidNotificationDetails(
  'channel_id', // 필수
  'Channel Name',
  channelDescription: 'Channel Description',
  importance: Importance.high,
);
```

### Android 9.0 (API 28) - 백그라운드 제한 강화
- **변화**: 백그라운드 서비스 제한
- **대응**: 포그라운드 서비스 사용 권장
- **권한 추가**:
```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

### Android 10 (API 29) - 위치 권한 변경
- **변화**: 위치 기반 알림 제한
- **대응**: 위치 권한 요청 방식 변경
- **권한 추가**:
```xml
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### Android 11 (API 30) - 패키지 가시성 제한
- **변화**: 다른 앱과의 상호작용 제한
- **대응**: 쿼리 권한 추가
- **권한 추가**:
```xml
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
```

### Android 12 (API 31) - 정확한 알림 예약 권한
- **변화**: `SCHEDULE_EXACT_ALARM` 권한 도입
- **대응**: 정확한 알림 예약 시 권한 요청
- **권한 추가**:
```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```
- **코드 예시**:
```dart
if (Platform.isAndroid && await DeviceInfoPlugin().androidInfo.sdkInt >= 31) {
  final status = await Permission.scheduleExactAlarm.status;
  if (!status.isGranted) {
    await Permission.scheduleExactAlarm.request();
  }
}
```

### Android 13 (API 33) - 알림 권한 분리
- **변화**: `POST_NOTIFICATIONS` 권한 도입
- **대응**: 알림 표시 시 권한 요청
- **권한 추가**:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```
- **코드 예시**:
```dart
if (Platform.isAndroid && await DeviceInfoPlugin().androidInfo.sdkInt >= 33) {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}
```

### Android 14 (API 34) - 부분 사진/비디오 접근
- **변화**: 미디어 접근 권한 세분화
- **대응**: 필요한 미디어 타입만 요청
- **권한 추가**:
```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
```

### Android 15 (API 35) - 백그라운드 제한 강화
- **변화**: 백그라운드 실행 제한 강화
- **대응**: 배터리 최적화 해제 권장
- **권한 추가**:
```xml
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
```
- **코드 예시**:
```dart
if (Platform.isAndroid && await DeviceInfoPlugin().androidInfo.sdkInt >= 35) {
  // 배터리 최적화 해제 요청
  await Permission.ignoreBatteryOptimizations.request();
}
```

## 버전별 대응 전략

### 1. 동적 권한 요청
```dart
Future<void> requestNotificationPermissions() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.sdkInt;
    
    // Android 13+ 알림 권한
    if (sdkInt >= 33) {
      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        await Permission.notification.request();
      }
    }
    
    // Android 12+ 정확한 알림 예약 권한
    if (sdkInt >= 31) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (!exactAlarmStatus.isGranted) {
        await Permission.scheduleExactAlarm.request();
      }
    }
    
    // Android 15+ 배터리 최적화 해제
    if (sdkInt >= 35) {
      final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
      if (!batteryStatus.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }
}
```

### 2. 버전별 알림 설정
```dart
AndroidNotificationDetails getAndroidNotificationDetails() {
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  final sdkInt = androidInfo.sdkInt;
  
  if (sdkInt >= 35) {
    // Android 15+ 최적화 설정
    return AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      usesChronometer: false,
      showWhen: true,
    );
  } else if (sdkInt >= 31) {
    // Android 12+ 설정
    return AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      importance: Importance.high,
      priority: Priority.high,
    );
  } else {
    // 기본 설정
    return AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      importance: Importance.defaultImportance,
    );
  }
}
```

### 3. 스케줄링 모드 선택
```dart
AndroidScheduleMode getScheduleMode() {
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  final sdkInt = androidInfo.sdkInt;
  
  if (sdkInt >= 35) {
    // Android 15+ Doze 모드 대응
    return AndroidScheduleMode.inexactAllowWhileIdle;
  } else if (sdkInt >= 31) {
    // Android 12+ 정확한 알림
    return AndroidScheduleMode.exactAllowWhileIdle;
  } else {
    // 기본 모드
    return AndroidScheduleMode.exact;
  }
}
```

## 호환성 테스트 체크리스트

### Android 8.0+ (API 26+)
- [ ] 알림 채널 설정 확인
- [ ] 채널별 알림 동작 테스트
- [ ] 채널 설정 변경 테스트

### Android 9.0+ (API 28+)
- [ ] 백그라운드 서비스 제한 테스트
- [ ] 포그라운드 서비스 동작 확인
- [ ] 배터리 사용량 모니터링

### Android 10+ (API 29+)
- [ ] 위치 기반 알림 테스트
- [ ] 백그라운드 위치 권한 확인
- [ ] 위치 서비스 동작 테스트

### Android 11+ (API 30+)
- [ ] 패키지 가시성 테스트
- [ ] 다른 앱과의 상호작용 확인
- [ ] 쿼리 권한 동작 테스트

### Android 12+ (API 31+)
- [ ] 정확한 알림 예약 권한 테스트
- [ ] `SCHEDULE_EXACT_ALARM` 권한 요청
- [ ] 정확한 시간 알림 동작 확인

### Android 13+ (API 33+)
- [ ] 알림 권한 분리 테스트
- [ ] `POST_NOTIFICATIONS` 권한 요청
- [ ] 알림 표시 동작 확인

### Android 14+ (API 34+)
- [ ] 미디어 접근 권한 테스트
- [ ] 부분 미디어 접근 확인
- [ ] 미디어 기반 알림 테스트

### Android 15+ (API 35+)
- [ ] 백그라운드 제한 강화 테스트
- [ ] 배터리 최적화 해제 확인
- [ ] `USE_EXACT_ALARM` 권한 동작
- [ ] Doze 모드에서 알림 동작 확인

## 문제 해결 가이드

### 일반적인 문제
1. **알림이 표시되지 않음**
   - 권한 상태 확인
   - 채널 설정 확인
   - 배터리 최적화 설정 확인

2. **예약 알림이 실행되지 않음**
   - 정확한 알림 예약 권한 확인
   - 스케줄링 모드 확인
   - 배터리 최적화 해제 확인

3. **백그라운드에서 알림이 작동하지 않음**
   - 포그라운드 서비스 사용
   - 배터리 최적화 해제
   - 시스템 설정 확인

### 디버깅 도구
```dart
// 권한 상태 확인
Future<void> checkPermissions() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    print('Android SDK: ${androidInfo.sdkInt}');
    print('알림 권한: ${await Permission.notification.status}');
    print('정확한 알림 예약 권한: ${await Permission.scheduleExactAlarm.status}');
    print('배터리 최적화 해제: ${await Permission.ignoreBatteryOptimizations.status}');
  }
}

// 예약된 알림 확인
Future<void> checkScheduledNotifications() async {
  final pendingNotifications = await _localNotifications.pendingNotificationRequests();
  print('예약된 알림 수: ${pendingNotifications.length}');
  for (final notification in pendingNotifications) {
    print('ID: ${notification.id}, 제목: ${notification.title}');
  }
}
```

## 향후 대응 방안

### Android 16+ 예상 변화
- 더 강화된 백그라운드 제한
- 새로운 권한 시스템
- 개선된 배터리 최적화

### 대응 전략
1. 정기적인 Android 업데이트 모니터링
2. 베타 버전에서 사전 테스트
3. 사용자 피드백 수집 및 대응
4. 대체 솔루션 준비 (FCM, 서버 푸시 등)

## 참고 자료
- [Android 개발자 문서 - 알림](https://developer.android.com/guide/topics/ui/notifiers/notifications)
- [Android 개발자 문서 - 권한](https://developer.android.com/guide/topics/permissions/overview)
- [Flutter Local Notifications 플러그인](https://pub.dev/packages/flutter_local_notifications)
- [Permission Handler 플러그인](https://pub.dev/packages/permission_handler)
