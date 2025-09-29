import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobi_party_link/core/di/injection.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/core/data/mock_party_data.dart';
import 'package:mobi_party_link/features/notification/presentation/providers/party_notification_provider.dart';

part 'party_creation_provider.g.dart';

@riverpod
class PartyCreationNotifier extends _$PartyCreationNotifier {
  @override
  AsyncValue<PartyEntity?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> createParty({
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

    final createPartyUseCase = ref.read(createPartyProvider);

    final result = await createPartyUseCase.call(
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

    result.fold(
      (failure) {
        print('파티 생성 실패: $failure');
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (party) {
        print('파티 생성 성공: ${party.name}');
        // 새로 생성된 파티를 Mock 데이터에 추가
        MockPartyData.addMyParty(party);
        print('Mock 데이터에 추가됨. 현재 파티 수: ${MockPartyData.getMyParties().length}');

        // 파티 생성 시 알림 등록
        ref
            .read(partyNotificationProvider.notifier)
            .schedulePartyNotification(party);
        print('파티 알림 등록 완료: ${party.name}');

        state = AsyncValue.data(party);
      },
    );
  }

  void clearState() {
    state = const AsyncValue.data(null);
  }
}
