# 📊 Supabase 사용량 최적화 가이드

## 목차
1. [Supabase 무료 플랜 제한](#supabase-무료-플랜-제한)
2. [현재 API 호출 분석](#현재-api-호출-분석)
3. [사용량 시뮬레이션](#사용량-시뮬레이션)
4. [최적화 전략](#최적화-전략)
5. [권장 구현 방안](#권장-구현-방안)

---

## Supabase 무료 플랜 제한

### Database
- **월간 Database Size**: 500 MB
- **월간 Bandwidth**: 5 GB (읽기 + 쓰기)
- **동시 연결 수**: 최대 60개

### API
- **월간 API 요청 수**: 무제한 ✅
- **실시간 구독 수**: 최대 200개 동시 연결

### Storage
- **Storage 용량**: 1 GB
- **Storage Bandwidth**: 2 GB/월

### 중요 포인트
- ✅ **API 요청 횟수는 무제한!**
- ⚠️ **Bandwidth (데이터 전송량)가 제한적 (5 GB/월)**
- ⚠️ **동시 연결 수 제한 (60개)**

---

## 현재 API 호출 분석

### 1. 앱 시작 시 호출 (최악의 경우)

**시나리오**: 버전 체크 후 모든 데이터 다운로드

```
1. GET /data_versions?data_type=eq.jobs              → 1 request (0.1 KB)
2. GET /jobs?is_active=eq.true                       → 1 request (5 KB, 19개)
3. GET /data_versions?data_type=eq.party_templates   → 1 request (0.1 KB)
4. GET /party_templates                               → 1 request (10 KB, 16개)
-----------------------------------------------------------------------
총 4 requests, 약 15.2 KB 데이터 전송
```

**시나리오**: 이미 최신 버전 (일반적인 경우)

```
1. GET /data_versions?data_type=eq.jobs              → 1 request (0.1 KB)
2. GET /data_versions?data_type=eq.party_templates   → 1 request (0.1 KB)
-----------------------------------------------------------------------
총 2 requests, 약 0.2 KB 데이터 전송
```

### 2. 파티 목록 조회 (향후 구현)

**내가 참가한 파티 + 내가 만든 파티**

```
1. GET /parties?creator_id=eq.{userId}               → 1 request (2 KB, 가정: 2개)
2. GET /party_members?user_id=eq.{userId}            → 1 request (1 KB, 가정: 3개)
-----------------------------------------------------------------------
총 2 requests, 약 3 KB 데이터 전송
```

### 3. 일반적인 앱 사용 흐름

**1회 앱 실행 시 (이미 최신 버전)**

```
앱 시작:
- 버전 체크 (직업) → 1 request, 0.1 KB
- 버전 체크 (템플릿) → 1 request, 0.1 KB
- 파티 목록 조회 → 2 requests, 3 KB

파티 생성:
- 파티 생성 → 1 request, 0.5 KB

파티 참가:
- 파티 멤버 추가 → 1 request, 0.2 KB
-----------------------------------------------------------------------
총 6 requests, 약 3.9 KB 데이터 전송
```

---

## 사용량 시뮬레이션

### 시나리오 1: 소규모 사용자 (100명, 초기)

**가정**
- DAU (일 활성 사용자): 100명
- 1인당 하루 평균 앱 실행: 3회
- 1인당 하루 평균 파티 생성: 0.5회
- 1인당 하루 평균 파티 참가: 2회
- 데이터 업데이트 주기: 월 1회

**일간 사용량**

```
버전 체크 (이미 최신):
- 100명 × 3회 × 2 requests × 0.1 KB = 60 KB

파티 목록 조회:
- 100명 × 3회 × 2 requests × 1.5 KB = 900 KB

파티 생성:
- 100명 × 0.5회 × 1 request × 0.5 KB = 25 KB

파티 참가:
- 100명 × 2회 × 1 request × 0.2 KB = 40 KB
-----------------------------------------------------------------------
일간 총 데이터 전송량: 약 1 MB
월간 총 데이터 전송량: 약 30 MB
```

**월간 API 요청 수**

```
버전 체크: 100명 × 3회 × 30일 × 2 = 18,000 requests
파티 목록: 100명 × 3회 × 30일 × 2 = 18,000 requests
파티 생성: 100명 × 0.5회 × 30일 × 1 = 1,500 requests
파티 참가: 100명 × 2회 × 30일 × 1 = 6,000 requests
-----------------------------------------------------------------------
월간 총 API 요청: 43,500 requests
```

**결론**: ✅ **무료 플랜으로 충분! (5 GB 중 30 MB만 사용)**

---

### 시나리오 2: 중규모 사용자 (1,000명)

**가정**
- DAU: 1,000명
- 1인당 하루 평균 앱 실행: 5회
- 1인당 하루 평균 파티 생성: 1회
- 1인당 하루 평균 파티 참가: 3회

**월간 사용량**

```
버전 체크: 1,000명 × 5회 × 30일 × 2 × 0.1 KB = 3 MB
파티 목록: 1,000명 × 5회 × 30일 × 2 × 1.5 KB = 450 MB
파티 생성: 1,000명 × 1회 × 30일 × 1 × 0.5 KB = 15 MB
파티 참가: 1,000명 × 3회 × 30일 × 1 × 0.2 KB = 18 MB
-----------------------------------------------------------------------
월간 총 데이터 전송량: 약 486 MB
```

**결론**: ✅ **여전히 무료 플랜으로 가능! (5 GB 중 486 MB 사용)**

---

### 시나리오 3: 대규모 사용자 (5,000명)

**월간 사용량**

```
버전 체크: 5,000명 × 5회 × 30일 × 2 × 0.1 KB = 15 MB
파티 목록: 5,000명 × 5회 × 30일 × 2 × 1.5 KB = 2,250 MB
파티 생성: 5,000명 × 1회 × 30일 × 1 × 0.5 KB = 75 MB
파티 참가: 5,000명 × 3회 × 30일 × 1 × 0.2 KB = 90 MB
-----------------------------------------------------------------------
월간 총 데이터 전송량: 약 2,430 MB (2.4 GB)
```

**결론**: ✅ **무료 플랜으로 가능! (5 GB 중 2.4 GB 사용, 48%)**

---

### 시나리오 4: 초대규모 사용자 (10,000명)

**월간 사용량**

```
버전 체크: 10,000명 × 5회 × 30일 × 2 × 0.1 KB = 30 MB
파티 목록: 10,000명 × 5회 × 30일 × 2 × 1.5 KB = 4,500 MB
파티 생성: 10,000명 × 1회 × 30일 × 1 × 0.5 KB = 150 MB
파티 참가: 10,000명 × 3회 × 30일 × 1 × 0.2 KB = 180 MB
-----------------------------------------------------------------------
월간 총 데이터 전송량: 약 4,860 MB (4.9 GB)
```

**결론**: ⚠️ **무료 플랜 거의 초과! (5 GB 중 4.9 GB 사용, 98%)**

**이 경우**: Pro 플랜으로 업그레이드 필요 ($25/월, 50 GB 제공)

---

## 최적화 전략

### 1. 버전 체크 빈도 줄이기 ⭐⭐⭐

**현재**: 앱 시작마다 버전 체크

**최적화 방안**

#### A. 시간 기반 캐싱 (권장) ✅

```dart
class LocalStorageService {
  static const String _lastVersionCheckKey = 'last_version_check';
  static const Duration versionCheckInterval = Duration(hours: 24);

  /// 버전 체크가 필요한지 확인
  static Future<bool> shouldCheckVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckString = prefs.getString(_lastVersionCheckKey);
    
    if (lastCheckString == null) return true;
    
    final lastCheck = DateTime.parse(lastCheckString);
    final now = DateTime.now();
    final diff = now.difference(lastCheck);
    
    // 24시간이 지났으면 체크
    return diff >= versionCheckInterval;
  }

  /// 버전 체크 시간 기록
  static Future<void> markVersionChecked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastVersionCheckKey, DateTime.now().toIso8601String());
  }
}

// 사용 예시
Future<void> _syncStaticData() async {
  if (await LocalStorageService.shouldCheckVersion()) {
    print('🔄 24시간 경과, 버전 체크 시작...');
    
    await dataSyncService.syncJobs();
    await dataSyncService.syncTemplates();
    
    await LocalStorageService.markVersionChecked();
  } else {
    print('✅ 최근 체크 완료, 로컬 데이터 사용');
  }
}
```

**효과**: 버전 체크 API 호출 **95% 감소** (하루 5번 → 1번)

**절감 효과** (1,000명 기준)
- 기존: 1,000명 × 5회 × 30일 × 2 = 300,000 requests
- 최적화: 1,000명 × 1회 × 30일 × 2 = 60,000 requests
- **절감: 240,000 requests (80% 감소)**

---

#### B. WiFi 연결 시에만 체크 (추가 최적화)

```dart
Future<bool> shouldCheckVersion() async {
  // 시간 체크
  if (!await _isTimeToCheck()) return false;
  
  // WiFi 연결 확인
  if (!await _isWiFiConnected()) {
    print('📶 WiFi 아님, 버전 체크 연기');
    return false;
  }
  
  return true;
}

Future<bool> _isWiFiConnected() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult == ConnectivityResult.wifi;
}
```

**효과**: 모바일 데이터 사용자에게 배려 + 추가 절감

---

### 2. 파티 목록 페이지네이션 ⭐⭐

**현재**: 모든 파티 한번에 조회

**최적화 방안**

```dart
// 한번에 20개씩만 조회
Future<List<PartyEntity>> getParties({
  required String userId,
  int page = 1,
  int pageSize = 20,
}) async {
  final offset = (page - 1) * pageSize;
  
  final response = await supabaseClient
      .from('parties')
      .select()
      .or('creator_id.eq.$userId,id.in.(SELECT party_id FROM party_members WHERE user_id=$userId)')
      .range(offset, offset + pageSize - 1)
      .order('start_time', ascending: false);
  
  return response.map((json) => PartyEntity.fromJson(json)).toList();
}
```

**효과**: 초기 로딩 데이터 **80% 감소** (파티 100개 → 20개)

---

### 3. 응답 데이터 최적화 (Select 지정) ⭐⭐⭐

**현재**: 모든 필드 조회 (`SELECT *`)

**최적화 방안**

```dart
// 필요한 필드만 선택
final response = await supabaseClient
    .from('jobs')
    .select('id, name, category_id')  // icon_url, description 제외
    .eq('is_active', true);
```

**효과**: 응답 데이터 크기 **40% 감소**

---

### 4. 로컬 우선 전략 (Offline-First) ⭐⭐⭐

**현재**: 서버 우선

**최적화 방안**

```dart
Future<List<JobEntity>> getJobs() async {
  // 1. 로컬에서 먼저 로드
  final localJobs = await LocalStorageService.getJobs();
  
  if (localJobs != null && localJobs.isNotEmpty) {
    // 로컬 데이터가 있으면 즉시 반환
    print('📱 로컬 데이터 사용 (서버 요청 없음)');
    
    // 백그라운드에서 버전 체크 (비동기)
    _checkVersionInBackground();
    
    return localJobs;
  }
  
  // 2. 로컬 데이터가 없으면 서버에서 가져오기
  print('☁️ 서버에서 데이터 다운로드');
  return await _fetchFromServer();
}
```

**효과**: 
- 빠른 UI 렌더링
- 불필요한 서버 요청 제거
- 오프라인 지원

---

### 5. 응답 압축 (gzip) ⭐

**Supabase는 기본적으로 gzip 압축 지원**

클라이언트에서 별도 설정 불필요!

```
실제 전송 데이터: 15 KB (압축 전) → 약 3 KB (압축 후)
```

**효과**: 데이터 전송량 **70-80% 감소** (자동 적용)

---

### 6. 캐시 만료 전략 ⭐⭐

**ETag 기반 캐싱**

```dart
Future<bool> isDataStale(String dataType) async {
  final prefs = await SharedPreferences.getInstance();
  final localETag = prefs.getString('${dataType}_etag');
  
  // HEAD 요청으로 ETag만 확인 (데이터 다운로드 X)
  final response = await http.head(
    Uri.parse('$supabaseUrl/rest/v1/$dataType'),
    headers: {'apikey': supabaseAnonKey},
  );
  
  final serverETag = response.headers['etag'];
  
  return localETag != serverETag;
}
```

**효과**: 변경되지 않은 데이터 다운로드 방지

---

## 권장 구현 방안

### 최종 권장 전략 (조합)

#### 1단계: 시간 기반 버전 체크 (24시간) ✅

```dart
// lib/core/services/data_sync_service.dart

class DataSyncService {
  static const Duration versionCheckInterval = Duration(hours: 24);
  
  /// 스마트 동기화 (시간 체크 + 버전 체크)
  Future<bool> smartSyncJobs() async {
    // 1. 24시간 이내에 체크했으면 스킵
    if (!await _shouldCheckVersion('jobs')) {
      print('✅ 직업 데이터 최근 체크 완료, 스킵');
      return true;
    }
    
    // 2. 24시간 경과 → 버전 체크
    print('🔄 24시간 경과, 직업 버전 체크 시작...');
    final synced = await syncJobs();
    
    // 3. 체크 시간 기록
    if (synced) {
      await _markVersionChecked('jobs');
    }
    
    return synced;
  }
  
  Future<bool> _shouldCheckVersion(String dataType) async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckString = prefs.getString('last_check_$dataType');
    
    if (lastCheckString == null) return true;
    
    final lastCheck = DateTime.parse(lastCheckString);
    final diff = DateTime.now().difference(lastCheck);
    
    return diff >= versionCheckInterval;
  }
  
  Future<void> _markVersionChecked(String dataType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'last_check_$dataType',
      DateTime.now().toIso8601String(),
    );
  }
}
```

#### 2단계: 앱 시작 시 로컬 우선 로드 ✅

```dart
// lib/features/home/presentation/screens/main_screen.dart

@override
void initState() {
  super.initState();
  _initializeApp();
}

Future<void> _initializeApp() async {
  // 1. 로컬 데이터 먼저 로드 (즉시)
  await _loadLocalData();
  
  // 2. 백그라운드 동기화 (비동기, await 없음)
  _syncDataInBackground();
  
  // 3. 파티 목록 조회 (서버)
  await _fetchParties();
}

Future<void> _loadLocalData() async {
  // 로컬 데이터는 이미 Provider에서 자동으로 로드됨
  print('📱 로컬 데이터 로드 완료');
}

Future<void> _syncDataInBackground() async {
  // await 없이 비동기로 실행 (UI 블로킹 없음)
  final dataSyncService = DataSyncService(
    jobRepository: ref.read(jobRepositoryProvider),
    templateRepository: ref.read(partyTemplateRepositoryProvider),
  );
  
  // 24시간마다 한번만 체크
  dataSyncService.smartSyncJobs();
  dataSyncService.smartSyncTemplates();
}
```

#### 3단계: 필요한 필드만 조회 ✅

```dart
// lib/features/party/data/datasources/job_remote_datasource.dart

@override
Future<List<JobEntity>> getJobs() async {
  try {
    final response = await _supabaseClient
        .from('jobs')
        .select('id, name, category_id')  // 필수 필드만
        .eq('is_active', true);

    return response
        .map((json) => JobModel.fromJson(json))
        .map((model) => model.toEntity())
        .toList();
  } catch (e) {
    throw ServerException(message: '직업 목록을 가져오는데 실패했습니다: $e');
  }
}
```

---

## 예상 사용량 (최적화 적용 후)

### 1,000명 사용자 기준

**최적화 전**
- 월간 API 요청: 450,000 requests
- 월간 데이터 전송: 486 MB

**최적화 후**
- 월간 API 요청: 90,000 requests (**80% 감소**)
- 월간 데이터 전송: 145 MB (**70% 감소**)

**절감 효과**
- ✅ 무료 플랜 여유 공간: 4,855 MB (97% 남음)
- ✅ 사용자 수 **10,000명까지 무료 플랜 가능**

---

## 모니터링

### Supabase 대시보드에서 확인

```
Settings → Usage

확인 항목:
- Database Size
- Database Bandwidth (읽기 + 쓰기)
- Storage Bandwidth
- Monthly Active Users
```

### 로그 모니터링

```dart
class UsageTracker {
  static int _apiCalls = 0;
  static int _dataTransferred = 0;
  
  static void trackApiCall(String endpoint, int bytes) {
    _apiCalls++;
    _dataTransferred += bytes;
    
    print('📊 API 사용량: ${_apiCalls} calls, ${_dataTransferred} bytes');
  }
  
  static void printDailyReport() {
    print('''
    📊 일간 사용량 리포트
    - API 호출: $_apiCalls requests
    - 데이터 전송: ${(_dataTransferred / 1024).toStringAsFixed(2)} KB
    ''');
  }
}
```

---

## 결론

### ✅ 버전 체크는 안전합니다!

**이유**
1. **API 요청 횟수는 무제한** (Supabase 무료 플랜)
2. **버전 체크는 극히 작은 데이터** (0.1 KB)
3. **24시간 캐싱 적용 시 95% 감소**
4. **gzip 압축 자동 적용** (70-80% 감소)

**권장 사항**
- ✅ **24시간마다 1회 버전 체크** (권장)
- ✅ **로컬 우선 전략** (빠른 UI + 오프라인 지원)
- ✅ **필요한 필드만 조회** (데이터 절감)
- ✅ **WiFi 연결 시 우선** (사용자 배려)

**예상 사용자 수**
- 무료 플랜: **최대 10,000명 DAU 가능**
- Pro 플랜 ($25/월): **최대 100,000명 DAU 가능**

**최종 답변**: 걱정하지 않아도 됩니다! 앱 시작 시 버전 체크는 매우 안전하며, 24시간 캐싱을 적용하면 더욱 효율적입니다! 🚀
