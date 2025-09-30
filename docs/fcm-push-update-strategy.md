# 🔔 FCM 푸시 기반 업데이트 전략

## 목차
1. [전략 개요](#전략-개요)
2. [기존 방식 vs FCM 방식](#기존-방식-vs-fcm-방식)
3. [구현 아키텍처](#구현-아키텍처)
4. [FCM 설정](#fcm-설정)
5. [Supabase Functions](#supabase-functions)
6. [Flutter 클라이언트 구현](#flutter-클라이언트-구현)
7. [사용량 비교](#사용량-비교)
8. [장단점 분석](#장단점-분석)

---

## 전략 개요

### 핵심 아이디어

**기존 방식 (Pull)**
```
앱 실행 → 버전 체크 API 호출 → 업데이트 여부 확인 → 다운로드
```

**FCM 방식 (Push)** ✨
```
Supabase 데이터 업데이트 → FCM 푸시 전송 → 앱 수신 → 플래그 저장 → 
앱 실행 시 플래그 체크 → 다운로드
```

### 장점

1. **API 호출 대폭 감소** ✅
   - 버전 체크 API 호출 불필요
   - 플래그만 로컬에서 확인

2. **실시간 업데이트 알림** ✅
   - 사용자가 앱을 실행하지 않아도 알림 받음
   - 백그라운드에서 업데이트 가능

3. **서버 부하 감소** ✅
   - Pull 방식 → Push 방식
   - 필요할 때만 다운로드

4. **사용자 경험 개선** ✅
   - "새로운 콘텐츠 업데이트!" 알림 가능
   - 선택적 업데이트 (사용자 동의)

---

## 기존 방식 vs FCM 방식

### 시나리오: 1,000명 사용자, 월 1회 데이터 업데이트

| 항목 | Pull 방식 (24시간 캐싱) | FCM Push 방식 |
|------|------------------------|---------------|
| **월간 버전 체크 API** | 60,000 requests | 0 requests ✅ |
| **FCM 푸시 전송** | 0 | 1,000 messages |
| **데이터 다운로드 API** | 60,000 requests | 1,000 requests ✅ |
| **총 API 호출** | 120,000 | 1,000 (99% 감소!) |
| **월간 데이터 전송** | 145 MB | 15 MB (90% 감소!) |

### 결론
- ✅ **API 호출 99% 감소**
- ✅ **데이터 전송 90% 감소**
- ✅ **실시간 알림 제공**

---

## 구현 아키텍처

### 전체 흐름

```mermaid
sequenceDiagram
    participant Admin as 관리자
    participant Supabase as Supabase DB
    participant Function as Supabase Function
    participant FCM as Firebase FCM
    participant App as Flutter App
    participant Local as Local Storage

    Admin->>Supabase: 1. 직업/템플릿 데이터 업데이트
    Admin->>Supabase: 2. data_versions 버전 증가
    
    Note over Supabase,Function: Database Trigger
    Supabase->>Function: 3. Trigger 발동 (버전 변경 감지)
    Function->>FCM: 4. 전체 사용자에게 FCM 푸시 전송
    
    FCM->>App: 5. 푸시 메시지 수신
    App->>Local: 6. 업데이트 플래그 저장<br/>(needs_update_jobs: true)
    
    Note over App: 백그라운드 또는 알림
    
    App->>App: 7. 사용자가 앱 실행
    App->>Local: 8. 업데이트 플래그 확인
    
    alt 업데이트 필요
        App->>Supabase: 9. 데이터 다운로드 (1회만)
        Supabase-->>App: 10. 직업/템플릿 데이터
        App->>Local: 11. 로컬 저장 + 플래그 제거
    else 업데이트 불필요
        App->>Local: 로컬 데이터 사용
    end
```

---

## FCM 설정

### 1. Firebase 프로젝트 생성

```bash
# Firebase Console
1. https://console.firebase.google.com/ 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름: "mobi-party-link"
4. Google Analytics 활성화 (선택)
5. Android 앱 추가
   - 패키지명: studio.deskmonent.mobipartylink
   - google-services.json 다운로드
```

### 2. Flutter 프로젝트 설정

**pubspec.yaml**
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # FCM
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  
  # 로컬 알림 (FCM과 연동)
  flutter_local_notifications: ^16.3.0
```

**google-services.json 배치**
```
android/app/google-services.json
```

**android/build.gradle**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**android/app/build.gradle**
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

---

## Supabase Functions

### 1. Database Trigger 생성

**SQL**
```sql
-- data_versions 테이블 변경 시 FCM 푸시 전송
CREATE OR REPLACE FUNCTION notify_data_update()
RETURNS TRIGGER AS $$
BEGIN
  -- Edge Function 호출 (HTTP POST)
  PERFORM
    net.http_post(
      url := 'https://your-project.supabase.co/functions/v1/send-update-notification',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer YOUR_SUPABASE_ANON_KEY'
      ),
      body := jsonb_build_object(
        'data_type', NEW.data_type,
        'version', NEW.version,
        'updated_at', NEW.last_updated
      )
    );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger 등록
CREATE TRIGGER on_data_version_update
  AFTER UPDATE ON data_versions
  FOR EACH ROW
  WHEN (OLD.version IS DISTINCT FROM NEW.version)
  EXECUTE FUNCTION notify_data_update();
```

### 2. Supabase Edge Function 생성

**supabase/functions/send-update-notification/index.ts**
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const FCM_SERVER_KEY = Deno.env.get('FCM_SERVER_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

serve(async (req) => {
  try {
    const { data_type, version, updated_at } = await req.json()
    
    console.log(`📢 Sending update notification: ${data_type} v${version}`)
    
    // FCM 토픽으로 전송 (모든 사용자)
    const fcmResponse = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Authorization': `key=${FCM_SERVER_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        to: '/topics/all_users',
        priority: 'high',
        data: {
          type: 'data_update',
          data_type: data_type,
          version: version.toString(),
          updated_at: updated_at,
        },
        notification: {
          title: '새로운 콘텐츠 업데이트!',
          body: data_type === 'jobs' 
            ? '새로운 직업이 추가되었습니다 🎮'
            : '새로운 파티 템플릿이 추가되었습니다 🎉',
        },
      }),
    })
    
    const result = await fcmResponse.json()
    console.log('✅ FCM sent:', result)
    
    return new Response(
      JSON.stringify({ success: true, result }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('❌ Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
```

**배포**
```bash
# Supabase CLI 설치
npm install -g supabase

# 로그인
supabase login

# Function 배포
supabase functions deploy send-update-notification

# Secret 설정
supabase secrets set FCM_SERVER_KEY=your_fcm_server_key
```

---

## Flutter 클라이언트 구현

### 1. FCM 서비스 구현

**lib/core/services/fcm_service.dart**
```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FCM 서비스
/// 데이터 업데이트 알림을 받고 로컬 플래그를 관리합니다.
class FcmService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// FCM 초기화
  static Future<void> initialize() async {
    print('🔔 FCM 초기화 시작...');

    // 1. 권한 요청
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ FCM 권한 승인됨');
    } else {
      print('⚠️ FCM 권한 거부됨');
      return;
    }

    // 2. FCM 토큰 가져오기
    final token = await _firebaseMessaging.getToken();
    print('📱 FCM 토큰: $token');

    // 3. 토픽 구독 (모든 사용자)
    await _firebaseMessaging.subscribeToTopic('all_users');
    print('✅ all_users 토픽 구독 완료');

    // 4. 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. 백그라운드 메시지 핸들러
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // 6. 로컬 알림 초기화
    await _initializeLocalNotifications();

    print('✅ FCM 초기화 완료');
  }

  /// 포그라운드 메시지 핸들러
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📬 포그라운드 메시지 수신: ${message.data}');

    if (message.data['type'] == 'data_update') {
      await _handleDataUpdateMessage(message.data);
      
      // 로컬 알림 표시
      await _showLocalNotification(
        title: message.notification?.title ?? '업데이트 알림',
        body: message.notification?.body ?? '새로운 콘텐츠가 업데이트되었습니다',
      );
    }
  }

  /// 백그라운드 메시지 핸들러
  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('📬 백그라운드 메시지 수신: ${message.data}');

    if (message.data['type'] == 'data_update') {
      await _handleDataUpdateMessage(message.data);
    }
  }

  /// 데이터 업데이트 메시지 처리
  static Future<void> _handleDataUpdateMessage(Map<String, dynamic> data) async {
    final dataType = data['data_type'] as String;
    final version = int.tryParse(data['version'] ?? '0') ?? 0;
    
    print('🔄 데이터 업데이트 감지: $dataType v$version');

    // 로컬 플래그 저장
    final prefs = await SharedPreferences.getInstance();
    
    if (dataType == 'jobs') {
      await prefs.setBool('needs_update_jobs', true);
      await prefs.setInt('pending_jobs_version', version);
      print('✅ 직업 업데이트 플래그 저장');
    } else if (dataType == 'party_templates') {
      await prefs.setBool('needs_update_templates', true);
      await prefs.setInt('pending_templates_version', version);
      print('✅ 템플릿 업데이트 플래그 저장');
    }
  }

  /// 로컬 알림 초기화
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);
  }

  /// 로컬 알림 표시
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'data_update_channel',
      '데이터 업데이트',
      channelDescription: '직업, 템플릿 등 데이터 업데이트 알림',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  /// 업데이트 플래그 확인
  static Future<bool> needsUpdateJobs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('needs_update_jobs') ?? false;
  }

  static Future<bool> needsUpdateTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('needs_update_templates') ?? false;
  }

  /// 업데이트 플래그 제거
  static Future<void> clearUpdateFlag(String dataType) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (dataType == 'jobs') {
      await prefs.remove('needs_update_jobs');
      await prefs.remove('pending_jobs_version');
      print('✅ 직업 업데이트 플래그 제거');
    } else if (dataType == 'templates') {
      await prefs.remove('needs_update_templates');
      await prefs.remove('pending_templates_version');
      print('✅ 템플릿 업데이트 플래그 제거');
    }
  }
}
```

---

### 2. 데이터 동기화 서비스 수정

**lib/core/services/data_sync_service.dart**
```dart
/// FCM 기반 스마트 동기화
Future<bool> fcmBasedSyncJobs() async {
  try {
    print('🔄 FCM 기반 직업 동기화 시작...');

    // 1. FCM 업데이트 플래그 확인
    final needsUpdate = await FcmService.needsUpdateJobs();
    
    if (!needsUpdate) {
      print('✅ 직업 업데이트 불필요 (FCM 플래그 없음)');
      return true;
    }

    print('📡 FCM 업데이트 플래그 감지, 다운로드 시작...');

    // 2. 서버에서 최신 데이터 다운로드
    final jobsResult = await jobRepository.getJobs();

    return jobsResult.fold(
      (failure) {
        print('❌ 직업 다운로드 실패: $failure');
        return false;
      },
      (jobs) async {
        // 3. 로컬 저장
        await LocalStorageService.saveJobs(jobs);

        // 4. 서버 버전 확인 후 저장
        final versionResult = await jobRepository.getJobsVersion();
        await versionResult.fold(
          (failure) async {
            print('⚠️ 버전 확인 실패, 로컬 데이터는 저장됨');
          },
          (version) async {
            await LocalStorageService.saveJobsVersion(version);
            print('✅ 직업 버전 $version 저장 완료');
          },
        );

        // 5. FCM 플래그 제거
        await FcmService.clearUpdateFlag('jobs');

        print('🎉 FCM 기반 직업 동기화 완료!');
        return true;
      },
    );
  } catch (e) {
    print('❌ FCM 기반 동기화 에러: $e');
    return false;
  }
}
```

---

### 3. 앱 시작 시 FCM 초기화 및 동기화

**lib/main.dart**
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:mobi_party_link/core/services/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase 초기화
  await Firebase.initializeApp();
  print('✅ Firebase 초기화 완료');

  // 2. FCM 초기화
  await FcmService.initialize();
  print('✅ FCM 초기화 완료');

  // 3. 타임존 초기화
  await _initializeTimeZone();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

**lib/features/home/presentation/screens/main_screen.dart**
```dart
@override
void initState() {
  super.initState();
  _initializeApp();
}

