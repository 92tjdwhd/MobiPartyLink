class PartyDifficultyConstants {
  // 파티 난이도
  static const List<String> difficulties = [
    'easy',
    'normal',
    'hard',
    'extreme',
    'nightmare',
  ];

  // 난이도 한국어 이름
  static const Map<String, String> difficultyNames = {
    'easy': '쉬움',
    'normal': '보통',
    'hard': '어려움',
    'extreme': '극한',
    'nightmare': '악몽',
  };

  // 난이도 설명
  static const Map<String, String> difficultyDescriptions = {
    'easy': '초보자도 참여할 수 있는 쉬운 난이도입니다.',
    'normal': '일반적인 난이도로 대부분의 플레이어가 참여 가능합니다.',
    'hard': '경험이 있는 플레이어를 위한 어려운 난이도입니다.',
    'extreme': '고수 플레이어를 위한 극한 난이도입니다.',
    'nightmare': '최고 수준의 플레이어만 도전할 수 있는 악몽 난이도입니다.',
  };

  // 난이도 아이콘
  static const Map<String, String> difficultyIcons = {
    'easy': 'assets/icons/difficulty_easy.png',
    'normal': 'assets/icons/difficulty_normal.png',
    'hard': 'assets/icons/difficulty_hard.png',
    'extreme': 'assets/icons/difficulty_extreme.png',
    'nightmare': 'assets/icons/difficulty_nightmare.png',
  };

  // 난이도 색상
  static const Map<String, int> difficultyColors = {
    'easy': 0xFF38A169, // 초록색
    'normal': 0xFF4299E1, // 파란색
    'hard': 0xFFD69E2E, // 노란색
    'extreme': 0xFFE53E3E, // 빨간색
    'nightmare': 0xFF805AD5, // 보라색
  };

  // 난이도별 기본 투력 요구사항
  static const Map<String, int?> difficultyPowerRequirements = {
    'easy': 500,
    'normal': 1000,
    'hard': 2000,
    'extreme': 4000,
    'nightmare': 8000,
  };

  // 난이도별 추천 인원수 범위
  static const Map<String, Map<String, int>> difficultyMemberRanges = {
    'easy': {'min': 2, 'max': 8},
    'normal': {'min': 4, 'max': 8},
    'hard': {'min': 4, 'max': 8},
    'extreme': {'min': 6, 'max': 8},
    'nightmare': {'min': 8, 'max': 8},
  };

  // 난이도별 추천 직업 조합
  static const Map<String, List<String>> difficultyRecommendedJobs = {
    'easy': ['warrior', 'archer', 'mage', 'priest'],
    'normal': ['warrior', 'archer', 'mage', 'priest'],
    'hard': ['warrior', 'archer', 'mage', 'priest', 'rogue'],
    'extreme': ['warrior', 'archer', 'mage', 'priest', 'rogue', 'paladin'],
    'nightmare': [
      'warrior',
      'archer',
      'mage',
      'priest',
      'rogue',
      'paladin',
      'monk'
    ],
  };
}
