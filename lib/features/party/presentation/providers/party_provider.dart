import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/party_entity.dart';
import '../../domain/entities/party_member_entity.dart';
import '../../domain/usecases/get_parties.dart';
import '../../domain/usecases/get_party_by_id.dart';
import '../../domain/usecases/create_party.dart';
import '../../domain/usecases/join_party.dart';
import '../../domain/usecases/leave_party.dart';
import '../../domain/usecases/delete_party.dart';
import '../../domain/usecases/update_party.dart';

part 'party_provider.g.dart';

@riverpod
class PartyListNotifier extends _$PartyListNotifier {
  @override
  Future<List<PartyEntity>> build() async {
    final getParties = ref.read(getPartiesProvider);
    final result = await getParties();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (parties) => parties,
    );
  }

  /// 파티 목록 새로고침
  Future<void> refresh() async {
    state = const AsyncLoading();

    final getParties = ref.read(getPartiesProvider);
    final result = await getParties();

    result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
      },
      (parties) {
        state = AsyncData(parties);
      },
    );
  }

  /// 파티 생성
  Future<void> createParty(PartyEntity party) async {
    final createParty = ref.read(createPartyProvider);
    final result = await createParty(party);

    result.fold(
      (failure) {
        throw Exception(failure.message);
      },
      (createdParty) {
        // 목록에 새 파티 추가
        state.whenData((parties) {
          state = AsyncData([createdParty, ...parties]);
        });
      },
    );
  }

  /// 파티 삭제
  Future<void> deleteParty(String partyId, String userId) async {
    final deleteParty = ref.read(deletePartyProvider);
    final result = await deleteParty(partyId, userId);

    result.fold(
      (failure) {
        throw Exception(failure.message);
      },
      (_) {
        // 목록에서 파티 제거
        state.whenData((parties) {
          state = AsyncData(parties.where((p) => p.id != partyId).toList());
        });
      },
    );
  }
}

@riverpod
class PartyDetailNotifier extends _$PartyDetailNotifier {
  @override
  Future<PartyEntity?> build(String partyId) async {
    final getPartyById = ref.read(getPartyByIdProvider);
    final result = await getPartyById(partyId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (party) => party,
    );
  }

  /// 파티 정보 새로고침
  Future<void> refresh() async {
    state = const AsyncLoading();

    final getPartyById = ref.read(getPartyByIdProvider);
    final result = await getPartyById(arg);

    result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
      },
      (party) {
        state = AsyncData(party);
      },
    );
  }

  /// 파티 참여
  Future<void> joinParty(PartyMemberEntity member) async {
    final joinParty = ref.read(joinPartyProvider);
    final result = await joinParty(arg, member);

    result.fold(
      (failure) {
        throw Exception(failure.message);
      },
      (_) {
        // 파티 정보 새로고침
        refresh();
      },
    );
  }

  /// 파티 나가기
  Future<void> leaveParty(String userId) async {
    final leaveParty = ref.read(leavePartyProvider);
    final result = await leaveParty(arg, userId);

    result.fold(
      (failure) {
        throw Exception(failure.message);
      },
      (_) {
        // 파티 정보 새로고침
        refresh();
      },
    );
  }

  /// 파티 업데이트
  Future<void> updateParty(PartyEntity party) async {
    final updateParty = ref.read(updatePartyProvider);
    final result = await updateParty(party);

    result.fold(
      (failure) {
        throw Exception(failure.message);
      },
      (updatedParty) {
        state = AsyncData(updatedParty);
      },
    );
  }
}
