# 🔥 FCM 완전 설정 가이드 (iOS + Android)

## 📋 설정 순서

1. Firebase 프로젝트 생성
2. Android 앱 등록
3. iOS 앱 등록
4. FlutterFire 자동 설정
5. Supabase FCM Trigger 설정
6. 테스트

---

## Step 1: Firebase 프로젝트 생성

### 1-1. Firebase Console 접속

```
https://console.firebase.google.com/
```

### 1-2. 프로젝트 생성

1. **"프로젝트 추가"** 클릭
2. **프로젝트 이름**: `mobi-party-link`
3. **Google Analytics**: 활성화 (권장)
4. **계정 선택**: 기본 계정
5. **프로젝트 만들기** 클릭

---

## Step 2: Android 앱 등록

### 2-1. Android 앱 추가

1. Firebase Console에서 **Android 아이콘** 클릭
2. **앱 등록** 정보 입력:
   ```
   Android 패키지 이름: studio.deskmonent.mobipartylink
   앱 닉네임(선택): Mobi Party Link
   디버그 서명 인증서(선택): 비워두기
   ```
3. **앱 등록** 클릭

### 2-2. google-services.json 다운로드

1. **google-services.json** 다운로드
2. 터미널에서 실행:
   ```bash
   # 다운로드한 파일을 프로젝트로 복사
   cp ~/Downloads/google-services.json android/app/
   ```

### 2-3. Firebase SDK 추가

**android/build.gradle** (프로젝트 레벨)
```gradle
buildscript {
    ext.kotlin_version = '1.9.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0'  // 이 줄 추가!
    }
}
```

**android/app/build.gradle** (앱 레벨)
```gradle
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

// 맨 아래에 추가!
apply plugin: 'com.google.gms.google-services'
```

---

## Step 3: iOS 앱 등록

### 3-1. iOS 앱 추가

1. Firebase Console에서 **iOS 아이콘** 클릭
2. **앱 등록** 정보 입력:
   ```
   iOS 번들 ID: com.ideaware.mobipartylink
   앱 닉네임(선택): Mobi Party Link
   앱스토어 ID(선택): 비워두기
   ```
3. **앱 등록** 클릭

### 3-2. GoogleService-Info.plist 다운로드

1. **GoogleService-Info.plist** 다운로드
2. Xcode에서 추가:
   ```bash
   # Xcode 열기
   open ios/Runner.xcworkspace
   
   # 또는 파일 복사
   cp ~/Downloads/GoogleService-Info.plist ios/Runner/
   ```
3. Xcode에서 **Runner** 프로젝트 선택 → **Add Files to "Runner"**
4. **GoogleService-Info.plist** 선택 → **Copy items if needed** 체크

### 3-3. iOS 권한 설정

**ios/Runner/Info.plist**
```xml
<dict>
    <!-- 기존 내용... -->
    
    <!-- FCM 백그라운드 모드 추가 -->
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>remote-notification</string>
    </array>
    
    <!-- 알림 권한 설명 -->
    <key>NSUserNotificationsUsageDescription</key>
    <string>파티 알림 및 콘텐츠 업데이트 알림을 받기 위해 권한이 필요합니다.</string>
</dict>
```

---

## Step 4: FlutterFire 자동 설정

### 4-1. FlutterFire CLI 실행

```bash
cd /Users/ideaware/flutter/mobi_party_link

# Firebase 프로젝트와 연동 (자동으로 firebase_options.dart 생성)
flutterfire configure
```

**선택 사항**:
1. **프로젝트 선택**: `mobi-party-link`
2. **플랫폼 선택**: iOS, Android 모두 선택
3. **자동 생성 완료!**

### 4-2. 생성된 파일 확인

```bash
# firebase_options.dart가 생성되었는지 확인
ls -la lib/firebase_options.dart
```

---

## Step 5: Android Manifest 수정

**android/app/src/main/AndroidManifest.xml**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 인터넷 권한 (이미 있음) -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <!-- FCM 권한 추가 -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="com.google.android.c2dm.permission.RECEIVE"/>

    <application
        android:label="mobi_party_link"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- 기존 MainActivity... -->
        
        <!-- FCM 서비스 추가 -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        
        <!-- FCM 기본 알림 아이콘 -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@mipmap/ic_launcher" />
        
        <!-- FCM 기본 알림 색상 -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@android:color/holo_blue_light" />
            
        <!-- FCM 자동 초기화 -->
        <meta-data
            android:name="firebase_messaging_auto_init_enabled"
            android:value="true" />
            
        <!-- Firebase Analytics 자동 수집 -->
        <meta-data
            android:name="firebase_analytics_collection_enabled"
            android:value="true" />
    </application>
