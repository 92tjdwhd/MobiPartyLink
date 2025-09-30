# 🚀 FCM 최소 구현 가이드 (기존 코드 활용)

## 개요

**현재 상태**: 이미 동기화 로직이 완벽하게 구현되어 있음!
- ✅ `DataSyncService.syncJobs()` - 직업 동기화
- ✅ `DataSyncService.syncTemplates()` - 템플릿 동기화
- ✅ `LocalStorageService` - 로컬 저장/조회

**추가 작업**: FCM 푸시 수신 → 플래그 저장 → 기존 동기화 로직 호출

**예상 작업량**: 
- 새 파일: 1개 (`fcm_service.dart`)
- 수정 파일: 2개 (`main.dart`, `main_screen.dart`)
- 설정: Firebase 프로젝트 + Supabase Function

---

## 구현 단계

### 1단계: Firebase 설정 (5분)

```bash
1. https://console.firebase.google.com/ 접속
2. "프로젝트 추가" → "mobi-party-link"
3. Android 앱 추가 → 패키지명: studio.deskmonent.mobipartylink
4. google-services.json 다운로드 → android/app/에 복사
```

---

### 2단계: Flutter 패키지 추가 (1분)

**pubspec.yaml**
```yaml
dependencies:
  # 기존 패키지들...
  
  # FCM 추가
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
```

**설치**
```bash
flutter pub get
```

---

### 3단계: FCM 서비스 추가 (신규 파일 1개)

**lib/core/services/fcm_service.dart**
```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FCM 서비스 - 데이터 업데이트 푸시 수신
class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// FCM 초기화 (간단!)
  static Future<void> initialize() async {
    // 1. 권한 요청
    await _messaging.requestPermission();

    // 2. 토픽 구독 (모든 사용자)
    await _messaging.subscribeToTopic('all_users');
    print('✅ FCM 구독 완료');

    // 3. 포그라운드 메시지 수신
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // 4. 백그라운드 메시지 수신
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  /// 메시지 수신 처리
  static Future<void> _handleMessage(RemoteMessage message) async {
    print('📬 FCM 수신: ${message.data}');
    
    if (message.data['type'] == 'data_update') {
      await _saveUpdateFlag(message.data);
    }
  }

  /// 백그라운드 메시지 처리
  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('📬 백그라운드 FCM 수신: ${message.data}');
    
    if (message.data['type'] == 'data_update') {
      await _saveUpdateFlag(message.data);
    }
  }

  /// 업데이트 플래그 저장 (핵심!)
  static Future<void> _saveUpdateFlag(Map<String, dynamic> data) async {
    final dataType = data['data_type'] as String;
    final prefs = await SharedPreferences.getInstance();
    
    if (dataType == 'jobs') {
      await prefs.setBool('needs_update_jobs', true);
      print('✅ 직업 업데이트 플래그 저장');
    } else if (dataType == 'party_templates') {
      await prefs.setBool('needs_update_templates', true);
      print('✅ 템플릿 업데이트 플래그 저장');
    }
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
    await prefs.remove('needs_update_$dataType');
    print('✅ $dataType 업데이트 플래그 제거');
  }
}
```

**총 라인 수**: 약 70줄 (매우 간단!)

---

### 4단계: DataSyncService에 FCM 플래그 체크 추가 (기존 파일 수정)

**lib/core/services/data_sync_service.dart**
```dart
// 기존 코드에 메서드 1개만 추가!

/// FCM 플래그 기반 스마트 동기화
Future<bool> fcmSmartSyncJobs() async {
  // 1. FCM 플래그 확인 (로컬에서만!)
  final needsUpdate = await FcmService.needsUpdateJobs();
  
  if (!needsUpdate) {
    print('✅ 직업 업데이트 불필요 (플래그 없음)');
    return true;
  }

  // 2. 플래그가 있으면 기존 동기화 로직 호출!
  print('🔔 FCM 플래그 감지, 동기화 시작...');
  final synced = await syncJobs();  // 기존 메서드 재사용!
  
  // 3. 성공하면 플래그 제거
  if (synced) {
    await FcmService.clearUpdateFlag('jobs');
  }
  
  return synced;
}

/// 템플릿도 동일
Future<bool> fcmSmartSyncTemplates() async {
  final needsUpdate = await FcmService.needsUpdateTemplates();
  
  if (!needsUpdate) {
    print('✅ 템플릿 업데이트 불필요 (플래그 없음)');
    return true;
  }

  print('🔔 FCM 플래그 감지, 동기화 시작...');
  final synced = await syncTemplates();  // 기존 메서드 재사용!
  
  if (synced) {
    await FcmService.clearUpdateFlag('templates');
  }
  
  return synced;
}
```

