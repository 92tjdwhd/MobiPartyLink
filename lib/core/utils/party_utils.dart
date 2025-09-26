import 'package:uuid/uuid.dart';

import '../../features/party/domain/entities/party_entity.dart';
import '../../features/party/domain/entities/party_member_entity.dart';
import '../../features/auth/domain/entities/auth_user_entity.dart';

class PartyUtils {
  static const _uuid = Uuid();

  /// 고유 ID 생성
  static String generateId() {
    return _uuid.v4();
  }

  /// 파티 상태를 한국어로 변환
  static String getPartyStatusText(PartyStatus status) {
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

  /// 파티 상태를 한국어로 변환 (간단 버전)
  static String getStatusText(PartyStatus status) {
    return getPartyStatusText(status);
  }

  /// 콘텐츠 타입을 한국어로 변환
  static String getContentTypeText(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'raid':
        return '레이드';
      case 'dungeon':
        return '던전';
      case 'pvp':
        return 'PvP';
      case 'guild':
        return '길드';
      case 'quest':
        return '퀘스트';
      case 'event':
        return '이벤트';
      case 'training':
        return '연습';
      case 'social':
        return '소셜';
      default:
        return contentType;
    }
  }

  /// 카테고리를 한국어로 변환
  static String getCategoryText(String category) {
    switch (category.toLowerCase()) {
      case 'raid':
        return '레이드';
      case 'dungeon':
        return '던전';
      case 'pvp':
        return 'PvP';
      case 'guild':
        return '길드';
      case 'quest':
        return '퀘스트';
      case 'event':
        return '이벤트';
      case 'training':
        return '연습';
      case 'social':
        return '소셜';
      default:
        return category;
    }
  }

  /// 난이도를 한국어로 변환
  static String getDifficultyText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '쉬움';
      case 'normal':
        return '보통';
      case 'hard':
        return '어려움';
      case 'extreme':
        return '극한';
      case 'nightmare':
        return '악몽';
      default:
        return difficulty;
    }
  }

  /// 직업을 한국어로 변환
  static String getJobText(String? job) {
    if (job == null) return '미설정';

    switch (job.toLowerCase()) {
      case 'warrior':
        return '전사';
      case 'archer':
        return '궁수';
      case 'mage':
        return '마법사';
      case 'priest':
        return '성직자';
      case 'rogue':
        return '도적';
      case 'paladin':
        return '성기사';
      case 'monk':
        return '수도사';
      default:
        return job;
    }
  }

  /// 투력을 포맷팅
  static String formatPower(int? power) {
    if (power == null) return '미설정';

    if (power >= 1000000) {
      return '${(power / 1000000).toStringAsFixed(1)}M';
    } else if (power >= 1000) {
      return '${(power / 1000).toStringAsFixed(1)}K';
    } else {
      return power.toString();
    }
  }

  /// 파티 인원수 표시
  static String getPartyMemberCount(PartyEntity party) {
    return '${party.members.length}/${party.maxMembers}';
  }

  /// 파티 참여 가능 여부 확인
  static bool canJoinParty(PartyEntity party, String userId) {
    // 이미 참여한 경우
    if (party.members.any((member) => member.userId == userId)) {
      return false;
    }

    // 인원이 가득 찬 경우
    if (party.members.length >= party.maxMembers) {
      return false;
    }

    // 파티가 종료된 경우
    if (party.status == PartyStatus.completed) {
      return false;
    }

    return true;
  }

  /// 파티 생성자 여부 확인
  static bool isPartyCreator(PartyEntity party, String userId) {
    return party.creatorId == userId;
  }

  /// 파티 멤버 여부 확인
  static bool isPartyMember(PartyEntity party, String userId) {
    return party.members.any((member) => member.userId == userId);
  }

  /// AuthUser를 PartyMember로 변환
  static PartyMemberEntity authUserToPartyMember(
    AuthUserEntity user,
    String partyId, {
    String? nickname,
    String? job,
    int? power,
  }) {
    return PartyMemberEntity(
      id: generateId(),
      partyId: partyId,
      userId: user.id,
      nickname: nickname ?? '익명사용자',
      jobId: job,
      power: power,
      joinedAt: DateTime.now(),
    );
  }

  /// 파티 시작 시간 포맷팅
  static String formatStartTime(DateTime startTime) {
    final now = DateTime.now();
    final difference = startTime.difference(now);

    if (difference.isNegative) {
      return '시작됨';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays}일 후';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 후';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 후';
    } else {
      return '곧 시작';
    }
  }

  /// 파티 생성 시간 포맷팅
  static String formatCreatedTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
