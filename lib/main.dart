import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/di/injection.dart';
import 'core/network/supabase_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/fcm_service.dart';
import 'firebase_options.dart';
import 'features/notification/presentation/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 플랫폼별 시스템 UI 설정 (웹 제외)
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      // Android 전용 설정 - 시스템 테마에 따라 동적 설정
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          // 상태바 설정
          statusBarColor: Colors.transparent, // 투명한 상태바
          statusBarIconBrightness: Brightness.dark, // 어두운 아이콘
          statusBarBrightness: Brightness.light, // 밝은 배경

          // 네비게이션 바 설정
          systemNavigationBarColor: Colors.transparent, // 투명한 네비게이션 바
          systemNavigationBarIconBrightness: Brightness.dark, // 어두운 아이콘
          systemNavigationBarDividerColor: Colors.transparent, // 투명한 구분선
        ),
      );

      // Android Edge-to-edge 모드
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
    } else if (Platform.isIOS) {
      // iOS 전용 설정 - 시스템 테마에 따라 동적 설정
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          // iOS 상태바 설정
          statusBarBrightness: Brightness.light, // 밝은 배경
          statusBarIconBrightness: Brightness.dark, // 어두운 아이콘
          // iOS에서는 statusBarColor와 systemNavigationBarColor 무시됨
        ),
      );

      // iOS는 기본적으로 edge-to-edge이므로 별도 설정 불필요
    }
  }

  // Firebase 초기화 (FCM)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FcmService.initialize();
  print('✅ Firebase & FCM 초기화 완료');

  // Supabase 초기화
  await AppSupabaseClient.initialize();

  // SharedPreferences 초기화
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // SharedPreferences 오버라이드
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Mobi Party Link',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