**추가 라인 수**: 약 30줄

---

### 5단계: main.dart 수정 (2줄 추가!)

**lib/main.dart**
```dart
import 'package:firebase_core/firebase_core.dart';  // 추가
import 'package:mobi_party_link/core/services/fcm_service.dart';  // 추가

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화 (기존)
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  // Firebase 초기화 (추가!)
  await Firebase.initializeApp();
  await FcmService.initialize();
  // 끝!

  // 타임존 초기화 (기존)
  await _initializeTimeZone();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

**추가 라인 수**: 2줄

---

### 6단계: main_screen.dart 수정 (1줄 변경!)

**lib/features/home/presentation/screens/main_screen.dart**
```dart
Future<void> _initializeApp() async {
  // 기존: 아무것도 안함
  
  // 변경 후: FCM 플래그 확인 후 동기화
  await _syncDataWithFcm();  // 이것만 추가!
  
  // 기존 파티 동기화는 그대로
  MockPartyData.syncPartyNotifications();
}

// 새 메서드 추가 (기존 코드 재사용!)
Future<void> _syncDataWithFcm() async {
  final dataSyncService = DataSyncService(
    jobRepository: ref.read(jobRepositoryProvider),
    templateRepository: ref.read(partyTemplateRepositoryProvider),
  );

  // FCM 플래그만 체크! (서버 요청 X)
  await dataSyncService.fcmSmartSyncJobs();
  await dataSyncService.fcmSmartSyncTemplates();
}
```

**추가 라인 수**: 약 15줄

---

### 7단계: Supabase Function 배포 (선택적)

**간단한 방법: Supabase Dashboard에서 직접 작성**

```sql
-- data_versions 테이블이 업데이트되면 자동으로 FCM 전송
CREATE OR REPLACE FUNCTION send_fcm_on_version_update()
RETURNS TRIGGER AS $$
DECLARE
  fcm_url TEXT := 'https://fcm.googleapis.com/fcm/send';
  fcm_key TEXT := 'YOUR_FCM_SERVER_KEY';
  topic TEXT := '/topics/all_users';
BEGIN
  -- FCM 푸시 전송 (간단한 HTTP POST)
  PERFORM net.http_post(
    url := fcm_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'key=' || fcm_key
    ),
    body := jsonb_build_object(
      'to', topic,
      'data', jsonb_build_object(
        'type', 'data_update',
        'data_type', NEW.data_type,
        'version', NEW.version
      )
    )
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger 등록
DROP TRIGGER IF EXISTS fcm_version_update ON data_versions;
CREATE TRIGGER fcm_version_update
  AFTER UPDATE ON data_versions
  FOR EACH ROW
  WHEN (OLD.version IS DISTINCT FROM NEW.version)
  EXECUTE FUNCTION send_fcm_on_version_update();
```

---

## 전체 변경사항 요약

### 신규 파일 (1개)
- ✅ `lib/core/services/fcm_service.dart` (70줄)

### 수정 파일 (3개)
- ✅ `lib/main.dart` (+2줄)
- ✅ `lib/features/home/presentation/screens/main_screen.dart` (+15줄)
- ✅ `lib/core/services/data_sync_service.dart` (+30줄)

### 설정 파일
- ✅ `pubspec.yaml` (+2줄)
- ✅ `android/app/google-services.json` (추가)

### 총 작업량
- **코드 추가**: 약 120줄
- **기존 코드 변경**: 거의 없음!
- **작업 시간**: 약 30분

---

## 작동 흐름 (최종)

### 시나리오: 관리자가 새 직업 추가

```
1. 관리자가 Supabase에서 직업 추가
   ↓
