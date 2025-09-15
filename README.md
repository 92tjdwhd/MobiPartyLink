# Mobi Party Link

Flutter Riverpod + Clean Architecture를 사용한 실제 회사 표준 모바일 애플리케이션입니다.

## 🏗️ 아키텍처

이 프로젝트는 **Clean Architecture + Riverpod + Repository Pattern**을 기반으로 구성되어 있으며, 실제 회사에서 사용하는 표준 구조입니다.

## 📁 Flutter 프로젝트 전체 구조

### 루트 디렉토리
```
mobi_party_link/
├── android/                 # Android 플랫폼 설정
│   ├── app/                # Android 앱 설정
│   │   ├── build.gradle    # 앱 빌드 설정
│   │   └── src/main/       # Android 소스 코드
│   ├── build.gradle        # 프로젝트 빌드 설정
│   └── settings.gradle     # Gradle 설정
├── ios/                    # iOS 플랫폼 설정
│   ├── Runner/             # iOS 앱 설정
│   │   ├── Info.plist      # iOS 앱 정보
│   │   └── AppDelegate.swift # iOS 앱 델리게이트
│   └── Runner.xcodeproj/   # Xcode 프로젝트
├── lib/                    # Flutter 소스 코드 (메인)
├── test/                   # 테스트 코드
├── docs/                   # 프로젝트 문서
├── pubspec.yaml           # Flutter 의존성 설정
├── analysis_options.yaml  # 코드 분석 설정
├── .gitignore             # Git 무시 파일
├── .cursorrules           # Cursor 코딩 규칙
└── README.md              # 프로젝트 설명서
```

### lib/ 디렉토리 (Flutter 소스 코드)
```
lib/
├── core/                    # 핵심 기능 (공통)
│   ├── di/                 # 의존성 주입 (Riverpod)
│   │   └── injection.dart  # DI 설정
│   ├── error/              # 에러 처리
│   │   ├── exceptions.dart # 예외 정의
│   │   └── failures.dart   # 실패 정의
│   ├── network/            # 네트워크 설정
│   │   ├── dio_client.dart # HTTP 클라이언트
│   │   └── network_info.dart # 네트워크 상태
│   ├── constants/          # 상수 정의
│   │   └── app_constants.dart
│   ├── router/             # 라우팅 설정
│   │   └── app_router.dart # GoRouter 설정
│   ├── theme/              # 테마 설정
│   │   └── app_theme.dart  # Material 3 테마
│   └── utils/              # 유틸리티 함수
│       └── logger.dart     # 로깅 유틸리티
├── features/               # 기능별 모듈 (Clean Architecture)
│   └── counter/            # 카운터 기능 예제
│       ├── data/           # 데이터 계층
│       │   ├── datasources/    # 데이터 소스
│       │   │   ├── counter_local_datasource.dart
│       │   │   └── counter_remote_datasource.dart
│       │   ├── models/         # 데이터 모델
│       │   │   └── counter_model.dart
│       │   └── repositories/   # Repository 구현체
│       │       └── counter_repository_impl.dart
│       ├── domain/         # 도메인 계층
│       │   ├── entities/       # 비즈니스 엔티티
│       │   │   └── counter_entity.dart
│       │   ├── repositories/   # Repository 인터페이스
│       │   │   └── counter_repository.dart
│       │   └── usecases/      # UseCase (비즈니스 로직)
│       │       ├── get_counter.dart
│       │       ├── increment_counter.dart
│       │       ├── decrement_counter.dart
│       │       └── reset_counter.dart
│       └── presentation/   # 프레젠테이션 계층
│           ├── providers/      # Riverpod Provider
│           │   └── counter_provider.dart
│           ├── pages/          # 화면
│           │   └── counter_screen.dart
│           └── widgets/        # UI 위젯
│               ├── counter_display.dart
│               └── counter_controls.dart
├── shared/                 # 공유 컴포넌트
│   ├── models/             # 공통 모델
│   ├── services/           # 공통 서비스
│   └── widgets/            # 공통 위젯
└── main.dart              # 앱 진입점
```

### test/ 디렉토리 (테스트 코드)
```
test/
├── unit/                   # 단위 테스트
│   └── features/
│       └── counter/
│           └── presentation/
│               └── providers/
│                   └── counter_provider_test.dart
├── widget/                 # 위젯 테스트
├── integration/            # 통합 테스트
└── helpers/                # 테스트 헬퍼
    └── mock_use_cases.dart
```

## 🏛️ Clean Architecture 계층 설명

### 1. Domain Layer (도메인 계층)
- **Entities**: 비즈니스 엔티티 (순수 Dart 객체)
- **Repositories**: 데이터 접근 인터페이스
- **UseCases**: 비즈니스 로직 (Entity 사용)

### 2. Data Layer (데이터 계층)
- **Models**: JSON 직렬화 가능한 데이터 모델
- **DataSources**: 로컬/원격 데이터 소스
- **Repository Impl**: Repository 인터페이스 구현

### 3. Presentation Layer (프레젠테이션 계층)
- **Providers**: Riverpod 상태 관리
- **Pages**: 화면 (Screen)
- **Widgets**: 재사용 가능한 UI 컴포넌트

## 🔄 데이터 흐름

```
UI (Widget) 
    ↓
Provider (Riverpod)
    ↓
UseCase (Domain)
    ↓
Repository (Data)
    ↓
DataSource (Local/Remote)
```

## 📱 플랫폼별 설정

### Android 설정
- **최소 SDK**: 21 (Android 5.0)
- **타겟 SDK**: 35 (Android 14)
- **컴파일 SDK**: 35
- **Kotlin**: 1.9.10
- **Gradle**: 8.1.4

### iOS 설정
- **최소 배포 타겟**: 15.0
- **Swift**: 5.0
- **Xcode**: 14.0+

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
