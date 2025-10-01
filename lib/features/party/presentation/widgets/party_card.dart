import 'package:flutter/material.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/core/utils/party_utils.dart';
import 'package:mobi_party_link/core/utils/party_status_calculator.dart';

class PartyCard extends StatelessWidget {
  final PartyEntity party;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onEdit; // 수정하기 버튼 콜백
  final bool isJoinedParty; // 참가한 파티인지 구분
  final bool isMyParty; // 내가 만든 파티인지 구분
  final EdgeInsetsGeometry? margin; // 마진 커스터마이징 옵션

  const PartyCard({
    super.key,
    required this.party,
    this.onTap,
    this.onShare,
    this.onEdit, // 수정하기 버튼 콜백
    this.isJoinedParty = false, // 기본값은 false (내가 만든 파티)
    this.isMyParty = false, // 기본값은 false
    this.margin, // 마진 커스터마이징 옵션
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(party.category);
    final isPartyFull = _isPartyFull();
    final isJobLimitFull = _isJobLimitFull();

    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: categoryColor,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap, // Always allow tap for joined parties
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: 1.0, // Always full opacity for joined parties
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 파티명과 상태
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        party.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(PartyStatusCalculator.getStatusColor(
                            PartyStatusCalculator.calculateStatus(party))),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        PartyStatusCalculator.getStatusText(
                            PartyStatusCalculator.calculateStatus(party)),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 컨텐츠, 카테고리, 난이도
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        party.contentType,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        party.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        party.difficulty,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${party.members.length}/${party.maxMembers}명',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 시작 시간
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${party.startTime.year}.${party.startTime.month.toString().padLeft(2, '0')}.${party.startTime.day.toString().padLeft(2, '0')} ${party.startTime.hour.toString().padLeft(2, '0')}:${party.startTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),

                // 투력 요구사항
                if (party.requirePower && party.minPower != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.flash_on,
                        size: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getPowerRequirementText(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ],

                // 직업 제한
                if (party.requireJobCategory) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.group,
                        size: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getJobLimitText(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ],

                // 공유/초대 버튼과 수정하기 버튼 (내가 만든 파티인 경우)
                if (onShare != null || onEdit != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null) ...[
                        InkWell(
                          onTap: onEdit,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF007AFF).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: const Color(0xFF007AFF),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '수정하기',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF007AFF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (onShare != null)
                        InkWell(
                          onTap: onShare,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: categoryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.share,
                                  size: 16,
                                  color: categoryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '초대하기',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: categoryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],

                // 제한 상태 메시지는 파티 참여 바텀시트에서만 표시
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case '레이드':
        return const Color(0xFFE91E63); // 핑크
      case '어비스':
        return const Color(0xFF9C27B0); // 퍼플
      case '던전':
        return const Color(0xFF3F51B5); // 인디고
      case 'pvp':
        return const Color(0xFFF44336); // 레드
      case '길드':
        return const Color(0xFF4CAF50); // 그린
      case '퀘스트':
        return const Color(0xFFFF9800); // 오렌지
      case '이벤트':
        return const Color(0xFF00BCD4); // 시안
      case '훈련':
        return const Color(0xFF795548); // 브라운
      case '소셜':
        return const Color(0xFF607D8B); // 블루 그레이
      default:
        return const Color(0xFFE0E0E0); // 기본 회색
    }
  }

  String _getPowerRequirementText() {
    if (party.minPower != null && party.maxPower != null) {
      return '투력 ${party.minPower} - ${party.maxPower}';
    } else if (party.minPower != null) {
      return '투력 ${party.minPower} 이상';
    } else if (party.maxPower != null) {
      return '투력 ${party.maxPower} 이하';
    }
    return '';
  }

  String _getJobLimitText() {
    final jobCounts = _getJobCategoryCounts();

    final limits = <String>[];
    if (party.tankLimit > 0) {
      limits.add('탱커(${jobCounts['tank']}/${party.tankLimit})');
    }
    if (party.healerLimit > 0) {
      limits.add('힐러(${jobCounts['healer']}/${party.healerLimit})');
    }
    if (party.dpsLimit > 0) {
      limits.add('딜러(${jobCounts['dps']}/${party.dpsLimit})');
    }
    return limits.join(' ');
  }

  Map<String, int> _getJobCategoryCounts() {
    final counts = <String, int>{
      'tank': 0,
      'healer': 0,
      'dps': 0,
    };

    for (final member in party.members) {
      if (member.job != null) {
        final category = _getJobCategory(member.job!);
        if (counts.containsKey(category)) {
          counts[category] = counts[category]! + 1;
        }
      }
    }

    return counts;
  }

  String _getJobCategory(String jobId) {
    // 탱커 직업들
    if (['전사', '수도사', '빙결술사'].contains(jobId)) {
      return 'tank';
    }
    // 힐러 직업들
    if (['힐러', '사제'].contains(jobId)) {
      return 'healer';
    }
    // 딜러 직업들 (나머지)
    return 'dps';
  }

  bool _isPartyFull() {
    return party.members.length >= party.maxMembers;
  }

  bool _isJobLimitFull() {
    if (!party.requireJobCategory) return false;

    final jobCounts = _getJobCategoryCounts();

    if (party.tankLimit > 0 && jobCounts['tank']! >= party.tankLimit)
      return true;
    if (party.healerLimit > 0 && jobCounts['healer']! >= party.healerLimit)
      return true;
    if (party.dpsLimit > 0 && jobCounts['dps']! >= party.dpsLimit) return true;

    return false;
  }
}
