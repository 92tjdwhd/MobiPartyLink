import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/core/di/injection.dart';

// 내가 만든 파티 리스트 Provider
final myPartiesProvider = FutureProvider<List<PartyEntity>>((ref) async {
  print('myPartiesProvider 호출됨');
  final getMyParties = ref.read(getMyPartiesProviderProvider);
  final result = await getMyParties();
  return result.fold(
    (failure) {
      print('내가 만든 파티 로드 실패: $failure');
      return [];
    },
    (parties) {
      print('내가 만든 파티 로드 성공: ${parties.length}개');
      return parties;
    },
  );
});

// 참가한 파티 리스트 Provider
final joinedPartiesProvider = FutureProvider<List<PartyEntity>>((ref) async {
  final getJoinedParties = ref.read(getJoinedPartiesProviderProvider);
  final result = await getJoinedParties();
  return result.fold(
    (failure) => [],
    (parties) => parties,
  );
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
