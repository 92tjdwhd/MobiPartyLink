# 🚀 Supabase에서 FCM 자동 푸시 전송 설정

## 개요

Supabase의 `data_versions` 테이블이 업데이트되면 자동으로 FCM 푸시를 전송하도록 설정합니다.

---

## Step 1: FCM 서버 키 가져오기

### 1-1. Firebase Console 접속

```
https://console.firebase.google.com/
→ 프로젝트 선택: mobi-party-link
→ 프로젝트 설정 (⚙️)
→ 클라우드 메시징 탭
```

### 1-2. 서버 키 복사

**Cloud Messaging API (Legacy)** 섹션에서:
- **서버 키** 복사
- 형식: `AAAAaBcDeFg:APA91b...`

**⚠️ 이 키는 중요합니다! 안전하게 보관하세요.**

---

## Step 2: Supabase SQL Trigger 생성

### 2-1. Supabase Dashboard 접속

```
https://supabase.com/dashboard
→ 프로젝트 선택: qpauuwmflnvdnnfctjyx
→ SQL Editor
→ New query
```

### 2-2. SQL 스크립트 실행

아래 SQL을 복사해서 붙여넣고 **FCM 서버 키를 입력**한 후 실행하세요:

```sql
-- ============================================
-- FCM 자동 푸시 전송 Trigger
-- ============================================

-- FCM 푸시 전송 함수
CREATE OR REPLACE FUNCTION send_fcm_push_notification()
RETURNS TRIGGER AS $$
DECLARE
  fcm_url TEXT := 'https://fcm.googleapis.com/fcm/send';
  fcm_server_key TEXT := 'YOUR_FCM_SERVER_KEY_HERE';  -- ⚠️ 여기에 FCM 서버 키 입력!
  notification_title TEXT;
  notification_body TEXT;
  topic TEXT := '/topics/all_users';
  http_response net.http_response_result;
BEGIN
  -- FCM 서버 키 확인
  IF fcm_server_key = 'YOUR_FCM_SERVER_KEY_HERE' THEN
    RAISE WARNING '⚠️ FCM 서버 키를 설정해주세요!';
    RETURN NEW;
  END IF;

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

  -- FCM 푸시 전송 (iOS + Android 백그라운드 지원)
  SELECT * INTO http_response FROM net.http_post(
    url := fcm_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'key=' || fcm_server_key
    ),
    body := jsonb_build_object(
      'to', topic,
      'priority', 'high',
      'content_available', true,
      
      -- 데이터 페이로드 (백그라운드에서도 수신!)
      'data', jsonb_build_object(
        'type', 'data_update',
        'data_type', NEW.data_type,
        'version', NEW.version::text,
        'updated_at', NEW.last_updated::text,
        'click_action', 'FLUTTER_NOTIFICATION_CLICK'
      ),
      
      -- 알림 페이로드
      'notification', jsonb_build_object(
        'title', notification_title,
        'body', notification_body,
        'sound', 'default',
        'badge', '1'
      ),
      
      -- Android 전용 설정
      'android', jsonb_build_object(
        'priority', 'high',
        'notification', jsonb_build_object(
          'channel_id', 'data_update_channel',
          'sound', 'default',
          'priority', 'high',
          'default_vibrate_timings', true,
          'notification_count', 1
        )
      ),
      
      -- iOS 전용 설정 (APNS)
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
  
  -- 성공 로그
  RAISE NOTICE '✅ FCM 푸시 전송 완료: % v% (응답: %)', 
    NEW.data_type, 
    NEW.version, 
    http_response.status;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING '❌ FCM 전송 실패: % (에러: %)', NEW.data_type, SQLERRM;
    RETURN NEW;  -- 에러가 발생해도 업데이트는 계속 진행
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

-- Trigger 확인
SELECT 
  trigger_name, 
  event_manipulation, 
  event_object_table,
  action_timing
FROM information_schema.triggers 
WHERE trigger_name = 'fcm_on_version_update';

-- 예상 출력:
-- trigger_name          | event_manipulation | event_object_table | action_timing
-- fcm_on_version_update | UPDATE             | data_versions      | AFTER
```

**⚠️ 중요**: 
1. `YOUR_FCM_SERVER_KEY_HERE`를 실제 FCM 서버 키로 변경!
2. Run 버튼 클릭!

---

## Step 3: Supabase HTTP Extension 활성화

Supabase의 `net.http_post` 함수를 사용하려면 HTTP Extension이 활성화되어 있어야 합니다.

### 3-1. HTTP Extension 확인

```sql
-- Extension 목록 확인
SELECT * FROM pg_available_extensions WHERE name = 'http';
```

### 3-2. HTTP Extension 활성화 (필요 시)

```sql
-- HTTP Extension 활성화
CREATE EXTENSION IF NOT EXISTS http WITH SCHEMA net;
```

---

## Step 4: 테스트

### 4-1. 수동으로 버전 업데이트

```sql
-- 직업 버전 업데이트 (Trigger 발동!)
UPDATE data_versions 
SET version = 2, last_updated = NOW()
WHERE data_type = 'jobs';

-- 예상 로그 (Supabase Logs에서 확인):
-- ✅ FCM 푸시 전송 완료: jobs v2 (응답: 200)
```

