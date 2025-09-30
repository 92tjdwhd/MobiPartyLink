# FCM Edge Function 사용법

## 개요
Supabase Edge Function을 통해 Firebase Cloud Messaging(FCM) 푸시 알림을 전송하는 방법입니다.

## Edge Function 정보
- **함수명**: `send-fcm-push`
- **URL**: `https://your-project.supabase.co/functions/v1/send-fcm-push`
- **런타임**: Deno (TypeScript/JavaScript)

## 요청 방법

### 1. Supabase Dashboard에서 직접 호출
**Supabase Dashboard → Edge Functions → send-fcm-push → Invoke**

#### Body (JSON):
```json
{
  "data_type": "jobs",
  "version": 4,
  "updated_at": "2025-01-30T10:30:00Z"
}
```

#### 템플릿 업데이트 예시:
```json
{
  "data_type": "templates",
  "version": 3,
  "updated_at": "2025-01-30T10:30:00Z"
}
```

#### Headers, Query Parameters:
- **비워두세요** (자동으로 설정됨)

### 2. HTTP POST 요청으로 호출
```bash
curl -X POST \
  'https://your-project.supabase.co/functions/v1/send-fcm-push' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_SUPABASE_ANON_KEY' \
  -d '{
    "data_type": "jobs",
    "version": 4,
    "updated_at": "2025-01-30T10:30:00Z"
  }'
```

### 3. JavaScript/TypeScript에서 호출
```javascript
const response = await fetch('https://your-project.supabase.co/functions/v1/send-fcm-push', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer YOUR_SUPABASE_ANON_KEY'
  },
  body: JSON.stringify({
    data_type: 'jobs',
    version: 4,
    updated_at: new Date().toISOString()
  })
});

const result = await response.json();
console.log(result);
```

## 응답 형식

### 성공 응답:
```json
{
  "success": true,
  "data_type": "jobs",
  "version": 4,
  "message_id": "projects/your-project/messages/0:1234567890"
}
```

### 실패 응답:
```json
{
  "success": false,
  "error": {
    "code": 400,
    "message": "Invalid JSON payload received",
    "status": "INVALID_ARGUMENT"
  }
}
```

## 파라미터 설명

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `data_type` | string | ✅ | 데이터 타입 (`jobs` 또는 `templates`) |
| `version` | number | ✅ | 버전 번호 |
| `updated_at` | string | ❌ | 업데이트 시간 (ISO 8601 형식) |

## FCM 메시지 내용

### 알림 메시지:
- **직업 업데이트**: "새로운 직업 추가!" / "새로운 직업이 추가되었습니다 🎮"
- **템플릿 업데이트**: "새로운 템플릿 추가!" / "새로운 파티 템플릿이 추가되었습니다 🎉"

### 데이터 페이로드:
```json
{
  "type": "data_update",
  "data_type": "jobs",
  "version": "4",
  "updated_at": "2025-01-30T10:30:00Z",
  "click_action": "FLUTTER_NOTIFICATION_CLICK"
}
```

## 앱에서 확인 방법

1. **앱을 백그라운드로 전송**
2. **Edge Function 호출**
3. **앱을 포그라운드로 가져오기**
4. **로그 확인**:
   ```
   ✅ 직업 업데이트 필요 (FCM 플래그 있음)
   ```

## 주의사항

- **Firebase Service Account Key**가 Supabase 환경변수에 설정되어 있어야 함
- **FCM 토픽**: `all_users`로 전송
- **백그라운드 수신**: 앱이 백그라운드에 있어야 FCM 수신 가능
- **토큰 만료**: OAuth 토큰은 1시간마다 갱신됨

## 트러블슈팅

### 일반적인 에러:
1. **JWT 생성 실패**: Service Account Key 확인
2. **FCM 전송 실패**: Firebase 프로젝트 설정 확인
3. **앱에서 수신 안됨**: FCM 토픽 구독 상태 확인

### 로그 확인:
- **Supabase Dashboard → Logs → Edge Functions**
- **Firebase Console → Cloud Messaging → Reports**
