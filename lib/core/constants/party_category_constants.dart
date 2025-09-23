class PartyCategoryConstants {
  // 파티 카테고리
  static const List<String> categories = [
    'raid',
    'dungeon',
    'pvp',
    'guild',
    'quest',
    'event',
    'training',
    'social',
  ];

  // 카테고리 한국어 이름
  static const Map<String, String> categoryNames = {
    'raid': '레이드',
    'dungeon': '던전',
    'pvp': 'PvP',
    'guild': '길드',
    'quest': '퀘스트',
    'event': '이벤트',
    'training': '연습',
    'social': '소셜',
  };

  // 카테고리 설명
  static const Map<String, String> categoryDescriptions = {
    'raid': '강력한 보스와의 전투를 위한 파티입니다.',
    'dungeon': '던전 탐험을 위한 파티입니다.',
    'pvp': '다른 플레이어와의 대전을 위한 파티입니다.',
    'guild': '길드 활동을 위한 파티입니다.',
    'quest': '퀘스트 완료를 위한 파티입니다.',
    'event': '특별 이벤트를 위한 파티입니다.',
    'training': '연습 및 학습을 위한 파티입니다.',
    'social': '친목 및 소통을 위한 파티입니다.',
  };

  // 카테고리 아이콘
  static const Map<String, String> categoryIcons = {
    'raid': 'assets/icons/raid.png',
    'dungeon': 'assets/icons/dungeon.png',
    'pvp': 'assets/icons/pvp.png',
    'guild': 'assets/icons/guild.png',
    'quest': 'assets/icons/quest.png',
    'event': 'assets/icons/event.png',
    'training': 'assets/icons/training.png',
    'social': 'assets/icons/social.png',
  };

  // 카테고리 색상
  static const Map<String, int> categoryColors = {
    'raid': 0xFFE53E3E, // 빨간색
    'dungeon': 0xFF3182CE, // 파란색
    'pvp': 0xFF805AD5, // 보라색
    'guild': 0xFF38A169, // 초록색
    'quest': 0xFFD69E2E, // 노란색
    'event': 0xFFE53E3E, // 빨간색
    'training': 0xFF4299E1, // 하늘색
    'social': 0xFFED8936, // 주황색
  };

  // 카테고리별 기본 설정
  static const Map<String, Map<String, dynamic>> categoryDefaults = {
    'raid': {
      'maxMembers': 8,
      'requireJob': true,
      'requirePower': true,
      'minPower': 1500,
      'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
    },
    'dungeon': {
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': false,
      'minPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
    },
    'pvp': {
      'maxMembers': 2,
      'requireJob': false,
      'requirePower': true,
      'minPower': 2000,
      'recommendedJobs': ['warrior', 'archer', 'mage'],
    },
    'guild': {
      'maxMembers': 10,
      'requireJob': false,
      'requirePower': false,
      'minPower': null,
      'recommendedJobs': [
        'warrior',
        'archer',
        'mage',
        'priest',
        'rogue',
        'paladin'
      ],
    },
    'quest': {
      'maxMembers': 4,
      'requireJob': false,
      'requirePower': false,
      'minPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
    },
    'event': {
      'maxMembers': 6,
      'requireJob': false,
      'requirePower': false,
      'minPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
    },
    'training': {
      'maxMembers': 4,
      'requireJob': false,
      'requirePower': false,
      'minPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
    },
    'social': {
      'maxMembers': 8,
      'requireJob': false,
      'requirePower': false,
      'minPower': null,
      'recommendedJobs': [],
    },
  };
}