Future<void> _initializeApp() async {
  // 1. FCM 플래그 기반 데이터 동기화
  await _syncDataWithFcm();
  
  // 2. 파티 목록 조회
  await _fetchParties();
}

Future<void> _syncDataWithFcm() async {
  final dataSyncService = DataSyncService(
    jobRepository: ref.read(jobRepositoryProvider),
    templateRepository: ref.read(partyTemplateRepositoryProvider),
  );

  // FCM 플래그 확인 후 필요 시에만 다운로드
  await dataSyncService.fcmBasedSyncJobs();
  await dataSyncService.fcmBasedSyncTemplates();
}
```

---

## 사용량 비교

### 1,000명 사용자, 월 1회 데이터 업데이트 기준

#### A. 기존 Pull 방식 (24시간 캐싱)

```
버전 체크 API:
- 1,000명 × 1회/일 × 30일 × 2(직업+템플릿) = 60,000 requests
- 60,000 × 0.1 KB = 6 MB

데이터 다운로드 API (월 1회 업데이트):
- 1,000명 × 1회 × 2 = 2,000 requests
- 2,000 × 7.5 KB = 15 MB

-----------------------------------------------------------------------
총 API 호출: 62,000 requests
총 데이터 전송: 21 MB
```

#### B. FCM Push 방식

```
FCM 푸시 전송 (월 1회 업데이트):
- 1,000명 × 1회 × 2 = 2,000 messages
- FCM은 무료 (무제한)

