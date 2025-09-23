import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/core/theme/app_theme.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        '모비링크',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
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

  Widget _buildUserProfile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
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
              color: const Color(0xFF6B21A8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E5E5),
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
              const Text(
                '플레이어',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.2,
                ),
              ),
              const Text(
                '전사 • 1500',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
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
          // TODO: 설정 화면으로 이동
        },
        icon: const Icon(
          Icons.settings_rounded,
          color: Color(0xFF666666),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF6B21A8),
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: const Color(0xFF6B21A8),
        unselectedLabelColor: const Color(0xFF999999),
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
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
    return _buildPartyList(
      parties: [], // TODO: 참가한 파티 데이터
      showCreateButton: false,
    );
  }

  Widget _buildCreatedPartiesTab() {
    return _buildPartyList(
      parties: [], // TODO: 내가 만든 파티 데이터
      showCreateButton: true,
    );
  }

  Widget _buildPartyList({
    required List<dynamic> parties,
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
                    return _buildPartyCard(
                      party: parties[index],
                      showShareButton: showCreateButton,
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
          // TODO: 파티 생성 화면으로 이동
        },
        icon: const Icon(
          Icons.add_rounded,
          size: 20,
        ),
        label: const Text(
          '파티 만들기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B21A8),
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

  Widget _buildPartyCard({
    required dynamic party,
    required bool showShareButton,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF0F0F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '서큐버스 레이드 (입문)',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (showShareButton)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE5E5E5),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // TODO: 파티 공유 기능
                      },
                      icon: const Icon(
                        Icons.share_rounded,
                        color: Color(0xFF6B21A8),
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildStatusChip('대기중', const Color(0xFFFF9500)),
                _buildInfoChip('입문', const Color(0xFF007AFF)),
                _buildInfoChip('4인', const Color(0xFF34C759)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Color(0xFF999999),
                ),
                const SizedBox(width: 6),
                const Text(
                  '2024.01.15 20:00',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    letterSpacing: -0.1,
                  ),
                ),
                const Spacer(),
                const Text(
                  '2/4',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.people_rounded,
                  size: 16,
                  color: Color(0xFF999999),
                ),
              ],
            ),
          ],
        ),
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
}
