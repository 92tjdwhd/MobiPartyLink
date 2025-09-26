import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_member_entity.dart';
import 'package:mobi_party_link/features/party/presentation/widgets/party_card.dart';
import 'package:mobi_party_link/core/utils/party_utils.dart';

class PartyManagementBottomSheet extends ConsumerStatefulWidget {
  final PartyEntity party;

  const PartyManagementBottomSheet({
    super.key,
    required this.party,
  });

  @override
  ConsumerState<PartyManagementBottomSheet> createState() =>
      _PartyManagementBottomSheetState();
}

class _PartyManagementBottomSheetState
    extends ConsumerState<PartyManagementBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
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
        color: Colors.grey[300],
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
          const Text(
            '파티 관리',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF666666)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyCard() {
    return PartyCard(
      party: widget.party,
      onTap: null, // 관리 바텀시트에서는 카드 클릭 비활성화
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
            const Text(
              '파티 멤버',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              '${widget.party.members.length}/${widget.party.maxMembers}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.party.members.map((member) => _buildMemberCard(member)),
      ],
    );
  }

  Widget _buildMemberCard(PartyMemberEntity member) {
    final isLeader = member.userId == widget.party.creatorId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLeader ? const Color(0xFF007AFF) : const Color(0xFFE5E5E5),
          width: isLeader ? 2 : 1,
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
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  isLeader ? const Color(0xFF007AFF) : const Color(0xFF6B21A8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isLeader ? Icons.star : Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.nickname,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    if (isLeader) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '파티장',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${PartyUtils.getJobText(member.jobId)} • 투력 ${member.power}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '참여일: ${_formatDateTime(member.joinedAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          if (!isLeader) // 파티장이 아닌 경우에만 강퇴 버튼 표시
            IconButton(
              icon: const Icon(
                Icons.person_remove,
                color: Color(0xFFFF3B30),
                size: 20,
              ),
              onPressed: () => _showKickConfirmDialog(member),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showKickConfirmDialog(PartyMemberEntity member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('멤버 강퇴'),
        content: Text('${member.nickname}님을 파티에서 강퇴하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _kickMember(member);
            },
            child: const Text(
              '강퇴',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );
  }

  void _kickMember(PartyMemberEntity member) {
    // TODO: 실제 강퇴 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.nickname}님을 강퇴했습니다'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
