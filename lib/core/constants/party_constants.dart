class PartyConstants {
  // 파티 설정
  static const int minPartyMembers = 1;
  static const int maxPartyMembers = 20;
  static const int defaultPartyMembers = 4;

  // 콘텐츠 타입
  static const List<String> contentTypeOptions = [
    'raid',
    'dungeon',
    'pvp',
    'guild',
    'quest',
  ];

  // 직업 옵션
  static const List<String> jobOptions = [
    'warrior',
    'archer',
    'mage',
    'priest',
    'rogue',
    'paladin',
    'monk',
  ];

  // 투력 범위
  static const int minPower = 0;
  static const int maxPower = 1000000;
  static const int defaultPower = 1000;

  // 파티 이름 길이 제한
  static const int minPartyNameLength = 1;
  static const int maxPartyNameLength = 100;

  // 닉네임 길이 제한
  static const int minNicknameLength = 1;
  static const int maxNicknameLength = 50;

  // 검색 설정
  static const int searchDebounceMs = 500;
  static const int maxSearchResults = 100;

  // 캐시 설정
  static const int partyListCacheMinutes = 5;
  static const int partyDetailCacheMinutes = 2;

  // 실시간 업데이트 설정
  static const int realtimeUpdateIntervalMs = 1000;

  // 에러 메시지
  static const String errorNetworkConnection = '인터넷 연결을 확인해주세요';
  static const String errorPartyNotFound = '파티를 찾을 수 없습니다';
  static const String errorPartyFull = '파티가 가득 찼습니다';
  static const String errorAlreadyJoined = '이미 참여한 파티입니다';
  static const String errorNotPartyMember = '파티 멤버가 아닙니다';
  static const String errorNotPartyCreator = '파티 생성자가 아닙니다';
  static const String errorInvalidPartyName = '올바른 파티 이름을 입력해주세요';
  static const String errorInvalidNickname = '올바른 닉네임을 입력해주세요';
  static const String errorInvalidPower = '올바른 투력을 입력해주세요';

  // 성공 메시지
  static const String successPartyCreated = '파티가 생성되었습니다';
  static const String successPartyJoined = '파티에 참여했습니다';
  static const String successPartyLeft = '파티에서 나갔습니다';
  static const String successPartyDeleted = '파티가 삭제되었습니다';
  static const String successPartyUpdated = '파티가 수정되었습니다';

  // 기본값
  static const String defaultPartyName = '새 파티';
  static const String defaultNickname = '익명사용자';
  static const String defaultContentType = 'raid';
  static const String defaultJob = 'warrior';
  static const int defaultMaxMembers = 4;
  static const bool defaultRequireJob = false;
  static const bool defaultRequirePower = false;
}
