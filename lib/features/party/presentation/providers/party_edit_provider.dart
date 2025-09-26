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
      // Mock 데이터에서 파티 수정
      final updatedParty = MockPartyData.updateMyParty(
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

      if (updatedParty != null) {
        print('파티 수정 성공: ${updatedParty.name}');
        state = AsyncValue.data(updatedParty);

        // 파티 리스트 새로고침
        ref.invalidate(myPartiesProvider);
        ref.invalidate(joinedPartiesProvider);
      } else {
        print('파티 수정 실패: 파티를 찾을 수 없음');
        state = AsyncValue.error('파티를 찾을 수 없습니다', StackTrace.current);
      }
    } catch (e) {
      print('파티 수정 실패: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