</manifest>
```

---

## Step 6: Supabase FCM Trigger 설정

### 6-1. FCM Server Key 가져오기

1. **Firebase Console** → 프로젝트 설정 (⚙️)
2. **클라우드 메시징** 탭
3. **Cloud Messaging API (Legacy)** 섹션에서 **서버 키** 복사
   ```
   예시: AAAAaBcDeFg:APA91bG...
   ```

### 6-2. Supabase SQL Trigger 생성

**Supabase Dashboard → SQL Editor → New query**

```sql
-- ============================================
-- FCM 자동 푸시 전송 Trigger
-- data_versions 테이블 업데이트 시 자동으로 FCM 전송
-- ============================================

-- FCM 푸시 전송 함수
CREATE OR REPLACE FUNCTION send_fcm_push_notification()
RETURNS TRIGGER AS $$
DECLARE
  fcm_url TEXT := 'https://fcm.googleapis.com/fcm/send';
  fcm_server_key TEXT := 'YOUR_FCM_SERVER_KEY';  -- ⚠️ 여기에 FCM 서버 키 입력!
  notification_title TEXT;
  notification_body TEXT;
  topic TEXT := '/topics/all_users';
BEGIN
  -- 알림 메시지 설정
  IF NEW.data_type = 'jobs' THEN
    notification_title := '새로운 직업 추가!';
    notification_body := '새로운 직업이 추가되었습니다 🎮';
  ELSIF NEW.data_type = 'party_templates' THEN
    notification_title := '새로운 템플릿 추가!';
    notification_body := '새로운 파티 템플릿이 추가되었습니다 🎉';
  ELSE
    notification_title := '콘텐츠 업데이트!';
    notification_body := '새로운 콘텐츠가 업데이트되었습니다';
  END IF;

  -- FCM 푸시 전송
  PERFORM net.http_post(
    url := fcm_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'key=' || fcm_server_key
    ),
    body := jsonb_build_object(
      'to', topic,
      'priority', 'high',
      'content_available', true,
      -- 데이터 페이로드 (백그라운드에서도 수신 가능!)
      'data', jsonb_build_object(
        'type', 'data_update',
        'data_type', NEW.data_type,
        'version', NEW.version::text,
        'updated_at', NEW.last_updated::text,
        'click_action', 'FLUTTER_NOTIFICATION_CLICK'
      ),
      -- 알림 페이로드 (포그라운드에서 표시)
      'notification', jsonb_build_object(
        'title', notification_title,
        'body', notification_body,
        'sound', 'default',
        'badge', '1',
        'priority', 'high'
      ),
      -- Android 전용 설정
      'android', jsonb_build_object(
        'priority', 'high',
        'notification', jsonb_build_object(
          'channel_id', 'data_update_channel',
          'sound', 'default',
          'priority', 'high'
        )
      ),
      -- iOS 전용 설정
      'apns', jsonb_build_object(
        'headers', jsonb_build_object(
          'apns-priority', '10'
        ),
        'payload', jsonb_build_object(
          'aps', jsonb_build_object(
            'alert', jsonb_build_object(
              'title', notification_title,
              'body', notification_body
            ),
            'sound', 'default',
            'badge', 1,
            'content-available', 1
          )
        )
      )
    )::text
  );
  
  -- 로그
  RAISE NOTICE '✅ FCM 푸시 전송: % v%', NEW.data_type, NEW.version;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 기존 Trigger 삭제 (있다면)
DROP TRIGGER IF EXISTS fcm_on_version_update ON data_versions;

-- 새 Trigger 생성
CREATE TRIGGER fcm_on_version_update
  AFTER UPDATE ON data_versions
  FOR EACH ROW
  WHEN (OLD.version IS DISTINCT FROM NEW.version)
  EXECUTE FUNCTION send_fcm_push_notification();

-- ============================================
-- 확인
-- ============================================

-- Trigger 목록 확인
SELECT trigger_name, event_manipulation, event_object_table 
FROM information_schema.triggers 
WHERE trigger_name = 'fcm_on_version_update';

