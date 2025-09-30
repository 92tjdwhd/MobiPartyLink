# 🚀 Supabase Edge Function 배포 가이드

## 준비물

1. ✅ Firebase 서비스 계정 키 JSON 파일
2. ✅ Supabase CLI

---

## Step 1: Supabase CLI 설치

```bash
# Homebrew로 설치 (macOS)
brew install supabase/tap/supabase

# 또는 npm으로 설치
npm install -g supabase
```

**설치 확인**:
```bash
supabase --version
```

---

## Step 2: Supabase 로그인

```bash
supabase login
```

브라우저가 열리면 로그인하세요.

---

## Step 3: Supabase 프로젝트 연결

```bash
cd /Users/ideaware/flutter/mobi_party_link

# 프로젝트 초기화 (이미 되어있을 수 있음)
supabase init

# 프로젝트 연결
supabase link --project-ref qpauuwmflnvdnnfctjyx
```

---

## Step 4: Firebase 서비스 계정 키를 Supabase Secret으로 설정

### 4-1. JSON 파일 내용 복사

다운로드한 Firebase 서비스 계정 키 JSON 파일을 열어서 **전체 내용**을 복사하세요.

```json
{
  "type": "service_account",
  "project_id": "mobi-party-link",
  ...
}
```

### 4-2. Secret 설정

**방법 1: Supabase Dashboard (권장)**

```
Supabase Dashboard
→ 프로젝트: qpauuwmflnvdnnfctjyx
→ Edge Functions
→ Secrets
→ "New secret" 버튼 클릭

Secret name: FIREBASE_SERVICE_ACCOUNT_KEY
Secret value: (JSON 전체 내용 붙여넣기)

→ Save
```

**방법 2: CLI로 설정**

```bash
# JSON 파일이 ~/Downloads/mobi-party-link-xxxxx.json 에 있다면
cat ~/Downloads/mobi-party-link-xxxxx.json | supabase secrets set FIREBASE_SERVICE_ACCOUNT_KEY --project-ref qpauuwmflnvdnnfctjyx
```

---

## Step 5: Edge Function 배포

```bash
cd /Users/ideaware/flutter/mobi_party_link

# Edge Function 배포
supabase functions deploy send-fcm-push --project-ref qpauuwmflnvdnnfctjyx
```

**예상 출력**:
```
Deploying Function send-fcm-push (project ref: qpauuwmflnvdnnfctjyx)
✓ Deployed send-fcm-push
Function URL: https://qpauuwmflnvdnnfctjyx.supabase.co/functions/v1/send-fcm-push
```

---

## Step 6: Edge Function 테스트

### 6-1. 수동 테스트 (cURL)

```bash
curl -X POST https://qpauuwmflnvdnnfctjyx.supabase.co/functions/v1/send-fcm-push \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwYXV1d21mbG52ZG5uZmN0anl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY4OTczMzUsImV4cCI6MjA0MjQ3MzMzNX0.g5v8bXpvk2_zMR8ib9rbx15Ik6h_YxW6FrK_RN-u_LM" \
  -H "Content-Type: application/json" \
  -d '{"data_type": "jobs", "version": "2"}'
```

**예상 응답**:
```json
{
  "success": true,
  "data_type": "jobs",
  "version": "2",
  "message_id": "projects/mobi-party-link/messages/abc123"
}
```

**앱에서 확인**:
```
📬 포그라운드 FCM 수신
✅ 직업 업데이트 플래그 저장 (v2)
```

---

## Step 7: Supabase Database Trigger 생성

### 7-1. Supabase SQL Editor

```
Supabase Dashboard
→ SQL Editor
→ New query
```

### 7-2. Trigger SQL 실행

