# Mobi Party Link

Flutter Riverpod + Clean Architecture를 사용한 실제 회사 표준 모바일 애플리케이션입니다.

## 🏗️ 아키텍처

이 프로젝트는 **Clean Architecture + Riverpod + Repository Pattern**을 기반으로 구성되어 있으며, 실제 회사에서 사용하는 표준 구조입니다.

### 폴더 구조

```
lib/
├── core/                    # 핵심 기능
│   ├── di/                 # 의존성 주입 (Riverpod)
│   ├── error/              # 에러 처리 (Failures, Exceptions)
│   ├── network/            # 네트워크 설정 (Dio, NetworkInfo)
│   ├── constants/          # 상수 정의
│   ├── router/             # 라우팅 설정 (GoRouter)
│   ├── theme/              # 테마 설정 (Material 3)
│   └── utils/              # 유틸리티 함수
├── features/               # 기능별 모듈 (Clean Architecture)
│   └── counter/            # 카운터 기능
│       ├── data/           # 데이터 계층
│       │   ├── datasources/    # 로컬/원격 데이터 소스
│       │   ├── models/         # 데이터 모델 (JSON 직렬화)
│       │   └── repositories/   # Repository 구현체
│       ├── domain/         # 도메인 계층
│       │   ├── entities/       # 비즈니스 엔티티
│       │   ├── repositories/   # Repository 인터페이스
│       │   └── usecases/      # UseCase (비즈니스 로직)
│       └── presentation/   # 프레젠테이션 계층
│           ├── providers/      # Riverpod Provider
│           ├── pages/          # 화면
│           └── widgets/        # UI 위젯
├── shared/                 # 공유 컴포넌트
│   ├── models/             # 공통 모델
│   ├── services/           # 공통 서비스
│   └── widgets/            # 공통 위젯
└── main.dart              # 앱 진입점
```

## 🚀 시작하기

### 필요 조건

- Flutter SDK 3.0.0 이상
- Dart 3.0.0 이상

### 설치 및 실행

1. 의존성 설치:
```bash
flutter pub get
```

2. 앱 실행:
```bash
flutter run
```

## 📦 사용된 패키지

### 상태 관리 & DI
- **flutter_riverpod**: 상태 관리 및 의존성 주입
- **riverpod_annotation**: 코드 생성 기반 Provider

### 네트워킹
- **dio**: HTTP 클라이언트
- **retrofit**: REST API 클라이언트 생성

### 로컬 스토리지
- **shared_preferences**: 간단한 키-값 저장
- **hive**: NoSQL 로컬 데이터베이스

### 코드 생성
- **freezed**: 불변 객체 생성
- **json_annotation**: JSON 직렬화
- **build_runner**: 코드 생성 도구

### 유틸리티
- **dartz**: 함수형 프로그래밍 (Either, Option)
- **equatable**: 객체 비교 최적화

## 🎯 주요 기능

- ✅ **Clean Architecture** - 계층 분리 및 의존성 역전
- ✅ **Riverpod DI** - 컴파일 타임 안전한 의존성 주입
- ✅ **Repository Pattern** - 데이터 계층 추상화
- ✅ **UseCase Pattern** - 비즈니스 로직 분리
- ✅ **Error Handling** - Result 패턴 기반 에러 처리
- ✅ **Code Generation** - Freezed, JSON 직렬화 자동화
- ✅ **Testing** - Unit/Widget/Integration 테스트 구조
- ✅ **Material 3** - 최신 디자인 시스템

## 📱 화면

### 홈 화면
- 앱 소개
- 기능 목록
- 네비게이션

### 카운터 화면
- 카운터 증가/감소
- 카운터 초기화
- 값 직접 설정
- Riverpod + Clean Architecture 데모

## 🔧 개발 가이드

### 새로운 기능 추가

1. `features/` 폴더에 새로운 기능 폴더 생성
2. Clean Architecture 구조에 따라 `data/`, `domain/`, `presentation/` 폴더 생성
3. `core/di/injection.dart`에 의존성 주입 설정 추가
4. 라우터에 새로운 경로 추가

### 상태 관리

- **Riverpod Provider** 사용
- **StateNotifier** - 복잡한 상태 관리
- **NotifierProvider** - 간단한 상태 관리
- **FutureProvider** - 비동기 데이터
- **StreamProvider** - 스트림 데이터

### 코드 생성 실행

```bash
# 의존성 설치
flutter pub get

# 코드 생성 실행
flutter packages pub run build_runner build

# 코드 생성 (파일 감시)
flutter packages pub run build_runner watch
```

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 있습니다.
