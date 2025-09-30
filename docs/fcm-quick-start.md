# ⚡ FCM 빠른 시작 가이드

## 🎯 5분 안에 FCM 설정하기

### Step 1: Firebase 프로젝트 생성 (2분)

1. https://console.firebase.google.com/ 접속
2. "프로젝트 추가" → 이름: `mobi-party-link`
3. Android 앱 추가 → 패키지: `studio.deskmonent.mobipartylink`
4. `google-services.json` 다운로드

---

### Step 2: 파일 복사 (30초)

```bash
cd /Users/ideaware/flutter/mobi_party_link

# google-services.json 복사
cp ~/Downloads/google-services.json android/app/

# FlutterFire 자동 설정
flutterfire configure
```

**선택사항**:
- 프로젝트: `mobi-party-link` 선택
- 플랫폼: Android, iOS 모두 선택

---

### Step 3: Android 설정 (1분)

**android/build.gradle** (프로젝트 레벨)
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'  // 추가
    }
}
```

**android/app/build.gradle** (맨 아래 추가)
```gradle
apply plugin: 'com.google.gms.google-services'
```

**android/app/src/main/AndroidManifest.xml**
```xml
<application>
    <!-- 기존 내용... -->
    
    <!-- FCM 서비스 추가 -->
    <service
        android:name="com.google.firebase.messaging.FirebaseMessagingService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
</application>
```

---

### Step 4: 앱 실행 (1분)

```bash
flutter pub get
flutter run -d R5CT501NKTK
```

**예상 로그**:
```
🔔 FCM 초기화 시작...
✅ FCM 권한 승인됨
📱 FCM 토큰: dAbCdEfGh...
✅ all_users 토픽 구독 완료
✅ FCM 초기화 완료
✅ 직업 업데이트 불필요 (FCM 플래그 없음)
✅ 템플릿 업데이트 불필요 (FCM 플래그 없음)
```

---

### Step 5: FCM 서버 키 복사 (30초)

1. Firebase Console → 프로젝트 설정 (⚙️)
2. 클라우드 메시징 탭
3. **서버 키** 복사
4. `test_fcm_push.js` 파일 열기
5. `YOUR_FCM_SERVER_KEY_HERE`를 실제 키로 변경

---

### Step 6: 테스트 푸시 전송 (30초)

```bash
# 직업 업데이트 푸시
node test_fcm_push.js jobs 2

# 예상 출력:
# 📤 FCM 푸시 전송 중...
#    토픽: /topics/all_users
#    데이터 타입: jobs
#    버전: 2
# 
# ✅ FCM 전송 완료!
# 🎉 푸시 전송 성공!
#    전송됨: 1개
#    실패: 0개
```

**앱 로그 확인**:
```
📬 포그라운드 FCM 수신: abc123
   제목: 새로운 직업 추가!
   내용: 새로운 직업이 추가되었습니다 🎮
   데이터: {type: data_update, data_type: jobs, version: 2}
✅ 직업 업데이트 플래그 저장 (v2)
```

---

### Step 7: 앱 재시작 및 동기화 확인 (30초)

```bash
# 앱 재시작 (Hot Restart)
flutter run에서 'R' 키 입력

# 또는 앱 종료 후 다시 실행
```

**예상 로그**:
```
📌 직업 업데이트 플래그 확인: true (v2)
🔔 FCM 플래그 감지, 직업 동기화 시작...
🔄 직업 데이터 동기화 시작...
⬇️ 서버에서 직업 데이터 다운로드 중...
✅ 직업 데이터 20개 다운로드 완료
✅ 직업 업데이트 플래그 제거
```

---

## ✅ 완료!

이제 FCM이 완전히 작동합니다! 🎉

**확인 사항**:
- ✅ FCM 초기화 성공
- ✅ 토픽 구독 완료
- ✅ 푸시 수신 가능
- ✅ 플래그 저장/확인/제거 작동
- ✅ 자동 동기화 작동

---

## 🚀 Supabase 자동화 (선택적)

**Supabase SQL Editor에서 실행**:

`docs/supabase_fcm_trigger.sql` 파일 참고

**중요**: FCM 서버 키를 SQL에 직접 입력!

---

## 📚 추가 문서

- **전체 설정**: `docs/fcm-complete-setup.md`
- **비용 분석**: `docs/fcm-cost-analysis.md`
- **최소 구현**: `docs/fcm-minimal-implementation.md`

---

## 🔧 문제 해결

### FCM 초기화 실패
```
❌ FCM 초기화 실패: Please set a valid API key
```
**해결**: `flutterfire configure` 실행

### 푸시 수신 안됨
```
토픽 구독 확인:
✅ all_users 토픽 구독 완료
```
**해결**: 앱 재시작

### 플래그 저장 안됨
```
data 페이로드 확인:
- type: data_update
- data_type: jobs
- version: 2
```
**해결**: 페이로드 형식 확인

---

**모든 준비 완료! Firebase 프로젝트만 생성하면 됩니다!** 🚀
