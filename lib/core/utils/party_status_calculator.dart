import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';

class PartyStatusCalculator {
  /// 현재 시간 기준으로 파티 상태 계산
  static PartyStatus calculateStatus(PartyEntity party) {
    final now = DateTime.now();
    final startTime = party.startTime;

    // 파티 시작 5분 전
    final fiveMinutesBefore = startTime.subtract(const Duration(minutes: 5));

    // 파티 시작 1시간 후
    final oneHourAfterStart = startTime.add(const Duration(hours: 1));

    if (now.isBefore(fiveMinutesBefore)) {
      return PartyStatus.pending; // 대기중
    } else if (now.isBefore(startTime)) {
      return PartyStatus.startingSoon; // 시작 5분 전
    } else if (now.isBefore(oneHourAfterStart)) {
      return PartyStatus.ongoing; // 진행중
    } else {
      return PartyStatus.completed; // 완료
    }
  }

  /// 상태별 텍스트 반환
  static String getStatusText(PartyStatus status) {
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
        return '취소됨';
    }
  }

  /// 상태별 색상 반환
  static int getStatusColor(PartyStatus status) {
    switch (status) {
      case PartyStatus.pending:
        return 0xFF007AFF; // 파란색
      case PartyStatus.startingSoon:
        return 0xFFFF9500; // 주황색
      case PartyStatus.ongoing:
        return 0xFF34C759; // 초록색
      case PartyStatus.completed:
        return 0xFF8E8E93; // 회색
      case PartyStatus.expired:
        return 0xFFFF3B30; // 빨간색
      case PartyStatus.cancelled:
        return 0xFFFF3B30; // 빨간색
    }
  }
}