-- 예상 출력:
-- trigger_name          | event_manipulation | event_object_table
-- fcm_on_version_update | UPDATE             | data_versions
```

**⚠️ 중요**: `fcm_server_key` 변수에 Firebase에서 복사한 서버 키를 입력하세요!

---

## Step 7: FCM Service 코드 개선 (iOS + Android)

**lib/core/services/fcm_service.dart** (이미 생성됨, 개선 버전)

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

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
class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

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
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ FCM 임시 권한 승인됨');
      } else {
        print('❌ FCM 권한 거부됨');
        return;
      }

      // 3. FCM 토큰 가져오기
      final token = await _messaging.getToken();
      if (token != null) {
        print('📱 FCM 토큰: ${token.substring(0, 20)}...');
      }

      // 4. 토픽 구독
      await _messaging.subscribeToTopic('all_users');
      print('✅ all_users 토픽 구독 완료');

      // 5. 백그라운드 메시지 핸들러 등록
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      print('✅ 백그라운드 핸들러 등록 완료');

      // 6. 포그라운드 메시지 핸들러
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      print('✅ 포그라운드 핸들러 등록 완료');

      // 7. 앱이 종료된 상태에서 푸시 클릭으로 실행된 경우
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print('📬 앱 종료 상태에서 푸시로 실행: ${initialMessage.data}');
        await _handleMessage(initialMessage);
      }

      // 8. 백그라운드 상태에서 푸시 클릭으로 포그라운드 전환
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      print('✅ FCM 초기화 완료');
    } catch (e) {
      print('❌ FCM 초기화 실패: $e');
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
        await prefs.setString('update_templates_version', data['version'] ?? '');
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

  /// FCM 토큰 갱신 리스너
  static void listenToTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM 토큰 갱신: ${newToken.substring(0, 20)}...');
      // TODO: 필요 시 서버에 토큰 업데이트
    });
  }
}
```

---

## Step 8: 테스트용 FCM 수동 전송 스크립트

### 8-1. Node.js 테스트 스크립트

**test_fcm_push.js** (프로젝트 루트에 생성)

```javascript
// FCM 테스트 푸시 전송 스크립트
// 사용법: node test_fcm_push.js jobs 2

const https = require('https');

// FCM 서버 키 (Firebase Console에서 복사)
const FCM_SERVER_KEY = 'YOUR_FCM_SERVER_KEY';

// 명령줄 인자
const dataType = process.argv[2] || 'jobs';  // jobs 또는 party_templates
const version = process.argv[3] || '2';

// FCM 페이로드 (iOS + Android 모두 지원)
const payload = {
  to: '/topics/all_users',
  priority: 'high',
  content_available: true,
  
  // 데이터 페이로드 (백그라운드에서도 수신!)
  data: {
    type: 'data_update',
    data_type: dataType,
    version: version,
    updated_at: new Date().toISOString(),
    click_action: 'FLUTTER_NOTIFICATION_CLICK'
  },
  
  // 알림 페이로드 (포그라운드 및 백그라운드)
  notification: {
    title: dataType === 'jobs' ? '새로운 직업 추가!' : '새로운 템플릿 추가!',
    body: dataType === 'jobs' 
      ? '새로운 직업이 추가되었습니다 🎮' 
      : '새로운 파티 템플릿이 추가되었습니다 🎉',
    sound: 'default',
    badge: '1'
  },
  
  // Android 전용 설정
  android: {
    priority: 'high',
    notification: {
      channel_id: 'data_update_channel',
      sound: 'default',
      priority: 'high',
      default_vibrate_timings: true,
      notification_count: 1
    }
  },
  
  // iOS 전용 설정 (APNS)
  apns: {
    headers: {
      'apns-priority': '10'
    },
    payload: {
      aps: {
        alert: {
          title: dataType === 'jobs' ? '새로운 직업 추가!' : '새로운 템플릿 추가!',
          body: dataType === 'jobs' 
            ? '새로운 직업이 추가되었습니다 🎮' 
            : '새로운 파티 템플릿이 추가되었습니다 🎉'
        },
        sound: 'default',
        badge: 1,
        'content-available': 1
      }
    }
  }
};

// FCM 전송
const postData = JSON.stringify(payload);

const options = {
  hostname: 'fcm.googleapis.com',
  port: 443,
  path: '/fcm/send',
  method: 'POST',
  headers: {
    'Authorization': `key=${FCM_SERVER_KEY}`,
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

console.log('📤 FCM 푸시 전송 중...');
console.log(`   데이터 타입: ${dataType}`);
console.log(`   버전: ${version}`);

const req = https.request(options, (res) => {
  let body = '';
  
  res.on('data', (chunk) => {
    body += chunk;
  });
  
  res.on('end', () => {
    console.log('\n✅ FCM 응답:');
    console.log(JSON.stringify(JSON.parse(body), null, 2));
  });
});

req.on('error', (e) => {
  console.error('❌ 에러:', e.message);
});

req.write(postData);
req.end();
```

