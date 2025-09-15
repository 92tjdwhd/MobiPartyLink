# 개발 로그

## 프로젝트 시작
- **날짜**: 2024-12-19
- **프로젝트명**: Mobi Party Link (마비노기 모바일 파티 모집 앱)
- **아키텍처**: Flutter + Riverpod + Clean Architecture
- **패키지명**: studio.deskmoment

## 완료된 작업

### 1. 프로젝트 구조 설정
- ✅ Flutter Riverpod + Clean Architecture 구조 생성
- ✅ Android SDK 35, iOS 15.0+ 지원 설정
- ✅ GitHub 저장소 연동 완료
- ✅ Git Template 생성 완료
- ✅ Cursor Rules 적용 완료

### 2. 기획서 문서화
- ✅ 프로젝트 기획서 저장 (`docs/project-brief.md`)
- ✅ 와이어프레임 명세 저장 (`docs/wireframes.md`)
- ✅ 기능 명세서 저장 (`docs/features.md`)

## 다음 개발 단계

### 1. 도메인 모델 설계
- [ ] Party Entity 설계
- [ ] PartyMember Entity 설계
- [ ] UserProfile Entity 설계
- [ ] PartyStatus Enum 설계

### 2. 데이터 계층 구현
- [ ] Party Repository 인터페이스
- [ ] Party Local DataSource 구현
- [ ] UserProfile Repository 인터페이스
- [ ] UserProfile Local DataSource 구현

### 3. UseCase 구현
- [ ] CreateParty UseCase
- [ ] JoinParty UseCase
- [ ] GetPartyList UseCase
- [ ] UpdateProfile UseCase

### 4. UI 구현
- [ ] 홈 화면 (파티 만들기/참여)
- [ ] 파티 만들기 화면
- [ ] 파티 상세 화면
- [ ] 파티 참여 화면
- [ ] 프로필 관리 화면

### 5. 알림 시스템
- [ ] 푸시 알림 설정
- [ ] 파티 시작 알림 로직

## 기술 스택
- **프레임워크**: Flutter 3.0+
- **상태 관리**: Riverpod
- **아키텍처**: Clean Architecture
- **로컬 저장소**: Hive
- **네트워킹**: Dio (향후 확장용)
- **코드 생성**: Freezed, JSON Annotation, Riverpod Generator

## 개발 우선순위
1. **MVP 핵심 기능**: 파티 생성/참여/관리
2. **프로필 관리**: 사용자 정보 저장/자동 입력
3. **알림 시스템**: 파티 시작 알림
4. **UI/UX 개선**: Material 3 디자인 적용
5. **확장 기능**: 반복 파티, 고급 관리 기능
