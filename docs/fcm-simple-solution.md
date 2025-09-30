# 💡 FCM 간단한 해결 방법 (Legacy API 중단 대응)

## 문제

Firebase의 Legacy Server Key API가 2024년부터 중단되고 있습니다.
새로운 FCM HTTP v1 API를 사용해야 합니다.

---

## 🎯 가장 간단한 해결책: Firebase Console에서 수동 전송

### 방법 1: Firebase Console 캠페인 (권장!)

FCM v1 API 토큰 생성이 복잡하므로, **Firebase Console에서 직접 전송**하는 것이 가장 간단합니다.

#### 절차

1. **Firebase Console** 접속
   ```
   https://console.firebase.google.com/
   → mobi-party-link 프로젝트
   → Cloud Messaging
   ```

2. **"첫 번째 캠페인 보내기"** 클릭

3. **"Firebase 알림 메시지"** 선택

4. **알림 작성**
   ```
   알림 제목: 새로운 직업 추가!
   알림 텍스트: 새로운 직업이 추가되었습니다 🎮
   ```

5. **타겟 선택**
   ```
   타겟: 주제
   주제 이름: all_users
   ```

6. **추가 옵션 → 맞춤 데이터**
   ```
   키              값
   type           data_update
   data_type      jobs
   version        2
   ```

7. **검토 → 게시**

**완료!** 🎉

---

## 🔧 방법 2: Admin SDK 사용 (자동화)

Firebase Admin SDK를 사용하면 서버에서 자동으로 FCM을 전송할 수 있습니다.

### Node.js 서버 구현

**fcm_admin_server.js**
```javascript
const admin = require('firebase-admin');
const express = require('express');

// Firebase Admin SDK 초기화
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const app = express();
app.use(express.json());

// FCM 전송 엔드포인트
app.post('/send-fcm', async (req, res) => {
  const { data_type, version } = req.body;

  const message = {
    topic: 'all_users',
    data: {
      type: 'data_update',
      data_type: data_type,
      version: version.toString(),
      updated_at: new Date().toISOString(),
    },
    notification: {
      title: data_type === 'jobs' ? '새로운 직업 추가!' : '새로운 템플릿 추가!',
      body: data_type === 'jobs' 
        ? '새로운 직업이 추가되었습니다 🎮'
        : '새로운 파티 템플릿이 추가되었습니다 🎉',
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'data_update_channel',
      },
    },
    apns: {
      payload: {
        aps: {
          contentAvailable: true,
        },
      },
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('✅ FCM 전송 성공:', response);
    res.json({ success: true, messageId: response });
  } catch (error) {
    console.error('❌ FCM 전송 실패:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.listen(3000, () => {
  console.log('🚀 FCM Admin 서버 실행 중: http://localhost:3000');
});
```

**Supabase Trigger**
```sql
CREATE OR REPLACE FUNCTION call_admin_server()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM net.http_post(
    url := 'http://your-server.com:3000/send-fcm',
    headers := jsonb_build_object('Content-Type', 'application/json'),
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

## 🚀 방법 3: Supabase Edge Function (권장!)

가장 깔끔한 방법은 Supabase Edge Function을 사용하는 것입니다.

### 장점
- ✅ 서버 불필요 (Serverless)
- ✅ Supabase에 통합
- ✅ 무료 (500,000회/월)
- ✅ OAuth 토큰 자동 관리

### 구현

**supabase/functions/send-fcm-push/index.ts**
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req) => {
  try {
    const { data_type, version } = await req.json();
    
    console.log(`📤 FCM 전송: ${data_type} v${version}`);

    // Firebase Admin SDK 사용
    // TODO: OAuth 토큰 생성 및 FCM v1 API 호출
    
    // 간단한 대안: Firebase Console에서 수동 전송 권장!
    
    return new Response(
      JSON.stringify({ success: true }),
      { status: 200 }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500 }
    );
  }
});
```

---

## 💡 최종 권장 방안

### 현재 단계: Firebase Console 수동 전송 ✅

**이유**:
1. FCM v1 API는 OAuth 토큰 생성이 복잡
2. Firebase Console은 v1 API를 자동으로 사용
3. 월 1-2회 업데이트라면 수동으로 충분
4. 설정 불필요, 즉시 사용 가능

**절차**:
```
1. Supabase에서 직업 데이터 업데이트
2. data_versions 버전 증가
3. Firebase Console → Cloud Messaging
4. "첫 번째 캠페인 보내기" 클릭
5. 타겟: all_users
6. 맞춤 데이터 추가 (type, data_type, version)
7. 전송!
```

**소요 시간**: 1분

---

### 향후 자동화 (사용자 100명 이상)

**방법**: Firebase Admin SDK 서버

**장점**:
- ✅ 완전 자동화
- ✅ v1 API 지원
- ✅ OAuth 토큰 자동 관리

**구현**:
1. Node.js 서버 구축 (또는 Vercel/Netlify Functions)
2. Firebase Admin SDK 사용
3. Supabase Webhook → 서버 호출
4. 서버 → FCM 전송

**소요 시간**: 30분

---

## 📝 서비스 계정 키 다운로드 (향후 자동화용)

### 1. Firebase Console 접속

```
Firebase Console → 프로젝트 설정 → 서비스 계정 탭
```

### 2. 새 비공개 키 생성

```
"새 비공개 키 생성" 버튼 클릭
→ JSON 파일 다운로드
→ 안전한 곳에 보관
```

### 3. 파일 구조

```json
{
  "type": "service_account",
  "project_id": "mobi-party-link",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-...@mobi-party-link.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs"
}
```

**⚠️ 이 파일은 절대 Git에 커밋하지 마세요!**

---

## 🎯 결론

**지금 단계**: 
- ✅ Firebase Console에서 수동 전송 (1분)
- ✅ 월 1-2회 업데이트라면 충분

**나중에 (사용자 많아지면)**:
- 🔜 Firebase Admin SDK 서버 구축
- 🔜 Supabase Edge Function으로 완전 자동화

**Legacy API 문제 해결!** 🎉
