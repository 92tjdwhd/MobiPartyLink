import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobi_party_link/features/notification/presentation/providers/notification_settings_provider.dart';
import 'package:mobi_party_link/features/notification/presentation/providers/party_notification_provider.dart';
import 'package:mobi_party_link/features/permission/presentation/widgets/permission_dialog.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  int? _selectedMinutes; // 선택된 알림 시간 (임시 저장)
  bool _hasChanges = false; // 변경사항이 있는지 확인

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
      if (granted ?? false) {
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

  /// 저장 버튼 위젯
  Widget _buildSaveButton(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _hasChanges
                ? () => _saveNotificationSettings(context, ref)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF76769A)
                  : Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              '저장',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 알림 설정 저장
  Future<void> _saveNotificationSettings(
      BuildContext context, WidgetRef ref) async {
    if (_selectedMinutes == null) return;

    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 알림 설정 변경 및 전체 알림 재등록
      await ref
          .read(partyNotificationProvider.notifier)
          .updateNotificationSettings(_selectedMinutes!);

      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }

      // 성공 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('알림 설정이 $_selectedMinutes분 전으로 변경되었습니다'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 변경사항 초기화
      setState(() {
        _hasChanges = false;
      });

      // 뒤로가기
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }

      // 에러 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('알림 설정 저장 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final partyNotificationState = ref.watch(partyNotificationProvider);

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
      body: _buildSettingsContent(context, ref, partyNotificationState),
      bottomNavigationBar: _hasChanges ? _buildSaveButton(context, ref) : null,
    );
  }

  Widget _buildSettingsContent(BuildContext context, WidgetRef ref,
      PartyNotificationState partyNotificationState) {
    // 초기 선택값 설정
    _selectedMinutes ??= partyNotificationState.notificationMinutesBefore;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 알림 상태 표시
          if (partyNotificationState.totalNotificationCount > 0)
            Card(
              color: Theme.of(context).cardColor,
              elevation: 2,
              shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '알림 등록 현황',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${partyNotificationState.totalNotificationCount}개 파티에 알림이 등록되어 있습니다',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
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
                        groupValue: _selectedMinutes,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMinutes = value;
                              _hasChanges = value !=
                                  partyNotificationState
                                      .notificationMinutesBefore;
                            });
                          }
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedMinutes = minutes;
                          _hasChanges = minutes !=
                              partyNotificationState.notificationMinutesBefore;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
