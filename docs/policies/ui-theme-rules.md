# UI 테마 규칙 - 다크모드/라이트모드 필수 적용

## 핵심 원칙
**모든 UI 컴포넌트는 반드시 다크모드/라이트모드 테마를 적용해야 합니다.**

## 필수 규칙

### 1. 하드코딩된 색상 사용 금지 ❌
```dart
// 금지된 사용법
color: Colors.white
color: Colors.black
color: Color(0xFF000000)
color: Color(0xFFFFFFFF)
backgroundColor: Colors.grey[100]
```

### 2. 테마 기반 색상 사용 필수 ✅
```dart
// 올바른 사용법
color: Theme.of(context).textTheme.titleLarge?.color
backgroundColor: Theme.of(context).scaffoldBackgroundColor
color: Theme.of(context).cardColor
color: Theme.of(context).primaryColor
color: Theme.of(context).textTheme.bodyMedium?.color
```

### 3. const 키워드 제한
테마 색상을 사용하는 위젯에서는 `const` 키워드 사용 금지

```dart
// 금지된 사용법
const Text(
  '제목',
  style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
)

// 올바른 사용법
Text(
  '제목',
  style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
)
```

## 적용 대상
- 모든 화면 (Screen)
- 모든 위젯 (Widget)
- 모든 바텀시트 (BottomSheet)
- 모든 다이얼로그 (Dialog)
- 모든 카드 (Card)
- 모든 버튼 (Button)
- 모든 텍스트 (Text)
- 모든 아이콘 (Icon)
- 모든 컨테이너 (Container)

## 테마 색상 매핑

### 텍스트 색상
- `Theme.of(context).textTheme.titleLarge?.color` - 제목 텍스트
- `Theme.of(context).textTheme.bodyLarge?.color` - 본문 텍스트
- `Theme.of(context).textTheme.bodyMedium?.color` - 보조 텍스트
- `Theme.of(context).textTheme.bodySmall?.color` - 작은 텍스트

### 배경 색상
- `Theme.of(context).scaffoldBackgroundColor` - 화면 배경
- `Theme.of(context).cardColor` - 카드 배경
- `Theme.of(context).dialogBackgroundColor` - 다이얼로그 배경

### 액센트 색상
- `Theme.of(context).primaryColor` - 주요 색상
- `Theme.of(context).colorScheme.onPrimary` - 주요 색상 위 텍스트
- `Theme.of(context).shadowColor` - 그림자 색상
- `Theme.of(context).dividerColor` - 구분선 색상

## 테마 변경 방법
`lib/core/theme/app_theme.dart`에서 `AppTheme.lightTheme`과 `AppTheme.darkTheme`의 색상 값만 변경하면 전체 앱 테마가 일괄 변경됩니다.

## 검증 방법
1. 시스템 다크모드/라이트모드 전환 시 모든 화면이 적절히 변경되는지 확인
2. 하드코딩된 색상이 없는지 코드 리뷰 시 확인
3. `const` 키워드와 테마 색상이 함께 사용되지 않았는지 확인

## 예외 사항
- 브랜드 색상 (로고, 특정 아이덴티티 색상)은 예외적으로 하드코딩 가능
- 하지만 가능한 한 테마 색상으로 대체하는 것을 권장
