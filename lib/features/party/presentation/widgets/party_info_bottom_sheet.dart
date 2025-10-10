import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_member_entity.dart';
import 'package:mobi_party_link/features/party/presentation/widgets/party_card.dart';
import 'package:mobi_party_link/features/party/presentation/providers/party_provider.dart';
import 'package:mobi_party_link/features/party/presentation/providers/party_list_provider.dart';
import 'package:mobi_party_link/core/di/injection.dart';
import 'package:mobi_party_link/shared/widgets/job_icon_widget.dart';

class PartyInfoBottomSheet extends ConsumerStatefulWidget {
  const PartyInfoBottomSheet({
    super.key,
    required this.party,
  });
  final PartyEntity party;

  @override
  ConsumerState<PartyInfoBottomSheet> createState() =>
      _PartyInfoBottomSheetState();
}

class _PartyInfoBottomSheetState extends ConsumerState<PartyInfoBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPartyCard(),
                  const SizedBox(height: 24),
                  _buildMembersSection(),
                  const SizedBox(height: 24),
                  FutureBuilder<bool>(
                    future: _isCreator(),
                    builder: (context, snapshot) {
                      final isCreator = snapshot.data ?? true;
                      // 파티장이 아닐 때만 나가기 버튼 표시
                      if (!isCreator) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _showLeaveConfirmDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF3B30),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              '파티 나가기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      height: 5,
      width: 40,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '파티 정보',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close,
                color: Theme.of(context).textTheme.bodyMedium?.color),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyCard() {
    return PartyCard(
      party: widget.party,
      isJoinedParty: true, // 참가한 파티로 표시하여 제한 메시지 숨김
      isMyParty: false, // 내가 만든 파티가 아님
      onTap: null, // 정보 보기 바텀시트에서는 카드 클릭 비활성화
      onShare: null, // 공유 버튼 숨김
      margin:
          const EdgeInsets.symmetric(horizontal: 0, vertical: 8), // 좌우 마진 제거
    );
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '파티 멤버',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            Text(
              '${widget.party.members.length}/${widget.party.maxMembers}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.party.members.map(_buildMemberCard),
      ],
    );
  }

  Widget _buildMemberCard(PartyMemberEntity member) {
    final isLeader = member.userId == widget.party.creatorId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLeader
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor,
          width: isLeader ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 모든 멤버 직업 아이콘 사용
          _buildMemberJobIcon(member),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.nickname,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    if (isLeader) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '파티장',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).cardColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${member.job ?? '미설정'} • 투력 ${member.power}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '참여일: ${_formatDateTime(member.joinedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberJobIcon(PartyMemberEntity member) {
    return JobIconWidget(
      jobId: member.jobId,
      size: 40,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF76769A)
          : Theme.of(context).primaryColor,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getPartyStatusText(PartyStatus status) {
    switch (status) {
      case PartyStatus.pending:
        return '대기중';
      case PartyStatus.startingSoon:
        return '시작 5분 전';
      case PartyStatus.ongoing:
        return '진행중';
      case PartyStatus.completed:
        return '완료';
      case PartyStatus.expired:
        return '만료됨';
      case PartyStatus.cancelled:
        return '취소';
    }
  }

  /// 현재 사용자가 파티장인지 확인
  Future<bool> _isCreator() async {
    final authService = ref.read(authServiceProvider);
    final userId = await authService.getUserId();
    return userId != null && widget.party.creatorId == userId;
  }

  /// 파티 나가기 확인 다이얼로그
  void _showLeaveConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          '파티 나가기',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: Text(
          '정말 파티에서 나가시겠습니까?',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _leaveParty();
            },
            child: const Text(
              '나가기',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );
  }

  /// 파티 나가기 실행
  Future<void> _leaveParty() async {
    try {
      final authService = ref.read(authServiceProvider);
      final userId = await authService.getUserId();

      if (userId == null) {
        throw Exception('사용자 인증이 필요합니다');
      }

      print('🔄 파티 나가기 시작: ${widget.party.name}');

      // PartyDetailNotifier를 통해 파티 나가기 요청
      final notifier =
          ref.read(partyDetailNotifierProvider(widget.party.id).notifier);
      await notifier.leaveParty(userId);

      print('✅ 파티 나가기 성공: ${widget.party.name}');

      if (mounted) {
        // 참가한 파티 목록 새로고침
        ref.invalidate(joinedPartiesProvider);
        ref.invalidate(myPartiesProvider);
        print('✅ 파티 목록 새로고침');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('파티에서 나갔습니다'),
            backgroundColor: Colors.green,
          ),
        );

        // 바텀시트 닫기
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ 파티 나가기 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('파티 나가기에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
