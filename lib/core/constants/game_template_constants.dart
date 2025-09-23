class GameTemplateConstants {
  // 게임 콘텐츠별 기본 템플릿들
  static const List<Map<String, dynamic>> gameTemplates = [
    // 서큐버스 레이드 템플릿들
    {
      'id': 'template_succubus_raid_beginner',
      'name': '서큐버스 레이드 (입문)',
      'description': '서큐버스 레이드 입문자용 파티입니다.',
      'contentType': 'raid',
      'category': '레이드',
      'difficulty': '입문',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 500,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자'],
      'iconUrl': 'assets/icons/succubus_raid_beginner.png',
      'isDefault': true,
    },
    {
      'id': 'template_succubus_raid_hard',
      'name': '서큐버스 레이드 (어려움)',
      'description': '서큐버스 레이드 어려움 난이도 파티입니다.',
      'contentType': 'raid',
      'category': '레이드',
      'difficulty': '어려움',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 2000,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자'],
      'iconUrl': 'assets/icons/succubus_raid_hard.png',
      'isDefault': true,
    },
    {
      'id': 'template_succubus_raid_extreme',
      'name': '서큐버스 레이드 (매우어려움)',
      'description': '서큐버스 레이드 매우어려움 난이도 파티입니다.',
      'contentType': 'raid',
      'category': '레이드',
      'difficulty': '매우어려움',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 4000,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자'],
      'iconUrl': 'assets/icons/succubus_raid_extreme.png',
      'isDefault': true,
    },

    // 글라스기브넨 레이드 템플릿들
    {
      'id': 'template_glasgibnen_raid_beginner',
      'name': '글라스기브넨 레이드 (입문)',
      'description': '글라스기브넨 레이드 입문자용 파티입니다.',
      'contentType': 'raid',
      'category': '레이드',
      'difficulty': '입문',
      'maxMembers': 8,
      'requireJob': true,
      'requirePower': true,
      'minPower': 800,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자', '도적', '성기사'],
      'iconUrl': 'assets/icons/glasgibnen_raid_beginner.png',
      'isDefault': true,
    },
    {
      'id': 'template_glasgibnen_raid_hard',
      'name': '글라스기브넨 레이드 (어려움)',
      'description': '글라스기브넨 레이드 어려움 난이도 파티입니다.',
      'contentType': 'raid',
      'category': '레이드',
      'difficulty': '어려움',
      'maxMembers': 8,
      'requireJob': true,
      'requirePower': true,
      'minPower': 3000,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자', '도적', '성기사'],
      'iconUrl': 'assets/icons/glasgibnen_raid_hard.png',
      'isDefault': true,
    },
    {
      'id': 'template_glasgibnen_raid_extreme',
      'name': '글라스기브넨 레이드 (매우어려움)',
      'description': '글라스기브넨 레이드 매우어려움 난이도 파티입니다.',
      'contentType': 'raid',
      'category': '레이드',
      'difficulty': '매우어려움',
      'maxMembers': 8,
      'requireJob': true,
      'requirePower': true,
      'minPower': 6000,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자', '도적', '성기사'],
      'iconUrl': 'assets/icons/glasgibnen_raid_extreme.png',
      'isDefault': true,
    },

    // 마스던전 어비스 템플릿들
    {
      'id': 'template_master_dungeon_abyss_beginner',
      'name': '마스던전 어비스 (입문)',
      'description': '마스던전 어비스 입문자용 파티입니다.',
      'contentType': 'dungeon',
      'category': '어비스',
      'difficulty': '입문',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': false,
      'minPower': null,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자'],
      'iconUrl': 'assets/icons/master_dungeon_abyss_beginner.png',
      'isDefault': true,
    },
    {
      'id': 'template_master_dungeon_abyss_hard',
      'name': '마스던전 어비스 (어려움)',
      'description': '마스던전 어비스 어려움 난이도 파티입니다.',
      'contentType': 'dungeon',
      'category': '어비스',
      'difficulty': '어려움',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 1500,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자'],
      'iconUrl': 'assets/icons/master_dungeon_abyss_hard.png',
      'isDefault': true,
    },
    {
      'id': 'template_master_dungeon_abyss_extreme',
      'name': '마스던전 어비스 (매우어려움)',
      'description': '마스던전 어비스 매우어려움 난이도 파티입니다.',
      'contentType': 'dungeon',
      'category': '어비스',
      'difficulty': '매우어려움',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 3000,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자'],
      'iconUrl': 'assets/icons/master_dungeon_abyss_extreme.png',
      'isDefault': true,
    },
    {
      'id': 'template_master_dungeon_abyss_hell1',
      'name': '마스던전 어비스 (지옥1)',
      'description': '마스던전 어비스 지옥1 난이도 파티입니다.',
      'contentType': 'dungeon',
      'category': '어비스',
      'difficulty': '지옥1',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 5000,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자'],
      'iconUrl': 'assets/icons/master_dungeon_abyss_hell1.png',
      'isDefault': true,
    },
    {
      'id': 'template_master_dungeon_abyss_hell2',
      'name': '마스던전 어비스 (지옥2)',
      'description': '마스던전 어비스 지옥2 난이도 파티입니다.',
      'contentType': 'dungeon',
      'category': '어비스',
      'difficulty': '지옥2',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 6000,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자'],
      'iconUrl': 'assets/icons/master_dungeon_abyss_hell2.png',
      'isDefault': true,
    },
    {
      'id': 'template_master_dungeon_abyss_hell3',
      'name': '마스던전 어비스 (지옥3)',
      'description': '마스던전 어비스 지옥3 난이도 파티입니다.',
      'contentType': 'dungeon',
      'category': '어비스',
      'difficulty': '지옥3',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 7000,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자'],
      'iconUrl': 'assets/icons/master_dungeon_abyss_hell3.png',
      'isDefault': true,
    },
    {
      'id': 'template_master_dungeon_abyss_hell4',
      'name': '마스던전 어비스 (지옥4)',
      'description': '마스던전 어비스 지옥4 난이도 파티입니다.',
      'contentType': 'dungeon',
      'category': '어비스',
      'difficulty': '지옥4',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 8000,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자'],
      'iconUrl': 'assets/icons/master_dungeon_abyss_hell4.png',
      'isDefault': true,
    },
    {
      'id': 'template_master_dungeon_abyss_hell5',
      'name': '마스던전 어비스 (지옥5)',
      'description': '마스던전 어비스 지옥5 난이도 파티입니다.',
      'contentType': 'dungeon',
      'category': '어비스',
      'difficulty': '지옥5',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 9000,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자'],
      'iconUrl': 'assets/icons/master_dungeon_abyss_hell5.png',
      'isDefault': true,
    },
    {
      'id': 'template_master_dungeon_abyss_hell6',
      'name': '마스던전 어비스 (지옥6)',
      'description': '마스던전 어비스 지옥6 난이도 파티입니다.',
      'contentType': 'dungeon',
      'category': '어비스',
      'difficulty': '지옥6',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 10000,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자'],
      'iconUrl': 'assets/icons/master_dungeon_abyss_hell6.png',
      'isDefault': true,
    },
    {
      'id': 'template_master_dungeon_abyss_hell7',
      'name': '마스던전 어비스 (지옥7)',
      'description': '마스던전 어비스 지옥7 난이도 파티입니다.',
      'contentType': 'dungeon',
      'category': '어비스',
      'difficulty': '지옥7',
      'maxMembers': 4,
      'requireJob': true,
      'requirePower': true,
      'minPower': 11000,
      'maxPower': null,
      'recommendedJobs': ['전사', '궁수', '마법사', '성직자'],
      'iconUrl': 'assets/icons/master_dungeon_abyss_hell7.png',
      'isDefault': true,
    },
  ];

  // 템플릿 카테고리별 그룹화
  static Map<String, List<Map<String, dynamic>>> get templatesByCategory {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final template in gameTemplates) {
      final category = template['category'] as String;
      grouped.putIfAbsent(category, () => []).add(template);
    }

    return grouped;
  }

  // 특정 카테고리의 템플릿들 가져오기
  static List<Map<String, dynamic>> getTemplatesByCategory(String category) {
    return gameTemplates
        .where((template) => template['category'] == category)
        .toList();
  }

  // 특정 난이도의 템플릿들 가져오기
  static List<Map<String, dynamic>> getTemplatesByDifficulty(
      String difficulty) {
    return gameTemplates
        .where((template) => template['difficulty'] == difficulty)
        .toList();
  }

  // 특정 콘텐츠 타입의 템플릿들 가져오기
  static List<Map<String, dynamic>> getTemplatesByContentType(
      String contentType) {
    return gameTemplates
        .where((template) => template['contentType'] == contentType)
        .toList();
  }
}
