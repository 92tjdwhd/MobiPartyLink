import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/features/profile/presentation/widgets/profile_setup_bottom_sheet.dart';
import 'package:mobi_party_link/features/profile/presentation/screens/profile_management_screen.dart';
import 'package:mobi_party_link/features/profile/presentation/providers/profile_provider.dart';
import 'package:mobi_party_link/features/notification/presentation/screens/notification_settings_screen.dart';
import 'package:mobi_party_link/features/settings/presentation/screens/data_sync_test_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // 플랫폼 감지 (웹 환경 고려)
    final isAndroid =
        !kIsWeb && Theme.of(context).platform == TargetPlatform.android;
    final isIOS = !kIsWeb && Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: isIOS ? _buildIOSAppBar(context) : null,
      body: isAndroid
          ? SafeArea(
              child: Column(
                children: [
                  _buildAndroidAppBar(context),
                  Expanded(child: _buildSettingsContent(context)),
                ],
              ),
            )
          : Column(
              children: [
                // 웹이나 iOS가 아닌 경우 기본 AppBar 표시
                if (!isIOS) _buildWebAppBar(context),
                Expanded(child: _buildSettingsContent(context)),
              ],
            ),
    );
  }

  // iOS용 AppBar
  PreferredSizeWidget _buildIOSAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios,
            color: Theme.of(context).textTheme.titleLarge?.color),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        '설정',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.titleLarge?.color,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
    );
  }

  // 웹용 AppBar
  Widget _buildWebAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).textTheme.titleLarge?.color),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 16),
          Text(
            '설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Android용 커스텀 AppBar
  Widget _buildAndroidAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).textTheme.titleLarge?.color),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 16),
          Text(
            '설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // 설정 화면 내용
  Widget _buildSettingsContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 일반 설정 섹션
          _buildSectionHeader('일반'),
          SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.notifications_outlined,
              title: '알림 설정',
              subtitle: '파티 시작 알림 및 푸시 알림 설정',
              onTap: () => _navigateToNotificationSettings(context),
            ),
            _buildDivider(),
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: '프로필 설정',
              subtitle: '닉네임, 직업, 전투력 수정',
              onTap: () => _navigateToProfileSettings(context),
            ),
          ]),

          SizedBox(height: 24),

          // 개발자 섹션
          _buildSectionHeader('개발자'),
          SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.cloud_sync,
              title: '데이터 동기화 테스트',
              subtitle: 'Supabase 연동 및 로컬 저장소 테스트',
              onTap: () => _navigateToDataSyncTest(context),
            ),
            _buildDivider(),
            _buildSettingsItem(
              icon: Icons.notifications_active,
              title: 'FCM 푸시 테스트',
              subtitle: 'Edge Function을 통한 FCM 푸시 알림 테스트',
              onTap: () => _testFcmPush(context),
            ),
          ]),

          SizedBox(height: 24),

          // 지원 섹션
          _buildSectionHeader('지원'),
          SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: '문의하기',
              subtitle: '앱 사용 중 문제나 건의사항',
              onTap: () => _showContactDialog(context),
            ),
            _buildDivider(),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: '앱 정보',
              subtitle: '버전 1.0.0',
              onTap: () => _showAppInfoDialog(context),
              showArrow: false,
            ),
          ]),

          SizedBox(height: 40),

          // 앱 정보
          Center(
            child: Column(
              children: [
                Text(
                  '모비링크',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '모바일 마비노기 파티 모집 앱',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyMedium?.color,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).textTheme.bodySmall?.color,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 72),
      color: Theme.of(context).dividerColor.withOpacity(0.1),
    );
  }

  // 알림 설정 화면으로 이동
  void _navigateToNotificationSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }

  // 프로필 설정 네비게이션
  void _navigateToProfileSettings(BuildContext context) async {
    final hasProfile = await ref.read(hasProfileProvider.future);

    if (hasProfile) {
      // 프로필이 있으면 프로필 관리 화면으로 이동
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ProfileManagementScreen(),
        ),
      );
    } else {
      // 프로필이 없으면 프로필 설정 바텀시트 표시
      _showProfileSetup(context);
    }
  }

  // 프로필 설정 바텀시트 표시
  void _showProfileSetup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileSetupBottomSheet(
        onProfileSaved: () {
          // 프로필 저장 후 프로필 관리 화면으로 이동
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProfileManagementScreen(),
            ),
          );
        },
      ),
    );
  }

  // 데이터 동기화 테스트 화면으로 이동
  void _navigateToDataSyncTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DataSyncTestScreen(),
      ),
    );
  }

  // 문의하기 다이얼로그 표시
  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text(
          '문의하기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '앱 사용 중 문제나 건의사항이 있으시면\n아래 방법으로 연락해 주세요.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            _buildContactOption(
              icon: Icons.email_outlined,
              title: '이메일',
              subtitle: 'deskmoment@gmail.com',
              onTap: () => _launchEmail(),
            ),
            SizedBox(height: 12),
            _buildContactOption(
              icon: Icons.chat_outlined,
              title: '카카오톡',
              subtitle: '@모비링크',
              onTap: () => _launchKakaoTalk(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '닫기',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 앱 정보 다이얼로그 표시
  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text(
          '앱 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('앱 이름', '모비링크'),
            _buildInfoRow('버전', '1.0.0'),
            _buildInfoRow('개발자', 'DeskMoment Studio'),
            _buildInfoRow('설명', '모바일 마비노기 파티 모집 앱'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 이메일 실행
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'deskmoment@gmail.com',
      query: Uri.encodeQueryComponent('subject=모비링크 앱 문의'),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  // 카카오톡 실행
  Future<void> _launchKakaoTalk() async {
    // 웹에서는 카카오톡 채널 링크로 이동
    const String kakaoChannelUrl = 'https://pf.kakao.com/_mobilink';
    final Uri uri = Uri.parse(kakaoChannelUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
