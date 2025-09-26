import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobi_party_link/features/notification/presentation/providers/notification_settings_provider.dart';
import 'package:mobi_party_link/features/permission/presentation/widgets/permission_dialog.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 권한 체크
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPermission();
    });
  }

  /// 알림 권한 체크
  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      // 권한이 없으면 다이얼로그 표시
      final granted = await showPermissionDialog(context);
      if (granted == true) {
        // 권한이 허용된 경우 스낵바 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('알림 권한이 허용되었습니다!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationTimeAsync =
        ref.watch(notificationSettingsNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '알림 설정',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: notificationTimeAsync.when(
        data: (notificationTime) =>
            _buildSettingsContent(context, ref, notificationTime),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('설정을 불러올 수 없습니다: $error'),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(
      BuildContext context, WidgetRef ref, int currentTime) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 알림 시간 설정
          Card(
            color: Theme.of(context).cardColor,
            elevation: 2,
            shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '파티 시작 알림',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '파티 시작 몇 분 전에 알림을 받을지 설정하세요.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...NotificationSettingsNotifier.notificationTimeOptions
                      .map((minutes) {
                    final isSelected = minutes == currentTime;
                    return ListTile(
                      title: Text(
                        NotificationSettingsNotifier.getNotificationTimeText(
                            minutes),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          letterSpacing: -0.3,
                        ),
                      ),
                      leading: Radio<int>(
                        value: minutes,
                        groupValue: currentTime,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(notificationSettingsNotifierProvider
                                    .notifier)
                                .setNotificationTime(value);
                          }
                        },
                      ),
                      onTap: () {
                        ref
                            .read(notificationSettingsNotifierProvider.notifier)
                            .setNotificationTime(minutes);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 알림 테스트 버튼
          Card(
            color: Theme.of(context).cardColor,
            elevation: 2,
            shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '알림 테스트',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '현재 설정으로 알림을 테스트해보세요.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _showTestNotification(context, ref, currentTime),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '테스트 알림 보내기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTestNotification(
      BuildContext context, WidgetRef ref, int minutes) async {
    // 먼저 권한 체크
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      // 권한이 없으면 다이얼로그 표시
      final granted = await showPermissionDialog(context);
      if (granted != true) {
        // 권한이 허용되지 않으면 테스트 중단
        return;
      }
    }

    // 테스트 알림 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${NotificationSettingsNotifier.getNotificationTimeText(minutes)} 알림이 설정되었습니다!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
