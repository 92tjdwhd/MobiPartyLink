import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// 알림 권한 요청
  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) {
      // 웹에서는 Notification API를 직접 사용하거나 브라우저 설정에 따름
      // 여기서는 항상 true 반환 (웹 브라우저에서 사용자에게 직접 요청)
      return true;
    }

    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return false;
  }

  /// 알림 권한 상태 체크
  Future<bool> checkNotificationPermission() async {
    if (kIsWeb) {
      return true; // 웹에서는 항상 true 반환
    }

    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.notification.status;
      return status.isGranted;
    }
    return false;
  }

  /// 정확한 알림 예약 권한 상태 체크
  Future<bool> checkExactAlarmPermission() async {
    if (kIsWeb) return true;
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.status;
      return status.isGranted;
    }
    return true; // iOS는 항상 허용
  }

  /// 정확한 알림 예약 권한 요청
  Future<bool> requestExactAlarmPermission() async {
    if (kIsWeb) return true;
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    }
    return true; // iOS는 항상 허용
  }
}
