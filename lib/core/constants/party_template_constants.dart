
class PartyTemplateConstants {
  // 템플릿 버전 관리
  static const int currentTemplateVersion = 1;
  static const int defaultTemplateCount = 4;

  // 기본 파티 템플릿들 (버전 1)
  static const List<Map<String, dynamic>> defaultTemplates = [
    {
      'id': 'template_raid_4',
      'name': '레이드 파티 (4인)',
      'description': '일반적인 레이드 파티입니다. 직업과 투력을 확인합니다.',
      'contentType': 'raid',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 1000,
      'maxPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
      'iconUrl': 'assets/icons/raid_4.png',
      'isDefault': true,
    },
    {
      'id': 'template_raid_8',
      'name': '레이드 파티 (8인)',
      'description': '대규모 레이드 파티입니다. 다양한 직업이 필요합니다.',
      'contentType': 'raid',
      'maxMembers': 8,
      'requireJob': true,
      'requirePower': true,
      'minPower': 1500,
      'maxPower': null,
      'recommendedJobs': [
        'warrior',
        'archer',
        'mage',
        'priest',
        'rogue',
        'paladin'
      ],
      'iconUrl': 'assets/icons/raid_8.png',
      'isDefault': true,
    },
    {
      'id': 'template_dungeon_4',
      'name': '던전 파티 (4인)',
      'description': '던전 탐험 파티입니다. 빠른 진행을 위해 직업을 확인합니다.',
      'contentType': 'dungeon',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': false,
      'minPower': null,
      'maxPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
      'iconUrl': 'assets/icons/dungeon_4.png',
      'isDefault': true,
    },
    {
      'id': 'template_pvp_2',
      'name': 'PvP 파티 (2인)',
      'description': 'PvP 대전 파티입니다. 투력이 중요합니다.',
      'contentType': 'pvp',
      'maxMembers': 2,
      'requireJob': false,
      'requirePower': true,
      'minPower': 2000,
      'maxPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage'],
      'iconUrl': 'assets/icons/pvp_2.png',
      'isDefault': true,
    },
    {
      'id': 'template_guild_10',
      'name': '길드 파티 (10인)',
      'description': '길드 활동 파티입니다. 모든 길드원이 참여 가능합니다.',
      'contentType': 'guild',
      'maxMembers': 10,
      'requireJob': false,
      'requirePower': false,
      'minPower': null,
      'maxPower': null,
      'recommendedJobs': [
        'warrior',
        'archer',
        'mage',
        'priest',
        'rogue',
        'paladin',
        'monk'
      ],
      'iconUrl': 'assets/icons/guild_10.png',
      'isDefault': true,
    },
    {
      'id': 'template_quest_4',
      'name': '퀘스트 파티 (4인)',
      'description': '퀘스트 완료 파티입니다. 누구나 참여 가능합니다.',
      'contentType': 'quest',
      'maxMembers': 4,
      'requireJob': false,
      'requirePower': false,
      'minPower': null,
      'maxPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
      'iconUrl': 'assets/icons/quest_4.png',
      'isDefault': true,
    },
  ];

  // 템플릿 카테고리
  static const List<String> templateCategories = [
    'all',
    'raid',
    'dungeon',
    'pvp',
    'guild',
    'quest',
  ];

  // 템플릿 카테고리 한국어
  static const Map<String, String> templateCategoryNames = {
    'all': '전체',
    'raid': '레이드',
    'dungeon': '던전',
    'pvp': 'PvP',
    'guild': '길드',
    'quest': '퀘스트',
  };

  // 템플릿 아이콘
  static const Map<String, String> templateIcons = {
    'raid': 'assets/icons/raid.png',
    'dungeon': 'assets/icons/dungeon.png',
    'pvp': 'assets/icons/pvp.png',
    'guild': 'assets/icons/guild.png',
    'quest': 'assets/icons/quest.png',
  };

  // 템플릿 색상
  static const Map<String, int> templateColors = {
    'raid': 0xFFE53E3E, // 빨간색
    'dungeon': 0xFF3182CE, // 파란색
    'pvp': 0xFF805AD5, // 보라색
    'guild': 0xFF38A169, // 초록색
    'quest': 0xFFD69E2E, // 노란색
  };

  // 템플릿 설명
  static const Map<String, String> templateDescriptions = {
    'raid': '강력한 보스와의 전투를 위한 파티입니다.',
    'dungeon': '던전 탐험을 위한 파티입니다.',
    'pvp': '다른 플레이어와의 대전을 위한 파티입니다.',
    'guild': '길드 활동을 위한 파티입니다.',
    'quest': '퀘스트 완료를 위한 파티입니다.',
  };
}