```sql
-- Database Trigger: data_versions 업데이트 시 Edge Function 호출
CREATE OR REPLACE FUNCTION trigger_fcm_edge_function()
RETURNS TRIGGER AS $$
DECLARE
  function_url TEXT := 'https://qpauuwmflnvdnnfctjyx.supabase.co/functions/v1/send-fcm-push';
  anon_key TEXT := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwYXV1d21mbG52ZG5uZmN0anl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY4OTczMzUsImV4cCI6MjA0MjQ3MzMzNX0.g5v8bXpvk2_zMR8ib9rbx15Ik6h_YxW6FrK_RN-u_LM';
  http_response net.http_response_result;
BEGIN
  -- Edge Function 호출
  SELECT * INTO http_response FROM net.http_post(
    url := function_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || anon_key
    ),
    body := jsonb_build_object(
      'data_type', NEW.data_type,
      'version', NEW.version,
      'updated_at', NEW.last_updated
    )::text
  );
  
  -- 로그
  RAISE NOTICE '✅ FCM Edge Function 호출 완료: % v% (상태: %)', 
    NEW.data_type, 
    NEW.version,
    http_response.status;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING '❌ Edge Function 호출 실패: % (에러: %)', NEW.data_type, SQLERRM;
    RETURN NEW;  -- 에러가 발생해도 업데이트는 계속 진행
END;
$$ LANGUAGE plpgsql;

-- 기존 Trigger 삭제
DROP TRIGGER IF EXISTS fcm_auto_push_trigger ON data_versions;

-- 새 Trigger 생성
CREATE TRIGGER fcm_auto_push_trigger
  AFTER UPDATE ON data_versions
  FOR EACH ROW
  WHEN (OLD.version IS DISTINCT FROM NEW.version)
  EXECUTE FUNCTION trigger_fcm_edge_function();

-- 확인
SELECT trigger_name, event_object_table 
FROM information_schema.triggers 
WHERE trigger_name = 'fcm_auto_push_trigger';
```

**Run 버튼 클릭!**

---

## Step 8: 전체 자동화 테스트

### 8-1. Supabase에서 버전 업데이트

```
Supabase Dashboard
→ Table Editor
→ data_versions 테이블
→ jobs 행 편집
→ version: 1 → 2
→ Save
```

### 8-2. 예상 흐름

```
1. version 업데이트 저장
   ↓ (즉시)
2. Database Trigger 발동
   ↓
3. trigger_fcm_edge_function() 실행
   ↓
4. Edge Function 호출
   ↓
5. send-fcm-push Function 실행
   ↓
6. OAuth 토큰 생성
   ↓
7. FCM v1 API 호출
   ↓
8. 전체 사용자에게 푸시 전송!
   ↓
9. 앱에서 수신 → 플래그 저장
```

### 8-3. 로그 확인

**Supabase Logs** (Dashboard → Logs → Edge Function Logs):
```
📬 FCM 푸시 요청 수신
📤 FCM 전송 준비: jobs v2
🚀 FCM API 호출 중...
✅ FCM 전송 성공: {name: "projects/mobi-party-link/messages/..."}
```

**앱 로그**:
```
📬 포그라운드 FCM 수신: abc123
   제목: 새로운 직업 추가!
   내용: 새로운 직업이 추가되었습니다 🎮
   데이터: {type: data_update, data_type: jobs, version: 2}
✅ 직업 업데이트 플래그 저장 (v2)
```

---

## ✅ 완료!

이제 Supabase에서 버전만 업데이트하면 자동으로 FCM이 전송됩니다!

**완전 자동화 흐름**:
```
관리자가 데이터 업데이트
  ↓ (1초 이내)
Database Trigger → Edge Function → FCM API
  ↓ (즉시)
전체 사용자에게 푸시 전송!
  ↓
앱에서 플래그 저장
  ↓ (사용자가 앱 실행 시)
자동 동기화!
```

---

## 문제 해결

### Edge Function 배포 실패

```
Error: Failed to deploy function
```

**해결**:
1. `supabase login` 다시 실행
2. 프로젝트 ref 확인: `qpauuwmflnvdnnfctjyx`

### Secret 설정 안됨

```
❌ FIREBASE_SERVICE_ACCOUNT_KEY 환경 변수가 설정되지 않았습니다
```

**해결**: Supabase Dashboard → Edge Functions → Secrets 확인

### OAuth 토큰 에러

```
OAuth token fetch failed
```

**해결**: 서비스 계정 키 JSON이 올바른지 확인

---

## 비용

- ✅ Edge Function: 무료 (500,000회/월)
- ✅ FCM: 무료 (무제한)
- ✅ 총 비용: $0

---

## 다음 단계

1. Supabase CLI 설치
2. 서비스 계정 키를 Secret으로 설정
3. Edge Function 배포
4. Database Trigger 생성
5. 테스트!

준비되셨으면 시작하겠습니다! 🚀
