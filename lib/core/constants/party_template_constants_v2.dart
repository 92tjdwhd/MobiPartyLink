
class PartyTemplateConstants {
  // 템플릿 버전 관리
  static const int currentTemplateVersion = 1;
  static const int defaultTemplateCount = 4;

  // 기본 파티 템플릿들 (버전 1 - 카테고리 + 난이도별)
  static const List<Map<String, dynamic>> defaultTemplates = [
    // 레이드 템플릿들
    {
      'id': 'template_raid_normal_4',
      'name': '레이드 파티 (보통)',
      'description': '일반적인 레이드 파티입니다. 직업과 투력을 확인합니다.',
      'contentType': 'raid',
      'category': 'raid',
      'difficulty': 'normal',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 1000,
      'maxPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
      'iconUrl': 'assets/icons/raid_normal.png',
      'isDefault': true,
    },
    {
      'id': 'template_raid_hard_8',
      'name': '레이드 파티 (어려움)',
      'description': '어려운 레이드 파티입니다. 고수 플레이어를 위한 파티입니다.',
      'contentType': 'raid',
      'category': 'raid',
      'difficulty': 'hard',
      'maxMembers': 8,
      'requireJob': true,
      'requirePower': true,
      'minPower': 2000,
      'maxPower': null,
      'recommendedJobs': [
        'warrior',
        'archer',
        'mage',
        'priest',
        'rogue',
        'paladin'
      ],
      'iconUrl': 'assets/icons/raid_hard.png',
      'isDefault': true,
    },
    // 던전 템플릿들
    {
      'id': 'template_dungeon_easy_4',
      'name': '던전 파티 (쉬움)',
      'description': '초보자를 위한 던전 파티입니다.',
      'contentType': 'dungeon',
      'category': 'dungeon',
      'difficulty': 'easy',
      'maxMembers': 4,
      'requireJob': false,
      'requirePower': false,
      'minPower': null,
      'maxPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
      'iconUrl': 'assets/icons/dungeon_easy.png',
      'isDefault': true,
    },
    {
      'id': 'template_dungeon_normal_4',
      'name': '던전 파티 (보통)',
      'description': '일반적인 던전 파티입니다. 빠른 진행을 위해 직업을 확인합니다.',
      'contentType': 'dungeon',
      'category': 'dungeon',
      'difficulty': 'normal',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': false,
      'minPower': null,
      'maxPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
      'iconUrl': 'assets/icons/dungeon_normal.png',
      'isDefault': true,
    },
    // PvP 템플릿들
    {
      'id': 'template_pvp_normal_2',
      'name': 'PvP 파티 (보통)',
      'description': '일반적인 PvP 파티입니다. 투력이 중요합니다.',
      'contentType': 'pvp',
      'category': 'pvp',
      'difficulty': 'normal',
      'maxMembers': 2,
      'requireJob': false,
      'requirePower': true,
      'minPower': 1000,
      'maxPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage'],
      'iconUrl': 'assets/icons/pvp_normal.png',
      'isDefault': true,
    },
    {
      'id': 'template_pvp_hard_2',
      'name': 'PvP 파티 (어려움)',
      'description': '고수 PvP 파티입니다. 높은 투력이 필요합니다.',
      'contentType': 'pvp',
      'category': 'pvp',
      'difficulty': 'hard',
      'maxMembers': 2,
      'requireJob': false,
      'requirePower': true,
      'minPower': 2000,
      'maxPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage'],
      'iconUrl': 'assets/icons/pvp_hard.png',
      'isDefault': true,
    },
    // 퀘스트 템플릿들
    {
      'id': 'template_quest_easy_4',
      'name': '퀘스트 파티 (쉬움)',
      'description': '초보자를 위한 퀘스트 파티입니다. 누구나 참여 가능합니다.',
      'contentType': 'quest',
      'category': 'quest',
      'difficulty': 'easy',
      'maxMembers': 4,
      'requireJob': false,
      'requirePower': false,
      'minPower': null,
      'maxPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
      'iconUrl': 'assets/icons/quest_easy.png',
      'isDefault': true,
    },
    {
      'id': 'template_quest_normal_4',
      'name': '퀘스트 파티 (보통)',
      'description': '일반적인 퀘스트 파티입니다. 빠른 완료를 위해 협력합니다.',
      'contentType': 'quest',
      'category': 'quest',
      'difficulty': 'normal',
      'maxMembers': 4,
      'requireJob': false,
      'requirePower': false,
      'minPower': null,
      'maxPower': null,
      'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
      'iconUrl': 'assets/icons/quest_normal.png',
      'isDefault': true,
    },
  ];

  // 템플릿 카테고리
  static const List<String> templateCategories = [
    'all',
    'raid',
    'dungeon',
    'pvp',
    'quest',
  ];

  // 템플릿 카테고리 한국어
  static const Map<String, String> templateCategoryNames = {
    'all': '전체',
    'raid': '레이드',
    'dungeon': '던전',
    'pvp': 'PvP',
    'quest': '퀘스트',
  };

  // 템플릿 아이콘
  static const Map<String, String> templateIcons = {
    'raid': 'assets/icons/raid.png',
    'dungeon': 'assets/icons/dungeon.png',
    'pvp': 'assets/icons/pvp.png',
    'quest': 'assets/icons/quest.png',
  };

  // 템플릿 색상
  static const Map<String, int> templateColors = {
    'raid': 0xFFE53E3E, // 빨간색
    'dungeon': 0xFF3182CE, // 파란색
    'pvp': 0xFF805AD5, // 보라색
    'quest': 0xFFD69E2E, // 노란색
  };

  // 템플릿 설명
  static const Map<String, String> templateDescriptions = {
    'raid': '강력한 보스와의 전투를 위한 파티입니다.',
    'dungeon': '던전 탐험을 위한 파티입니다.',
    'pvp': '다른 플레이어와의 대전을 위한 파티입니다.',
    'quest': '퀘스트 완료를 위한 파티입니다.',
  };

  // 로컬 저장 키
  static const String serverTemplatesKey = 'server_templates';
  static const String customTemplatesKey = 'custom_templates';
  static const String templateVersionKey = 'template_version';

  // 버전 체크 주기 (일)
  static const int versionCheckIntervalDays = 7;
}
