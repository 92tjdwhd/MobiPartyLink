import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/core/services/notification_service.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';

/// 파티 알림 상태 관리 Provider
class PartyNotificationNotifier extends StateNotifier<PartyNotificationState> {

  PartyNotificationNotifier(this._notificationService)
      : super(const PartyNotificationState()) {
    _initialize();
  }
  final NotificationService _notificationService;

  /// 초기화
  Future<void> _initialize() async {
    try {
      final minutesBefore =
          await _notificationService.getNotificationMinutesBefore();
      state = state.copyWith(
        notificationMinutesBefore: minutesBefore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: '알림 설정 초기화 실패: $e',
        isLoading: false,
      );
    }
  }

  /// 파티 생성 시 알림 등록
  Future<void> schedulePartyNotification(PartyEntity party) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final minutesBefore = state.notificationMinutesBefore;
      await _notificationService.schedulePartyNotification(
          party, minutesBefore);

      // 파티 목록에 추가
      final updatedParties = [...state.scheduledParties, party];
      state = state.copyWith(
        scheduledParties: updatedParties,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: '파티 알림 등록 실패: $e',
        isLoading: false,
      );
    }
  }

  /// 파티 가입 시 알림 등록
  Future<void> scheduleJoinedPartyNotification(PartyEntity party) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final minutesBefore = state.notificationMinutesBefore;
      await _notificationService.schedulePartyNotification(
          party, minutesBefore);

      // 가입한 파티 목록에 추가
      final updatedJoinedParties = [...state.joinedParties, party];
      state = state.copyWith(
        joinedParties: updatedJoinedParties,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: '가입 파티 알림 등록 실패: $e',
        isLoading: false,
      );
    }
  }

  /// 파티 알림 취소
  Future<void> cancelPartyNotification(PartyEntity party) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _notificationService.cancelPartyNotification(party);

      // 파티 목록에서 제거
      final updatedScheduledParties =
          state.scheduledParties.where((p) => p.id != party.id).toList();
      final updatedJoinedParties =
          state.joinedParties.where((p) => p.id != party.id).toList();

      state = state.copyWith(
        scheduledParties: updatedScheduledParties,
        joinedParties: updatedJoinedParties,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: '파티 알림 취소 실패: $e',
        isLoading: false,
      );
    }
  }

  /// 알림 설정 변경
  Future<void> updateNotificationSettings(int newMinutesBefore) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 모든 파티 목록 가져오기
      final allParties = [...state.scheduledParties, ...state.joinedParties];

      // 알림 설정 변경 및 전체 재등록
      await _notificationService.updateNotificationSettings(
          newMinutesBefore, allParties);

      state = state.copyWith(
        notificationMinutesBefore: newMinutesBefore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: '알림 설정 변경 실패: $e',
        isLoading: false,
      );
    }
  }

  /// 전체 알림 재등록
  Future<void> rescheduleAllNotifications() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 모든 파티 목록 가져오기
      final allParties = [...state.scheduledParties, ...state.joinedParties];

      // 전체 알림 재등록
      await _notificationService.rescheduleAllPartyNotifications(allParties);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: '전체 알림 재등록 실패: $e',
        isLoading: false,
      );
    }
  }

  /// 파티 목록 초기화
  Future<void> initializePartyList(
      List<PartyEntity> createdParties, List<PartyEntity> joinedParties) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 기존 알림 모두 취소
      await _notificationService.cancelAllPartyNotifications();

      // 새로운 파티 목록으로 알림 재등록
      final allParties = [...createdParties, ...joinedParties];
      await _notificationService.rescheduleAllPartyNotifications(allParties);

      state = state.copyWith(
        scheduledParties: createdParties,
        joinedParties: joinedParties,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: '파티 목록 초기화 실패: $e',
        isLoading: false,
      );
    }
  }

  /// 서버 파티 목록과 동기화
  Future<void> syncWithServerParties(
      List<PartyEntity> serverMyParties, List<PartyEntity> serverJoinedParties) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 현재 등록된 파티 목록
      final currentMyParties = state.scheduledParties;
      final currentJoinedParties = state.joinedParties;

      // 변경사항 확인 및 알림 업데이트
      await _updatePartyNotifications(
        currentMyParties,
        currentJoinedParties,
        serverMyParties,
        serverJoinedParties,
      );

      // 상태 업데이트
      state = state.copyWith(
        scheduledParties: serverMyParties,
        joinedParties: serverJoinedParties,
        isLoading: false,
      );

      print('서버 파티 동기화 완료: 내 파티 ${serverMyParties.length}개, 참가 파티 ${serverJoinedParties.length}개');
    } catch (e) {
      state = state.copyWith(
        error: '서버 파티 동기화 실패: $e',
        isLoading: false,
      );
      print('서버 파티 동기화 실패: $e');
    }
  }

  /// 파티 알림 업데이트 로직
  Future<void> _updatePartyNotifications(
    List<PartyEntity> currentMyParties,
    List<PartyEntity> currentJoinedParties,
    List<PartyEntity> serverMyParties,
    List<PartyEntity> serverJoinedParties,
  ) async {
    final currentAllParties = [...currentMyParties, ...currentJoinedParties];
    final serverAllParties = [...serverMyParties, ...serverJoinedParties];

    // 1. 삭제된 파티 알림 취소
    for (final currentParty in currentAllParties) {
      final stillExists = serverAllParties.any((serverParty) => serverParty.id == currentParty.id);
      if (!stillExists) {
        await _notificationService.cancelPartyNotification(currentParty);
        print('삭제된 파티 알림 취소: ${currentParty.name}');
      }
    }

    // 2. 새로 추가된 파티 또는 변경된 파티 알림 등록/업데이트
    for (final serverParty in serverAllParties) {
      final existingParty = currentAllParties.firstWhere(
        (currentParty) => currentParty.id == serverParty.id,
        orElse: () => PartyEntity(
          id: '',
          name: '',
          startTime: DateTime.now(),
          maxMembers: 0,
          contentType: '',
          category: '',
          difficulty: '',
          requireJob: false,
          requirePower: false,
          status: PartyStatus.pending,
          creatorId: '',
          members: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // 새 파티이거나 시작 시간이 변경된 경우
      if (existingParty.id.isEmpty || 
          existingParty.startTime != serverParty.startTime ||
          existingParty.name != serverParty.name) {
        
        // 기존 알림 취소 (있는 경우)
        if (existingParty.id.isNotEmpty) {
          await _notificationService.cancelPartyNotification(existingParty);
        }

        // 새 알림 등록
        await _notificationService.schedulePartyNotification(
          serverParty,
          state.notificationMinutesBefore,
        );
        
        if (existingParty.id.isEmpty) {
          print('새 파티 알림 등록: ${serverParty.name}');
        } else {
          print('변경된 파티 알림 업데이트: ${serverParty.name}');
        }
      }
    }
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 파티 알림 상태
class PartyNotificationState {

  const PartyNotificationState({
    this.notificationMinutesBefore = 5,
    this.scheduledParties = const [],
    this.joinedParties = const [],
    this.isLoading = true,
    this.error,
  });
  final int notificationMinutesBefore;
  final List<PartyEntity> scheduledParties;
  final List<PartyEntity> joinedParties;
  final bool isLoading;
  final String? error;

  PartyNotificationState copyWith({
    int? notificationMinutesBefore,
    List<PartyEntity>? scheduledParties,
    List<PartyEntity>? joinedParties,
    bool? isLoading,
    String? error,
  }) {
    return PartyNotificationState(
      notificationMinutesBefore:
          notificationMinutesBefore ?? this.notificationMinutesBefore,
      scheduledParties: scheduledParties ?? this.scheduledParties,
      joinedParties: joinedParties ?? this.joinedParties,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 전체 파티 목록
  List<PartyEntity> get allParties => [...scheduledParties, ...joinedParties];

  /// 알림이 등록된 파티 수
  int get totalNotificationCount => allParties.length;
}

/// 파티 알림 Provider
final partyNotificationProvider =
    StateNotifierProvider<PartyNotificationNotifier, PartyNotificationState>(
        (ref) {
  return PartyNotificationNotifier(NotificationService());
});

/// 알림 서비스 Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
