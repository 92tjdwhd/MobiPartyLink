# 기능 명세서

## 핵심 기능

### 1. 파티 생성 및 관리
- **파티 생성**: 파티명, 날짜/시간, 인원수, 콘텐츠 종류 설정
- **참가자 정보 요구사항**: 직업/투력 입력 필수 여부 선택
- **파티 링크 생성**: 공유 가능한 링크 자동 생성
- **파티 상태 관리**: 예정/진행중/마감 상태 자동/수동 관리

### 2. 파티 참여
- **링크 기반 참여**: 파티 링크 클릭으로 참여
- **프로필 자동 입력**: 저장된 프로필 정보 자동 입력
- **정보 수정**: 참가 후 내 정보 수정/취소/나가기 가능

### 3. 실시간 파티 관리
- **참여자 리스트**: 실시간 참여자 현황 표시
- **강퇴 기능**: 파티장이 참가자 강퇴 가능
- **자진 나가기**: 참가자가 자진 나가기 가능

### 4. 프로필 관리
- **프로필 저장**: 닉네임, 직업, 투력 정보 저장
- **자동 입력**: 파티 참여 시 저장된 프로필 자동 입력
- **프로필 수정**: 언제든지 프로필 정보 수정 가능

### 5. 알림 시스템
- **푸시 알림**: 파티 시작 N분 전 알림
- **알림 설정**: 파티장/참가자 모두 알림 수신

## 데이터 구조

### 파티 (Party)
```dart
class Party {
  String id;
  String name;
  DateTime startTime;
  int maxMembers;
  String contentType;
  bool requireJob;
  bool requirePower;
  PartyStatus status;
  String creatorId;
  List<PartyMember> members;
}
```

### 파티 멤버 (PartyMember)
```dart
class PartyMember {
  String id;
  String nickname;
  String job;
  int power;
  DateTime joinedAt;
}
```

### 사용자 프로필 (UserProfile)
```dart
class UserProfile {
  String id;
  String nickname;
  String job;
  int power;
  DateTime createdAt;
  DateTime updatedAt;
}
```

## 직업 리스트
- 전사
- 마법사
- 궁수
- 도적
- 기사
- 팔라딘
- 다크나이트
- 바드
- 기타

## 파티 상태
- **예정**: 시작 시간 전
- **진행중**: 시작 시간 이후
- **마감**: 종료 시간 경과 또는 수동 마감