데이터 다운로드 API (FCM 수신 후):
- 1,000명 × 1회 × 2 = 2,000 requests
- 2,000 × 7.5 KB = 15 MB

-----------------------------------------------------------------------
총 API 호출: 2,000 requests (97% 감소!)
총 데이터 전송: 15 MB (29% 감소)
총 FCM 메시지: 2,000 (무료)
```

---

## 장단점 분석

### FCM 방식의 장점 ✅

1. **API 호출 대폭 감소** (97%)
   - 버전 체크 API 완전 제거
   - 필요할 때만 다운로드

2. **실시간 알림**
   - 사용자가 앱을 실행하지 않아도 알림
   - "새로운 콘텐츠!" 푸시 알림 가능

3. **서버 부하 최소화**
   - Pull → Push 전환
   - 1회 푸시로 전체 사용자 알림

4. **사용자 경험 개선**
   - 즉시 업데이트 알림
   - 선택적 다운로드 가능

5. **비용 절감**
   - FCM 무료 (무제한)
   - Supabase Bandwidth 97% 절감

### FCM 방식의 단점 ⚠️

1. **추가 설정 필요**
   - Firebase 프로젝트 생성
   - Supabase Edge Function 배포
   - Database Trigger 설정

2. **FCM 의존성**
   - Firebase 인프라 의존
   - 푸시 전송 실패 가능성

3. **초기 다운로드 필요**
   - 신규 사용자는 여전히 다운로드 필요
   - FCM 미수신 사용자 대비 필요

4. **복잡도 증가**
   - Pull 방식보다 구조 복잡
   - 디버깅 어려움

---

## 하이브리드 전략 (권장) ⭐⭐⭐

### 최적의 조합: FCM + Fallback

```dart
/// 하이브리드 동기화 전략
Future<bool> hybridSyncJobs() async {
  // 1. FCM 플래그 우선 확인
  if (await FcmService.needsUpdateJobs()) {
    print('🔔 FCM 업데이트 플래그 감지');
    return await fcmBasedSyncJobs();
  }

  // 2. 로컬 데이터 확인
  final localJobs = await LocalStorageService.getJobs();
  if (localJobs != null && localJobs.isNotEmpty) {
    print('📱 로컬 데이터 사용 (업데이트 불필요)');
    return true;
  }

  // 3. Fallback: 로컬 데이터 없으면 서버에서 다운로드
  print('⚠️ 로컬 데이터 없음, 서버에서 다운로드');
  return await syncJobs();
}
```

### 장점

- ✅ FCM 미수신 사용자도 커버 (Fallback)
- ✅ 신규 사용자 자동 다운로드
- ✅ 최대한 API 호출 절감
- ✅ 안정적인 시스템

---

## 구현 우선순위

### Phase 1: 기본 구현 (현재)
- ✅ 24시간 캐싱
- ✅ 로컬 우선 전략

### Phase 2: FCM 추가 (권장)
- 🔜 Firebase 프로젝트 생성
- 🔜 Supabase Edge Function 배포
- 🔜 FCM 서비스 구현
- 🔜 하이브리드 전략 적용

### Phase 3: 최적화 (선택)
- 🔜 사용자별 타겟팅
- 🔜 Wi-Fi 전용 다운로드
- 🔜 백그라운드 자동 다운로드

---

## 비용 분석 (10,000명 기준)

| 방식 | 월간 API 호출 | 월간 Bandwidth | Firebase 비용 |
|------|--------------|---------------|--------------|
| Pull (24h 캐싱) | 620,000 | 210 MB | $0 |
| FCM Push | 20,000 | 150 MB | $0 (FCM 무료) |
| **절감** | **97%** | **29%** | **$0** |

### 결론
- ✅ **10,000명까지 무료 플랜 가능**
- ✅ **API 호출 97% 절감**
- ✅ **추가 비용 없음 (FCM 무료)**

---

## 마무리

### 권장 사항

**단기 (현재)**
- ✅ 24시간 캐싱 적용 (이미 구현됨)
- ✅ 로컬 우선 전략 (이미 구현됨)

**중기 (사용자 1,000명 이상)**
- 🔜 FCM 추가 구현
- 🔜 하이브리드 전략 적용

**장기 (사용자 10,000명 이상)**
- 🔜 백그라운드 자동 다운로드
- 🔜 사용자별 타겟팅
- 🔜 Pro 플랜 고려

### 최종 답변

FCM 푸시 기반 업데이트는 **매우 효과적인 전략**입니다!

- ✅ API 호출 97% 감소
- ✅ 실시간 알림 제공
- ✅ 추가 비용 없음
- ✅ 사용자 경험 개선

**하지만 현재 단계에서는 24시간 캐싱만으로도 충분하며, 사용자가 늘어나면 FCM을 추가하는 것을 권장합니다!** 🚀
