import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobi_party_link/core/di/injection.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/core/data/mock_party_data.dart';
import 'package:mobi_party_link/features/party/presentation/providers/party_list_provider.dart';

part 'party_edit_provider.g.dart';

@riverpod
class PartyEditNotifier extends _$PartyEditNotifier {
  @override
  AsyncValue<PartyEntity?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> editParty({
    required String partyId,
    required String name,
    required DateTime startTime,
    required int maxMembers,
    required String contentType,
    required String category,
    required String difficulty,
    required bool requireJob,
    required bool requirePower,
    int? minPower,
    int? maxPower,
    bool requireJobCategory = false,
    int tankLimit = 0,
    int healerLimit = 0,
    int dpsLimit = 0,
  }) async {
    state = const AsyncValue.loading();

    try {
      // 기존 파티 정보를 기반으로 업데이트된 파티 생성
      final repository = ref.read(partyRepositoryProvider);

      // 현재 파티 조회
      final currentPartyResult = await repository.getPartyById(partyId);
      final currentParty = currentPartyResult.fold(
        (failure) => throw Exception(failure.message),
        (party) => party,
      );

      if (currentParty == null) {
        throw Exception('파티를 찾을 수 없습니다');
      }

      // 업데이트된 파티 엔티티 생성
      final updatedParty = currentParty.copyWith(
        name: name,
        startTime: startTime,
        maxMembers: maxMembers,
        contentType: contentType,
        category: category,
        difficulty: difficulty,
        requireJob: requireJob,
        requirePower: requirePower,
        minPower: minPower,
        maxPower: maxPower,
        requireJobCategory: requireJobCategory,
        tankLimit: tankLimit,
        healerLimit: healerLimit,
        dpsLimit: dpsLimit,
        updatedAt: DateTime.now(),
      );

      // 서버에 업데이트 요청
      final result = await repository.updateParty(updatedParty);

      result.fold(
        (failure) {
          print('❌ 파티 수정 실패: ${failure.message}');
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (party) {
          print('✅ 파티 수정 성공: ${party.name}');
          state = AsyncValue.data(party);

          // Mock 데이터도 업데이트 (로컬 캐시)
          MockPartyData.updateMyParty(
            partyId: partyId,
            name: name,
            startTime: startTime,
            maxMembers: maxMembers,
            contentType: contentType,
            category: category,
            difficulty: difficulty,
            requireJob: requireJob,
            requirePower: requirePower,
            minPower: minPower,
            maxPower: maxPower,
            requireJobCategory: requireJobCategory,
            tankLimit: tankLimit,
            healerLimit: healerLimit,
            dpsLimit: dpsLimit,
          );

          // 파티 리스트 새로고침
          ref.invalidate(myPartiesProvider);
          ref.invalidate(joinedPartiesProvider);
        },
      );
    } catch (e) {
      print('❌ 파티 수정 에러: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