### 4-2. 앱에서 확인

**앱이 실행 중이라면 (포그라운드)**:
```
📬 포그라운드 FCM 수신: abc123
   제목: 새로운 직업 추가!
   내용: 새로운 직업이 추가되었습니다 🎮
   데이터: {type: data_update, data_type: jobs, version: 2}
✅ 직업 업데이트 플래그 저장 (v2)
```

**앱이 백그라운드라면**:
```
(시스템 로그)
📬 백그라운드 FCM 수신: abc123
✅ 직업 업데이트 플래그 저장 (v2)
```

**앱 재시작 후**:
```
📌 직업 업데이트 플래그 확인: true (v2)
🔔 FCM 플래그 감지, 직업 동기화 시작...
⬇️ 서버에서 직업 데이터 다운로드 중...
✅ 직업 데이터 20개 다운로드 완료
```

---

## Step 5: Supabase Logs 확인

### 5-1. Logs 메뉴 접속

```
Supabase Dashboard → Logs → Postgres Logs
```

### 5-2. 예상 로그

```
NOTICE: ✅ FCM 푸시 전송 완료: jobs v2 (응답: 200)
```

**또는 에러가 있다면**:
```
WARNING: ❌ FCM 전송 실패: jobs (에러: ...)
```

---

## 전체 흐름 확인

### 관리자가 새 직업 추가 시

```
Step 1: Supabase에서 새 직업 추가
---------------------------------------
Supabase → Table Editor → jobs
→ Insert row
→ 새 직업 정보 입력
→ Save


Step 2: 버전 업데이트
---------------------------------------
Supabase → Table Editor → data_versions
→ jobs 행 편집
→ version: 1 → 2
→ Save

(자동!)
↓
Database Trigger 발동
↓
send_fcm_push_notification() 함수 실행
↓
FCM API 호출 (https://fcm.googleapis.com/fcm/send)
↓
전체 사용자에게 푸시 전송!


Step 3: 사용자 앱에서 자동 처리
---------------------------------------
1. 푸시 수신 (포그라운드/백그라운드 모두)
2. 플래그 저장: needs_update_jobs = true
3. 앱 실행 시 플래그 확인
4. 플래그 있음 → 서버에서 다운로드
5. 로컬 저장 + 플래그 제거
6. 완료! ✅
```

---

## 문제 해결

### 에러 1: HTTP Extension 없음

```
ERROR: function net.http_post does not exist
```

**해결**:
```sql
CREATE EXTENSION IF NOT EXISTS http WITH SCHEMA net;
```

---

### 에러 2: FCM 서버 키 오류

```
WARNING: ⚠️ FCM 서버 키를 설정해주세요!
```

**해결**: SQL의 `fcm_server_key` 변수에 실제 키 입력

---

### 에러 3: FCM 응답 에러

```
WARNING: ❌ FCM 전송 실패: jobs (에러: 401 Unauthorized)
```

**해결**: FCM 서버 키가 올바른지 확인

---

### 에러 4: net.http_post 권한 에러

```
ERROR: permission denied for schema net
```

**해결**: Supabase에서 HTTP Extension은 기본적으로 활성화되어 있어야 합니다.
확인:
```sql
SELECT * FROM pg_extension WHERE extname = 'http';
```

---

## 대안: Supabase Edge Function 사용

만약 `net.http_post`가 작동하지 않으면 Edge Function을 사용할 수 있습니다.

### Edge Function 방식

**1. Function 생성**
```typescript
// supabase/functions/send-fcm/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const FCM_SERVER_KEY = Deno.env.get('FCM_SERVER_KEY')!

serve(async (req) => {
  const { data_type, version } = await req.json()

  const title = data_type === 'jobs' 
    ? '새로운 직업 추가!' 
    : '새로운 템플릿 추가!'
  
  const body = data_type === 'jobs'
    ? '새로운 직업이 추가되었습니다 🎮'
    : '새로운 파티 템플릿이 추가되었습니다 🎉'

  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Authorization': `key=${FCM_SERVER_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      to: '/topics/all_users',
      priority: 'high',
      content_available: true,
      data: {
        type: 'data_update',
        data_type: data_type,
        version: version.toString(),
      },
      notification: {
        title: title,
        body: body,
      },
    }),
  })

  return new Response(JSON.stringify({ success: true }))
})
```

**2. Database Trigger**
```sql
CREATE OR REPLACE FUNCTION trigger_edge_function()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/send-fcm',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer YOUR_SUPABASE_ANON_KEY'
    ),
    body := jsonb_build_object(
      'data_type', NEW.data_type,
      'version', NEW.version
    )::text
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## 완료!

이제 Supabase에서 데이터를 업데이트하면 자동으로 FCM 푸시가 전송됩니다! 🎉

**테스트**:
1. Supabase → data_versions 테이블
2. jobs의 version을 2로 변경
3. 앱에서 푸시 수신 확인!

---

## 다음 문서

**수동 테스트**: `test_fcm_push.js` 또는 `test_fcm_push.sh` 사용