**사용 방법**:
```bash
# 직업 업데이트 푸시 전송
node test_fcm_push.js jobs 2

# 템플릿 업데이트 푸시 전송
node test_fcm_push.js party_templates 2
```

---

### 8-2. cURL 테스트 스크립트

**test_fcm_push.sh**

```bash
#!/bin/bash

# FCM 서버 키
FCM_SERVER_KEY="YOUR_FCM_SERVER_KEY"

# 파라미터
DATA_TYPE=${1:-jobs}
VERSION=${2:-2}

# FCM 페이로드
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$FCM_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"to\": \"/topics/all_users\",
    \"priority\": \"high\",
    \"content_available\": true,
    \"data\": {
      \"type\": \"data_update\",
      \"data_type\": \"$DATA_TYPE\",
      \"version\": \"$VERSION\",
      \"updated_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
      \"click_action\": \"FLUTTER_NOTIFICATION_CLICK\"
    },
    \"notification\": {
      \"title\": \"새로운 콘텐츠 업데이트!\",
      \"body\": \"$DATA_TYPE 데이터가 v$VERSION 으로 업데이트되었습니다\",
      \"sound\": \"default\",
      \"badge\": \"1\"
    },
    \"android\": {
      \"priority\": \"high\",
      \"notification\": {
        \"channel_id\": \"data_update_channel\",
        \"sound\": \"default\",
        \"priority\": \"high\"
      }
    },
    \"apns\": {
      \"headers\": {
        \"apns-priority\": \"10\"
      },
      \"payload\": {
        \"aps\": {
          \"alert\": {
            \"title\": \"새로운 콘텐츠 업데이트!\",
            \"body\": \"$DATA_TYPE 데이터가 업데이트되었습니다\"
          },
          \"sound\": \"default\",
          \"badge\": 1,
          \"content-available\": 1
        }
      }
    }
  }"
```

**사용 방법**:
```bash
chmod +x test_fcm_push.sh

# 직업 업데이트
./test_fcm_push.sh jobs 2

# 템플릿 업데이트
./test_fcm_push.sh party_templates 2
```

---

## Step 9: Android 채널 설정

**lib/core/services/fcm_service.dart**에 추가

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Android 알림 채널 생성
  static Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'data_update_channel', // ID (FCM 페이로드와 동일!)
        '데이터 업데이트', // 이름
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

  /// initialize() 메서드 안에 추가
  static Future<void> initialize() async {
    // ... 기존 코드 ...
    
    // Android 알림 채널 생성
    await _createNotificationChannel();
    
    // ... 나머지 코드 ...
  }
}
```

---

## Step 10: 테스트 시나리오

### 시나리오 1: 포그라운드 푸시 수신

```
1. 앱 실행 중
2. Supabase에서 jobs 버전 1→2로 업데이트
   (또는 test_fcm_push.js 실행)
3. 앱 로그 확인:
   📬 포그라운드 FCM 수신: abc123
      제목: 새로운 직업 추가!
      내용: 새로운 직업이 추가되었습니다 🎮
      데이터: {type: data_update, data_type: jobs, version: 2}
   ✅ 직업 업데이트 플래그 저장 (v2)
4. 앱 재시작
5. 로그 확인:
   📌 직업 업데이트 플래그 확인: true (v2)
   🔔 FCM 플래그 감지, 직업 동기화 시작...
   ⬇️ 서버에서 직업 데이터 다운로드 중...
   ✅ 직업 데이터 20개 다운로드 완료
   ✅ 직업 업데이트 플래그 제거
```

---

### 시나리오 2: 백그라운드 푸시 수신

```
1. 앱 종료 또는 백그라운드 상태
2. FCM 푸시 전송
3. 시스템 로그 확인:
   📬 백그라운드 FCM 수신: def456
      데이터: {type: data_update, data_type: party_templates, version: 2}
   ✅ 템플릿 업데이트 플래그 저장 (v2)
4. 사용자가 나중에 앱 실행
5. 로그 확인:
   ✅ 직업 업데이트 불필요 (FCM 플래그 없음)
   📌 템플릿 업데이트 플래그 확인: true (v2)
   🔔 FCM 플래그 감지, 템플릿 동기화 시작...
   ⬇️ 서버에서 템플릿 데이터 다운로드 중...
   ✅ 템플릿 데이터 17개 다운로드 완료
