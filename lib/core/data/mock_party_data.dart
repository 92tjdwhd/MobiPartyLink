import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_member_entity.dart';

class MockPartyData {
  // 동적으로 생성된 파티들을 저장하는 리스트
  static final List<PartyEntity> _myParties = [];
  static final List<PartyEntity> _joinedParties = [];

  static List<PartyEntity> getMyParties() {
    // Mock 데이터 제거 - 서버에서만 가져오기
    return _myParties;
  }

  static List<PartyEntity> getJoinedParties() {
    // Mock 데이터 제거 - 서버에서만 가져오기
    return _joinedParties;
  }

  // 새로 생성된 파티를 내가 만든 파티 리스트에 추가
  static void addMyParty(PartyEntity party) {
    print('MockPartyData.addMyParty 호출됨: ${party.name}');
    _myParties.add(party);
    print('추가 후 내가 만든 파티 수: ${_myParties.length}');
  }

  // 새로 참가한 파티를 참가한 파티 리스트에 추가
  static void addJoinedParty(PartyEntity party) {
    _joinedParties.add(party);
  }

  // 내가 만든 파티 수정
  static PartyEntity? updateMyParty({
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
  }) {
    for (int i = 0; i < _myParties.length; i++) {
      if (_myParties[i].id == partyId) {
        final updatedParty = _myParties[i].copyWith(
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
        _myParties[i] = updatedParty;
        print('MockPartyData.updateMyParty 호출됨: $name');
        return updatedParty;
      }
    }
    return null;
  }

  // 파티 삭제
  static void removeParty(String partyId) {
    _myParties.removeWhere((party) => party.id == partyId);
    _joinedParties.removeWhere((party) => party.id == partyId);
  }
}