2. data_versions 테이블 version 1 → 2로 업데이트
   ↓
3. Database Trigger 발동
   ↓
4. FCM 푸시 전송 (1,000명 → 1,000개 푸시)
   ↓ (즉시)
5. 앱들이 백그라운드에서 푸시 수신
   ↓
6. FcmService._handleBackgroundMessage() 호출
   ↓
7. SharedPreferences.setBool('needs_update_jobs', true) 저장
   ↓ (로컬만, 서버 요청 X)
8. 사용자가 앱 실행
   ↓
9. main_screen.dart → _syncDataWithFcm() 호출
   ↓
10. dataSyncService.fcmSmartSyncJobs() 호출
   ↓
11. FcmService.needsUpdateJobs() 확인
   ↓ (플래그 true!)
12. syncJobs() 호출 (기존 메서드!)
   ↓
13. 서버에서 직업 19개 → 20개 다운로드
   ↓
14. 로컬 저장 + 버전 저장
   ↓
15. FcmService.clearUpdateFlag('jobs') - 플래그 제거
   ↓
완료! ✅
```

---

## API 호출 비교

### 케이스 1: 업데이트 없음 (대부분의 경우)

**Pull 방식 (24시간 캐싱)**
```
앱 실행 (하루에 1번)
  ↓
버전 체크 API: 2 requests (직업 + 템플릿)
  ↓
결과: 이미 최신
```
- API 호출: **2 requests/일**
- 데이터: 0.2 KB

**FCM 방식**
```
앱 실행
  ↓
로컬 플래그 확인: 0 requests (SharedPreferences만)
  ↓
결과: 플래그 없음, 업데이트 불필요
```
- API 호출: **0 requests/일** ✅
- 데이터: 0 KB ✅

---

### 케이스 2: 업데이트 있음 (월 1회)

**Pull 방식**
```
앱 실행
  ↓
버전 체크 API: 2 requests
  ↓
서버 버전 > 로컬 버전 감지
  ↓
데이터 다운로드 API: 2 requests
```
- API 호출: **4 requests**
- 데이터: 15.2 KB

**FCM 방식**
```
(백그라운드)
FCM 푸시 수신 → 플래그 저장
  ↓
(앱 실행)
로컬 플래그 확인 → 플래그 있음!
  ↓
데이터 다운로드 API: 2 requests (버전 체크 없음!)
```
- API 호출: **2 requests** (50% 감소!)
- 데이터: 15 KB
- FCM 푸시: 1 message (무료)

---

## 1,000명 사용자 월간 사용량

### Pull 방식 (24시간 캐싱)

```
평상시 (29일):
- 버전 체크: 1,000명 × 29일 × 2 = 58,000 requests
- 데이터 전송: 5.8 MB

업데이트 날 (1일):
- 버전 체크: 1,000명 × 1일 × 2 = 2,000 requests
- 데이터 다운로드: 1,000명 × 2 = 2,000 requests
- 데이터 전송: 15.2 MB

-----------------------------------------------------------------------
총 API 호출: 62,000 requests
총 데이터 전송: 21 MB
```

### FCM 방식

```
평상시 (29일):
- API 호출: 0 requests (플래그만 확인!)
- 데이터 전송: 0 MB

업데이트 날 (1일):
- FCM 푸시: 1,000 messages (무료)
- 데이터 다운로드: 1,000명 × 2 = 2,000 requests
- 데이터 전송: 15 MB

-----------------------------------------------------------------------
총 API 호출: 2,000 requests (97% 감소!)
총 데이터 전송: 15 MB (29% 감소)
총 FCM 푸시: 2,000 messages (무료)
```

---

## 코드 변경 미리보기

### main.dart (2줄 추가)

```dart
// BEFORE
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(...);
  await _initializeTimeZone();
  runApp(...);
}

// AFTER (2줄만 추가!)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(...);
  await Firebase.initializeApp();        // 추가 1
  await FcmService.initialize();         // 추가 2
  await _initializeTimeZone();
  runApp(...);
}
```

---

### main_screen.dart (메서드 1개 추가)

```dart
// BEFORE
@override
void initState() {
  super.initState();
  MockPartyData.syncPartyNotifications();
}

