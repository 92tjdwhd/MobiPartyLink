import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/features/party/presentation/widgets/party_recruitment_bottom_sheet.dart';
import 'package:mobi_party_link/core/services/profile_service.dart';
import 'package:mobi_party_link/features/profile/presentation/widgets/profile_setup_bottom_sheet.dart';
import 'package:mobi_party_link/features/party/presentation/widgets/party_management_bottom_sheet.dart';
import 'package:mobi_party_link/features/party/presentation/widgets/party_info_bottom_sheet.dart';
import 'package:mobi_party_link/features/party/presentation/widgets/party_edit_bottom_sheet.dart';
import 'package:mobi_party_link/features/notification/presentation/screens/notification_settings_screen.dart';
import 'package:mobi_party_link/features/profile/presentation/providers/profile_provider.dart';
import 'package:mobi_party_link/features/party/presentation/providers/party_list_provider.dart';
import 'package:mobi_party_link/features/party/presentation/widgets/party_card.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/features/permission/presentation/providers/permission_provider.dart';
import 'package:mobi_party_link/features/permission/presentation/widgets/permission_dialog.dart';
import 'package:mobi_party_link/features/settings/presentation/screens/settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 권한 체크 및 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissions();
      _initializePartyNotifications();
    });
  }

  /// 파티 알림 초기화
  Future<void> _initializePartyNotifications() async {
    try {
      // 서버에서 파티 목록을 가져와서 알림 동기화
      // myPartiesProvider와 joinedPartiesProvider가 자동으로 호출되어
      // 서버 데이터를 가져오고 알림을 동기화함
      print('파티 알림 초기화 시작 - 서버에서 파티 목록을 가져와서 동기화합니다');
    } catch (e) {
      print('파티 알림 초기화 실패: $e');
    }
  }

  /// 권한 체크 및 요청
  Future<void> _checkAndRequestPermissions() async {
    final permissionNotifier = ref.read(permissionProvider.notifier);

    // 권한 상태 체크
    await permissionNotifier.checkPermissions();

    // 권한이 허용되지 않은 경우 다이얼로그 표시
    final permissionState = ref.read(permissionProvider);
    if (!permissionState.areAllPermissionsGranted) {
      final granted = await showPermissionDialog(context);
      if (granted == true) {
        // 권한이 허용된 경우 다시 체크
        await permissionNotifier.checkPermissions();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 플랫폼 감지 (웹 환경 고려)
    final isAndroid = !kIsWeb && Platform.isAndroid;
    final isIOS = !kIsWeb && Platform.isIOS;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: isIOS ? _buildIOSAppBar() : null,
      body: isAndroid
          ? SafeArea(
              child: Column(
                children: [
                  _buildAndroidAppBar(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildJoinedPartiesTab(),
                        _buildCreatedPartiesTab(),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // 웹이나 iOS가 아닌 경우 기본 AppBar 표시
                if (!isIOS) _buildWebAppBar(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildJoinedPartiesTab(),
                      _buildCreatedPartiesTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // iOS용 AppBar (네이티브 AppBar 사용)
  PreferredSizeWidget _buildIOSAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(
        '모비링크',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.titleLarge?.color,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        _buildUserProfile(),
        const SizedBox(width: 12),
        _buildSettingsButton(),
        const SizedBox(width: 20),
      ],
    );
  }

  // 웹용 AppBar (Android와 유사하지만 SafeArea 없음)
  Widget _buildWebAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '모비링크',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              _buildUserProfile(),
              const SizedBox(width: 12),
              _buildSettingsButton(),
            ],
          ),
        ],
      ),
    );
  }

  // Android용 커스텀 AppBar
  Widget _buildAndroidAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '모비링크',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              _buildUserProfile(),
              const SizedBox(width: 12),
              _buildSettingsButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Consumer(
      builder: (context, ref, child) {
        final hasProfileAsync = ref.watch(hasProfileProvider);

        return hasProfileAsync.when(
          data: (hasProfile) {
            if (hasProfile) {
              return _buildExistingProfile(ref);
            } else {
              return _buildProfileSetup();
            }
          },
          loading: () => _buildProfileSetup(),
          error: (error, stack) => _buildProfileSetup(),
        );
      },
    );
  }

  Widget _buildExistingProfile(WidgetRef ref) {
    final profileAsync = ref.watch(profileDataProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return _buildProfileSetup();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF76769A)
                      : Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profile.nickname,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '${profile.job} • ${profile.power}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => _buildProfileSetup(),
      error: (error, stack) => _buildProfileSetup(),
    );
  }

  Widget _buildProfileSetup() {
    return GestureDetector(
      onTap: _showProfileSetupBottomSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF76769A)
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person_add_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '프로필 설정하기',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileSetupBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileSetupBottomSheet(
        onProfileSaved: () {
          // 프로필 저장 후 메인 화면 새로고침
          refreshProfile(ref);
        },
      ),
    );
  }

  void _showPartyManagementBottomSheet(PartyEntity party) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PartyManagementBottomSheet(
        party: party,
      ),
    );
  }

  void _showPartyEditBottomSheet(PartyEntity party) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PartyEditBottomSheet(
        party: party,
      ),
    );
  }

  void _showPartyInfoBottomSheet(PartyEntity party) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PartyInfoBottomSheet(
        party: party,
      ),
    );
  }

  Widget _buildSettingsButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          );
        },
        icon: Icon(
          Icons.settings_rounded,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Theme.of(context).primaryColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Theme.of(context).textTheme.titleLarge?.color,
        unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
        labelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),
        tabs: const [
          Tab(text: '참가한 파티'),
          Tab(text: '내가 만든 파티'),
        ],
      ),
    );
  }

  Widget _buildJoinedPartiesTab() {
    return Consumer(
      builder: (context, ref, child) {
        final joinedPartiesAsync = ref.watch(joinedPartiesProvider);

        return joinedPartiesAsync.when(
          data: (parties) => _buildPartyList(
            parties: parties,
            showCreateButton: false,
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  '파티 목록을 불러올 수 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    refreshPartyList(ref);
                  },
                  child: Text('다시 시도'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreatedPartiesTab() {
    return Consumer(
      builder: (context, ref, child) {
        final myPartiesAsync = ref.watch(myPartiesProvider);

        return myPartiesAsync.when(
          data: (parties) => _buildPartyList(
            parties: parties,
            showCreateButton: true,
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  '파티 목록을 불러올 수 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    refreshPartyList(ref);
                  },
                  child: Text('다시 시도'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPartyList({
    required List<PartyEntity> parties,
    required bool showCreateButton,
  }) {
    return Column(
      children: [
        if (showCreateButton) _buildCreatePartyButton(),
        Expanded(
          child: parties.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: parties.length,
                  itemBuilder: (context, index) {
                    return PartyCard(
                      party: parties[index],
                      isJoinedParty:
                          !showCreateButton, // showCreateButton이 false면 참가한 파티
                      isMyParty:
                          showCreateButton, // showCreateButton이 true면 내가 만든 파티
                      onTap: () {
                        // 파티 타입에 따라 다른 바텀시트 표시
                        if (showCreateButton) {
                          // 내가 만든 파티 (파티장) - 파티 관리 바텀시트
                          _showPartyManagementBottomSheet(parties[index]);
                        } else {
                          // 참가한 파티 (일반 참여자) - 파티 정보 보기 바텀시트
                          _showPartyInfoBottomSheet(parties[index]);
                        }
                      },
                      onEdit: showCreateButton
                          ? () {
                              _showPartyEditBottomSheet(parties[index]);
                            }
                          : null,
                      onShare: showCreateButton
                          ? () {
                              // TODO: 파티 공유 기능
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('파티 공유 기능은 준비 중입니다'),
                                ),
                              );
                            }
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCreatePartyButton() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ElevatedButton.icon(
        onPressed: () {
          _showPartyRecruitmentBottomSheet();
        },
        icon: const Icon(
          Icons.add_rounded,
          size: 20,
        ),
        label: Text(
          '파티 만들기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF76769A)
              : Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '아직 파티가 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '파티를 만들어보세요!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  void _showPartyRecruitmentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PartyRecruitmentBottomSheet(),
    );
  }
}
