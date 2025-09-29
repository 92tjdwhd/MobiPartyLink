import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_member_entity.dart';

class MockPartyData {
  // 동적으로 생성된 파티들을 저장하는 리스트
  static final List<PartyEntity> _myParties = [];
  static final List<PartyEntity> _joinedParties = [];

  static List<PartyEntity> getMyParties() {
    // 기본 파티들과 동적으로 추가된 파티들을 합쳐서 반환
    final defaultParties = [
      PartyEntity(
        id: '1',
        name: '서큐버스 레이드 입문',
        creatorId: 'user1',
        startTime: DateTime.now().add(const Duration(minutes: 5)), // 5분 후로 변경
        maxMembers: 4,
        contentType: '서큐버스 레이드',
        category: '레이드',
        difficulty: '입문',
        status: PartyStatus.pending,
        members: [
          PartyMemberEntity(
            id: 'member1',
            partyId: '1',
            userId: 'user1',
            nickname: '플레이어1',
            jobId: 'warrior',
            power: 1500,
            joinedAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
        requireJob: true,
        requirePower: true,
        minPower: 1000,
        maxPower: 2000,
        requireJobCategory: true,
        tankLimit: 1,
        healerLimit: 1,
        dpsLimit: 2,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PartyEntity(
        id: '2',
        name: '글라스기브넨 레이드 어려움',
        creatorId: 'user1',
        startTime: DateTime.now().add(const Duration(minutes: 10)), // 10분 후로 변경
        maxMembers: 8,
        contentType: '글라스기브넨 레이드',
        category: '레이드',
        difficulty: '어려움',
        status: PartyStatus.pending,
        members: [
          PartyMemberEntity(
            id: 'member2',
            partyId: '2',
            userId: 'user1',
            nickname: '플레이어1',
            jobId: 'warrior',
            power: 1500,
            joinedAt: DateTime.now().subtract(const Duration(minutes: 15)),
          ),
        ],
        requireJob: true,
        requirePower: true,
        minPower: 2000,
        maxPower: 3000,
        requireJobCategory: true,
        tankLimit: 2,
        healerLimit: 2,
        dpsLimit: 4,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];

    return [...defaultParties, ..._myParties];
  }

  static List<PartyEntity> getJoinedParties() {
    // 기본 파티들과 동적으로 추가된 파티들을 합쳐서 반환
    final defaultParties = [
      PartyEntity(
        id: '3',
        name: '마스던전 어비스 입문',
        creatorId: 'user2',
        startTime: DateTime.now().add(const Duration(hours: 3)),
        maxMembers: 4,
        contentType: '마스던전 어비스',
        category: '어비스',
        difficulty: '입문',
        status: PartyStatus.pending,
        members: [
          PartyMemberEntity(
            id: 'member3',
            partyId: '3',
            userId: 'user2',
            nickname: '파티장',
            jobId: 'mage',
            power: 1800,
            joinedAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          PartyMemberEntity(
            id: 'member4',
            partyId: '3',
            userId: 'user1',
            nickname: '플레이어1',
            jobId: 'warrior',
            power: 1500,
            joinedAt: DateTime.now().subtract(const Duration(minutes: 20)),
          ),
        ],
        requireJob: true,
        requirePower: true,
        minPower: 1200,
        maxPower: 2500,
        requireJobCategory: true,
        tankLimit: 1,
        healerLimit: 1,
        dpsLimit: 2,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    return [...defaultParties, ..._joinedParties];
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
