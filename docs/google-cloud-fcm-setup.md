# ☁️ Google Cloud FCM API 활성화 가이드

## Step 1: Google Cloud Console 접속

```
https://console.cloud.google.com/
```

**로그인**: Firebase 프로젝트와 동일한 Google 계정으로 로그인

---

## Step 2: 프로젝트 선택

```
상단 프로젝트 선택 드롭다운 클릭
→ "mobi-party-link" 선택
```

**참고**: Firebase 프로젝트는 자동으로 Google Cloud 프로젝트로 생성됩니다.

---

## Step 3: Firebase Cloud Messaging API 활성화

### 방법 1: 직접 링크 (가장 빠름)

```
https://console.cloud.google.com/apis/library/fcm.googleapis.com
```

1. 위 링크 클릭
2. 프로젝트 선택: mobi-party-link
3. **"사용 설정"** 또는 **"ENABLE"** 버튼 클릭
4. 완료!

---

### 방법 2: API 라이브러리에서 검색

```
Google Cloud Console
→ 좌측 메뉴: API 및 서비스 → 라이브러리
→ 검색창: "Firebase Cloud Messaging API"
→ "Firebase Cloud Messaging API" 클릭
→ "사용 설정" 버튼 클릭
```

---

## Step 4: API 활성화 확인

```
Google Cloud Console
→ API 및 서비스 → 사용 설정된 API 및 서비스
→ "Firebase Cloud Messaging API" 확인 ✅
```

**상태**: 사용 설정됨

---

## Step 5: 서비스 계정 키 다운로드

### 5-1. IAM 및 관리자 메뉴

```
Google Cloud Console
→ 좌측 메뉴: IAM 및 관리자 → 서비스 계정
```

### 5-2. 서비스 계정 찾기

```
firebase-adminsdk-xxxxx@mobi-party-link.iam.gserviceaccount.com
```

**또는 Firebase Console에서**:
```
Firebase Console
→ 프로젝트 설정 (⚙️)
→ 서비스 계정 탭
→ "새 비공개 키 생성" 버튼 클릭
→ JSON 다운로드
```

### 5-3. 파일 저장

```
파일명: mobi-party-link-firebase-adminsdk-xxxxx.json
위치: 안전한 곳 (Git에 커밋하지 마세요!)
```

---

## ✅ 완료 확인

활성화가 완료되면:

1. ✅ Firebase Cloud Messaging API: 사용 설정됨
2. ✅ 서비스 계정 키 JSON 다운로드 완료

---

## 다음 단계

서비스 계정 키 JSON을 다운로드하셨다면:

1. **Firebase Admin SDK 서버** 구축 또는
2. **Supabase Edge Function** 배포

어떤 방법을 원하시나요?

**참고**: 현재는 Firebase Console에서 수동으로 푸시 전송도 가능합니다!
