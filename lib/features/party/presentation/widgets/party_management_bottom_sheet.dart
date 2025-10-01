import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_member_entity.dart';
import 'package:mobi_party_link/core/di/injection.dart';
import 'package:mobi_party_link/core/services/fcm_push_service.dart';
import 'package:mobi_party_link/core/data/mock_party_data.dart';
import 'package:mobi_party_link/features/party/presentation/providers/party_list_provider.dart';
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
                  const SizedBox(height: 24),
                  _buildDeleteButton(),
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
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[600]
            : Colors.grey[300],
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
            '파티 관리',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
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
              color: isLeader
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isLeader ? Icons.star : Icons.person,
              color: Theme.of(context).cardColor,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          '멤버 강퇴',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: Text(
          '${member.nickname}님을 파티에서 강퇴하시겠습니까?',
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

  Future<void> _kickMember(PartyMemberEntity member) async {
    try {
      final repository = ref.read(partyRepositoryProvider);
      final authService = ref.read(authServiceProvider);

      // 생성자 userId 가져오기
      final creatorId = await authService.getUserId();
      if (creatorId == null) {
        throw Exception('사용자 인증이 필요합니다');
      }

      // 멤버 강퇴 API 호출
      final result = await repository.kickMember(
        widget.party.id,
        member.id,
        creatorId,
      );

      result.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (_) {
          print('✅ 멤버 강퇴 성공: ${member.nickname}');

          // 파티 리스트 새로고침
          refreshPartyList(ref);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${member.nickname}님을 강퇴했습니다'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // 바텀시트 닫기
          }
        },
      );
    } catch (e) {
      print('❌ 멤버 강퇴 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('멤버 강퇴에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _deleteParty,
        icon: const Icon(Icons.delete_outline),
        label: const Text('파티 삭제'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteParty() async {
    // 삭제 확인 다이얼로그
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('파티 삭제'),
        content: Text(
          '정말 "${widget.party.name}" 파티를 삭제하시겠습니까?\n\n삭제된 파티는 복구할 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final repository = ref.read(partyRepositoryProvider);
      final authService = ref.read(authServiceProvider);

      // 생성자 userId 가져오기
      final creatorId = await authService.getUserId();
      if (creatorId == null) {
        throw Exception('사용자 인증이 필요합니다');
      }

      // 파티 삭제 API 호출
      final result = await repository.deleteParty(widget.party.id, creatorId);

      result.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (_) {
          print('✅ 파티 삭제 성공: ${widget.party.name}');

          // 파티 리스트 새로고침
          refreshPartyList(ref);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('파티가 삭제되었습니다'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // 바텀시트 닫기
          }
        },
      );
    } catch (e) {
      print('❌ 파티 삭제 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('파티 삭제에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
