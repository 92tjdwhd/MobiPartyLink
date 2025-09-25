import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobi_party_link/core/di/injection.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';

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
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (party) => state = AsyncValue.data(party),
    );
  }

  void clearState() {
    state = const AsyncValue.data(null);
  }
}
