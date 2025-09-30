# 🔑 Firebase 서비스 계정 키 다운로드

## Step 1: Firebase Console에서 서비스 계정 키 생성

1. **Firebase Console** 접속
   ```
   https://console.firebase.google.com/
   → mobi-party-link 프로젝트 선택
   ```

2. **프로젝트 설정** 이동
   ```
   좌측 상단 톱니바퀴(⚙️) → 프로젝트 설정
   ```

3. **서비스 계정** 탭 클릭

4. **새 비공개 키 생성** 클릭
   ```
   "새 비공개 키 생성" 버튼 클릭
   → 확인 대화상자에서 "키 생성" 클릭
   → JSON 파일 자동 다운로드
   ```

5. **파일 이름 확인**
   ```
   예시: mobi-party-link-firebase-adminsdk-xxxxx-xxxxxxxxxx.json
   ```

---

## Step 2: JSON 파일 내용 확인

다운로드한 JSON 파일을 열면 이런 내용이 있습니다:

```json
{
  "type": "service_account",
  "project_id": "mobi-party-link",
  "private_key_id": "abcdef1234567890...",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@mobi-party-link.iam.gserviceaccount.com",
  "client_id": "123456789012345678901",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40mobi-party-link.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
```

**⚠️ 이 파일은 매우 중요합니다!**
- Git에 절대 커밋하지 마세요
- `.gitignore`에 추가하세요

---

## Step 3: 다음 단계

다운로드가 완료되면 알려주세요!
이 키를 사용해서 Supabase Edge Function을 만들겠습니다.

**JSON 파일 전체 내용**을 복사해서 준비해주세요.