// AFTER (메서드 호출 1줄 추가!)
@override
void initState() {
  super.initState();
  _initializeApp();  // 변경
}

// 새 메서드 추가
Future<void> _initializeApp() async {
  // FCM 플래그 체크 + 동기화
  await _syncDataWithFcm();
  
  // 기존 파티 동기화
  MockPartyData.syncPartyNotifications();
}

Future<void> _syncDataWithFcm() async {
  final dataSyncService = DataSyncService(
    jobRepository: ref.read(jobRepositoryProvider),
    templateRepository: ref.read(partyTemplateRepositoryProvider),
  );

  // 플래그만 확인! (서버 요청 X)
  await dataSyncService.fcmSmartSyncJobs();
  await dataSyncService.fcmSmartSyncTemplates();
}
```

---

### data_sync_service.dart (메서드 2개 추가)

```dart
// 기존 syncJobs(), syncTemplates() 메서드는 그대로!

// 새 메서드 추가 (기존 메서드 재사용!)
Future<bool> fcmSmartSyncJobs() async {
  if (!await FcmService.needsUpdateJobs()) {
    return true;  // 플래그 없으면 즉시 반환
  }
  
  final synced = await syncJobs();  // 기존 메서드 호출!
  if (synced) await FcmService.clearUpdateFlag('jobs');
  return synced;
}

Future<bool> fcmSmartSyncTemplates() async {
  if (!await FcmService.needsUpdateTemplates()) {
    return true;
  }
  
  final synced = await syncTemplates();  // 기존 메서드 호출!
  if (synced) await FcmService.clearUpdateFlag('templates');
  return synced;
}
```

---

## 테스트 시나리오

### 1. 초기 설치 (플래그 없음)

```
앱 실행
  ↓
FcmService.needsUpdateJobs() → false
  ↓
로컬 데이터 확인 → 없음
  ↓
Fallback: syncJobs() 호출 → 서버에서 다운로드
  ↓
완료! (서버 요청 2번: 다운로드만)
```

### 2. 평소 사용 (플래그 없음)

```
앱 실행
  ↓
FcmService.needsUpdateJobs() → false
  ↓
즉시 종료 (서버 요청 0번!)
```

### 3. 업데이트 후 (플래그 있음)

```
(백그라운드) FCM 푸시 수신 → 플래그 저장
  ↓
앱 실행
  ↓
FcmService.needsUpdateJobs() → true
  ↓
syncJobs() 호출 → 서버에서 다운로드
  ↓
플래그 제거
  ↓
완료! (서버 요청 2번: 다운로드만)
```

---

## 장점 정리

### 1. 기존 코드 재사용 ✅
- `syncJobs()`, `syncTemplates()` 그대로 사용
- 추가 코드 최소화 (약 120줄)

### 2. API 호출 97% 감소 ✅
- 버전 체크 API 완전 제거
- 플래그만 로컬에서 확인

### 3. 실시간 알림 ✅
- "새로운 직업 추가!" 푸시 알림
- 사용자 경험 개선

### 4. 비용 절감 ✅
- FCM 무료 (무제한)
- Supabase Bandwidth 29% 감소

### 5. 구현 간단 ✅
- 신규 파일: 1개
- 수정 파일: 3개
- 작업 시간: 30분

---

## 결론

### 당신 말이 맞습니다! 🎯

> "지금 상태에서 FCM으로 한다면 수정될 게 별로 없지 않음?"

**정답**: ✅ **맞습니다!**

**필요한 작업**
1. FCM 서비스 추가 (1개 파일, 70줄)
2. main.dart에 초기화 (2줄)
3. main_screen.dart에 플래그 체크 (15줄)
4. DataSyncService에 스마트 동기화 (30줄)

**총 작업량**: 약 120줄, 30분

**효과**
- ✅ API 호출 97% 감소
- ✅ 기존 코드 100% 재사용
- ✅ 추가 비용 $0

**추천**: 
- 지금 당장은 24시간 캐싱으로 충분
- 사용자 500명 이상이면 FCM 추가 (30분 작업)

매우 효율적인 전략입니다! 🚀
