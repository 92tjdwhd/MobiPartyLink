class AppConstants {
  // API 관련 상수
  static const String baseUrl = 'https://api.example.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // 로컬 스토리지 키
  static const String counterKey = 'counter_value';
  static const String themeKey = 'theme_mode';
  
  // 앱 정보
  static const String appName = 'Mobi Party Link';
  static const String appVersion = '1.0.0';
  
  // 애니메이션 지속 시간
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