```

---

### 시나리오 3: 앱 종료 상태에서 푸시로 실행

```
1. 앱 완전 종료
2. FCM 푸시 수신 → 알림 표시
3. 사용자가 알림 클릭 → 앱 실행
4. 로그 확인:
   📬 앱 종료 상태에서 푸시로 실행: {type: data_update...}
   ✅ 직업 업데이트 플래그 저장
   (앱 초기화 진행)
   📌 직업 업데이트 플래그 확인: true
   🔔 FCM 플래그 감지, 동기화 시작...
```

---

## Step 11: Firebase Console에서 테스트 푸시 전송

### 11-1. Cloud Messaging 메뉴 진입

```
Firebase Console → Cloud Messaging → "첫 번째 캠페인 보내기"
```

### 11-2. 알림 작성

```
알림 제목: 새로운 직업 추가!
알림 텍스트: 새로운 직업이 추가되었습니다 🎮
알림 이미지(선택): 비워두기
```

### 11-3. 타겟 선택

```
타겟: 주제
주제 이름: all_users
```

### 11-4. 추가 옵션 설정

**맞춤 데이터 추가** (중요!)
```
키                값
type             data_update
data_type        jobs
version          2
click_action     FLUTTER_NOTIFICATION_CLICK
```

### 11-5. 전송

```
검토 → 게시
```

---

## 📱 예상 로그 (완전 작동 시)

### 앱 시작 시

```
🔔 FCM 초기화 시작...
✅ iOS 포그라운드 알림 설정 완료
✅ FCM 권한 승인됨
📱 FCM 토큰: dAbCdEfGh123456789...
✅ all_users 토픽 구독 완료
✅ 백그라운드 핸들러 등록 완료
✅ 포그라운드 핸들러 등록 완료
✅ Android 알림 채널 생성 완료
✅ FCM 초기화 완료
✅ Firebase & FCM 초기화 완료
✅ Supabase 초기화 완료
✅ 직업 업데이트 불필요 (FCM 플래그 없음)
✅ 템플릿 업데이트 불필요 (FCM 플래그 없음)
```

### FCM 푸시 수신 시 (포그라운드)

```
📬 포그라운드 FCM 수신: projects/123/messages/456
   제목: 새로운 직업 추가!
   내용: 새로운 직업이 추가되었습니다 🎮
   데이터: {type: data_update, data_type: jobs, version: 2, ...}
✅ 직업 업데이트 플래그 저장 (v2)
```

### 앱 재시작 시 (플래그 있음)

```
📌 직업 업데이트 플래그 확인: true (v2)
🔔 FCM 플래그 감지, 직업 동기화 시작...
🔄 직업 데이터 동기화 시작...
📱 로컬 직업 버전: 1
☁️ 서버 직업 버전: 2
⬇️ 서버에서 직업 데이터 다운로드 중...
✅ 직업 데이터 20개 다운로드 완료
✅ 직업 데이터 20개 로컬 저장 완료
✅ 직업 버전 2 저장 완료
🎉 직업 데이터 동기화 완료! (v1 → v2)
✅ 직업 업데이트 플래그 제거
```

---

## 🎯 체크리스트

### Firebase 설정
- [ ] Firebase 프로젝트 생성
- [ ] Android 앱 등록
- [ ] iOS 앱 등록
- [ ] `google-services.json` 다운로드 및 복사
- [ ] `GoogleService-Info.plist` 다운로드 및 Xcode 추가
- [ ] FCM 서버 키 복사

### Android 설정
- [ ] `android/build.gradle`에 google-services plugin 추가
- [ ] `android/app/build.gradle`에 apply plugin 추가
- [ ] `AndroidManifest.xml`에 FCM 권한 및 서비스 추가

### iOS 설정
- [ ] `ios/Runner/Info.plist`에 백그라운드 모드 추가
- [ ] `GoogleService-Info.plist` Xcode 추가

### Flutter 설정
- [ ] `flutterfire configure` 실행
- [ ] `lib/firebase_options.dart` 생성 확인
- [ ] `lib/core/services/fcm_service.dart` 업데이트

### Supabase 설정
- [ ] FCM Trigger SQL 실행
- [ ] FCM 서버 키를 SQL에 입력

### 테스트
- [ ] 앱 실행 후 FCM 초기화 로그 확인
- [ ] 테스트 푸시 전송
- [ ] 플래그 저장 확인
- [ ] 앱 재시작 후 동기화 확인

---

## 다음 단계

1. **Firebase 프로젝트 생성**
   ```
   https://console.firebase.google.com/
   ```

2. **FlutterFire 설정**
   ```bash
   flutterfire configure
   ```

3. **앱 실행 및 테스트**
   ```bash
   flutter run -d R5CT501NKTK
   ```

모든 준비가 완료되었습니다! 🚀
