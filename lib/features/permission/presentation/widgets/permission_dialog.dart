import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool?> showPermissionDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // 사용자가 외부 탭으로 닫을 수 없음
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text(
          '알림 권한 요청',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '모비링크는 파티 시작 5분 전 알림을 통해 중요한 파티 일정을 놓치지 않도록 도와드립니다.',
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '알림을 받으려면 권한 허용이 필요합니다.',
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              dialogContext.pop(false); // '나중에' 선택 시 false 반환
            },
            child: Text(
              '나중에',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // 권한 요청
              final status = await Permission.notification.request();
              if (status.isGranted) {
                dialogContext.pop(true); // 권한 허용 시 true 반환
              } else if (status.isPermanentlyDenied) {
                // 영구적으로 거부된 경우 설정으로 이동 유도
                openAppSettings();
                dialogContext.pop(false); // 설정으로 이동했으므로 false 반환
              } else {
                dialogContext.pop(false); // 그 외의 경우 false 반환
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              '권한 허용',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      );
    },
  );
}
