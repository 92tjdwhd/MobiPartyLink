import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/party_entity.dart';
import '../../domain/usecases/search_parties.dart';

part 'party_search_provider.g.dart';

@riverpod
class PartySearchNotifier extends _$PartySearchNotifier {
  @override
  Future<List<PartyEntity>> build() async {
    // 초기에는 모든 파티를 가져옴
    final searchParties = ref.read(searchPartiesProvider);
    final result = await searchParties();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (parties) => parties,
    );
  }

  /// 파티 검색
  Future<void> search({
    String? query,
    String? contentType,
    bool? requireJob,
    bool? requirePower,
    int? minPower,
    int? maxPower,
    PartyStatus? status,
  }) async {
    state = const AsyncLoading();

    final searchParties = ref.read(searchPartiesProvider);
    final result = await searchParties(
      query: query,
      contentType: contentType,
      requireJob: requireJob,
      requirePower: requirePower,
      minPower: minPower,
      maxPower: maxPower,
      status: status,
    );

    result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
      },
      (parties) {
        state = AsyncData(parties);
      },
    );
  }

  /// 검색 초기화 (모든 파티 표시)
  Future<void> clearSearch() async {
    await search();
  }

  /// 텍스트 검색
  Future<void> searchByText(String query) async {
    await search(query: query);
  }

  /// 콘텐츠 타입으로 필터링
  Future<void> filterByContentType(String contentType) async {
    await search(contentType: contentType);
  }

  /// 직업 필수 여부로 필터링
  Future<void> filterByJobRequirement(bool requireJob) async {
    await search(requireJob: requireJob);
  }

  /// 투력 필수 여부로 필터링
  Future<void> filterByPowerRequirement(bool requirePower) async {
    await search(requirePower: requirePower);
  }

  /// 파티 상태로 필터링
  Future<void> filterByStatus(PartyStatus status) async {
    await search(status: status);
  }

  /// 복합 필터링
  Future<void> applyFilters({
    String? query,
    String? contentType,
    bool? requireJob,
    bool? requirePower,
    PartyStatus? status,
  }) async {
    await search(
      query: query,
      contentType: contentType,
      requireJob: requireJob,
      requirePower: requirePower,
      status: status,
    );
  }
}
