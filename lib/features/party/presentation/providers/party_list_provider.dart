import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/core/di/injection.dart';
import 'package:mobi_party_link/features/notification/presentation/providers/party_notification_provider.dart';

// 내가 만든 파티 리스트 Provider
final myPartiesProvider = FutureProvider<List<PartyEntity>>((ref) async {
  print('myPartiesProvider 호출됨');

  // Supabase에서 내가 만든 파티 가져오기
  final repository = ref.read(partyRepositoryProvider);
  final result = await repository.getMyParties();

  final parties = result.fold(
    (failure) {
      print('❌ 내 파티 로드 실패: ${failure.message}');
      return <PartyEntity>[];
    },
    (parties) {
      print('내가 만든 파티 로드 성공: ${parties.length}개');
      return parties;
    },
  );

  // 파티 목록 로드 후 알림 동기화
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _syncPartyNotifications(ref, parties, []);
  });

  return parties;
});

// 참가한 파티 리스트 Provider
final joinedPartiesProvider = FutureProvider<List<PartyEntity>>((ref) async {
  print('joinedPartiesProvider 호출됨');

  // Supabase에서 참가한 파티 가져오기
  final repository = ref.read(partyRepositoryProvider);
  final result = await repository.getJoinedParties();

  final parties = result.fold(
    (failure) {
      print('❌ 참가한 파티 로드 실패: ${failure.message}');
      return <PartyEntity>[];
    },
    (parties) {
      print('참가한 파티 로드 성공: ${parties.length}개');
      return parties;
    },
  );

  // 참가한 파티 목록 로드 후 알림 동기화
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _syncPartyNotifications(ref, [], parties);
  });

  return parties;
});

// 파티 리스트 새로고침 Provider
final partyListRefreshProvider = StateProvider<int>((ref) => 0);

// 파티 리스트 새로고침 트리거
void refreshPartyList(WidgetRef ref) {
  print('refreshPartyList 호출됨');
  ref.read(partyListRefreshProvider.notifier).state++;
  ref.invalidate(myPartiesProvider);
  ref.invalidate(joinedPartiesProvider);
  print('Provider 무효화 완료');
}

// 파티 알림 동기화 함수
Future<void> _syncPartyNotifications(
  FutureProviderRef<List<PartyEntity>> ref,
  List<PartyEntity> myParties,
  List<PartyEntity> joinedParties,
) async {
  try {
    print(
        '파티 알림 동기화 시작: 내 파티 ${myParties.length}개, 참가 파티 ${joinedParties.length}개');

    // 파티 알림 Provider에 전체 파티 목록 전달하여 동기화
    await ref.read(partyNotificationProvider.notifier).syncWithServerParties(
          myParties,
          joinedParties,
        );

    print('파티 알림 동기화 완료');
  } catch (e) {
    print('파티 알림 동기화 실패: $e');
  }
}
